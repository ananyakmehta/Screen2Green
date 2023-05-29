# Screen Time to Green Time
	# A desktop application that can process data from a fitness tracker and use it to control
	# access to the WiFi router, to help balance screen time and physical activity
# Algorithm
	# Function to return the number of steps for the desired user
	# Run the process until terminated
		# For each user, do the following:
			# Fetch the previous steps
			# Fetch the new steps using the above function
			# Compare the new steps with the previous steps

			# If the difference > 0 (user has done some activity)
				# Update the internet timeout value based on the diff
				# Set the previous steps to the new steps
			# If the difference = 0 (no additional physical activity)
				# Decrease the timeout value if not already 0
			# If the difference < 0
				# Display an error message and restart the script

			# Decide the internet access based on the timeout from above
			# If the timeout = 0
				# Turn off the internet access if internet is active
			# If the timeout > 0
				# Turn on the internet access if internet is inactive
