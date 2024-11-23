#!/bin/bash

# Create directory for certificates
mkdir -p temp_certs

# Generate secure passwords
KEYCHAIN_PASSWORD=$(openssl rand -base64 24)
CERTIFICATE_PASSWORD=$(openssl rand -base64 24)

# Create secrets file
cat > temp_certs/github_secrets.txt << EOL
# GitHub Secrets Setup Instructions

Save these secrets in your GitHub repository:
(Settings -> Secrets and variables -> Actions -> New repository secret)

1. KEYCHAIN_PASSWORD
Value: ${KEYCHAIN_PASSWORD}

2. CERTIFICATE_PASSWORD
Value: ${CERTIFICATE_PASSWORD}

3. FASTLANE_USER
Value: [Your Apple ID email]

4. FASTLANE_PASSWORD
Value: [Your Apple ID password]

5. FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD
Generate at: https://appleid.apple.com/account/manage
Section: Security -> App-Specific Passwords

6. PROVISIONING_PROFILE_BASE64
After downloading your provisioning profile from Apple Developer Portal:
base64 -i path/to/profile.mobileprovision | pbcopy

7. CERTIFICATE_BASE64
After downloading your distribution certificate (p12):
base64 -i path/to/certificate.p12 | pbcopy

Instructions for certificates:

1. Distribution Certificate:
   - Go to Apple Developer Portal
   - Certificates, Identifiers & Profiles -> Certificates
   - Create a new iOS Distribution certificate
   - Download and export as .p12 with the password above
   - Convert using: base64 -i path/to/certificate.p12 | pbcopy

2. Provisioning Profile:
   - Go to Apple Developer Portal
   - Certificates, Identifiers & Profiles -> Profiles
   - Create a new Distribution profile for your app
   - Download and convert using: base64 -i path/to/profile.mobileprovision | pbcopy

3. App Store Connect API Key:
   - Go to App Store Connect
   - Users and Access -> Keys
   - Generate a new API Key
   - Save the Key ID and download the .p8 file

Remember:
- Keep these values secure and never commit them to the repository
- After setting up, delete the temp_certs directory
- Store the certificates and keys securely offline
EOL

echo "Instructions have been generated in temp_certs/github_secrets.txt"
echo "IMPORTANT: After setting up the secrets, delete the temp_certs directory"
