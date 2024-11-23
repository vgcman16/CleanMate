#!/bin/bash

# Set up environment variables
export FASTLANE_USER="vgcman1993@gmail.com"
export FASTLANE_PASSWORD="Tommysport30"

# Create Fastlane match repository
fastlane match init

# Fetch team IDs
echo "Fetching Apple Developer team information..."
fastlane run get_team_name

echo "Please copy the Team ID and App Store Connect Team ID from above and update them in fastlane/Appfile"
