#!/bin/bash

# Global variables
USERS=(smt.dev001 smt.dev002)
declare -A PREVSTEPS=( [${USERS[0]}]=0 [${USERS[1]}]=0 )
declare -A TIMEOUT=( [${USERS[0]}]=0 [${USERS[1]}]=0 )
declare -A INTERNET=( [${USERS[0]}]=0 [${USERS[1]}]=0 )
declare -A ADDRESS=( [${USERS[0]}]=10.42.0.77 [${USERS[1]}]=10.42.0.226 )
declare -A SLOPE=( [${USERS[0]}]=0.13 [${USERS[1]}]=0.27 )

unblock_user() {
	printf "Unblocking IP address: %s" $1
	sudo iptables -D FORWARD -s 10.42.0.0/24 -i wlo1 -j ACCEPT
	sudo iptables -D FORWARD -s $1 -i wlo1 -j ACCEPT
	sudo iptables -I FORWARD 2 -s $1 -i wlo1 -j ACCEPT
}

block_user() {
	printf "Blocking IP address: %s" $1
	sudo iptables -D FORWARD -s 10.42.0.0/24 -i wlo1 -j ACCEPT
	sudo iptables -D FORWARD -s $1 -i wlo1 -j ACCEPT
}

# Run the process until terminated
while :
do
	echo "---------------------------------"
	# Iterate over the users and compute their internet access
	for userid in "${USERS[@]}"
	do
		printf "User: %s\n" $userid

		# Fetch the previous steps
		prev=${PREVSTEPS[$userid]}

		# Fetch the new steps
		new=$(curl --silent -X GET -H "X-Parse-Application-Id: E5MTBEcLG44oxsG1ZqwnNvmzMfNIsQKsMwd4ZJjj" -H "X-Parse-REST-API-Key: m6lxP4JOPjn9KpKxNfpFrc6SE17jgFevLPJCtk9P" -G --data-urlencode "where={ \"UserID\":\"$userid\" }" https://parseapi.back4app.com/classes/Fitness | jq '.results' | jq '.[]' | jq '.Steps')
		printf "Prev Steps=%d, New Steps=%d\n" $prev $new

		# Compare the new steps with the previous steps
		diff=$(( $new-$prev ))

		# If the diff > 0, set the counter value to the max & update prev steps 
		# If the diff = 0, update the counter value & continue
		# If the diff < 0, print an error message and restart script
		if [[ $diff -gt 0 ]]; then
			#TIMEOUT[$userid]=$(( $diff*${SLOPE[$userid]} ))
			tmp=`echo $diff \* ${SLOPE[$userid]} | bc -l`
			TIMEOUT[$userid]=${tmp%.*}
			PREVSTEPS[$userid]=$new
		elif [[ $diff -eq 0 ]]; then
			if [[ ${TIMEOUT[$userid]} -gt 0 ]]; then
				TIMEOUT[$userid]=$(( ${TIMEOUT[$userid]}-1 ))
			fi
		else
			printf "Something bad happend. Quitting..."
			exit
		fi

		# Decide the internet access based on the counter
		if [[ ${TIMEOUT[$userid]} -eq 0 ]]; then
			if [[ ${INTERNET[$userid]} -eq 1 ]]; then
				echo "Turning internet access OFF"
				block_user ${ADDRESS[$userid]}
				date +"%T"
				INTERNET[$userid]=0
			fi
		else
			if [[ ${INTERNET[$userid]} -eq 0 ]]; then
				echo "Turning internet access ON"
				unblock_user ${ADDRESS[$userid]}
				date +"%T"
				INTERNET[$userid]=1
			fi
			printf "Internet Timeout=%d\n\n" ${TIMEOUT[$userid]}
		fi
		sleep 1
	done
done
