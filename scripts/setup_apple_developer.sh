#!/bin/bash

# Create necessary directories
mkdir -p certificates
cd certificates

# Generate a new key pair
openssl genrsa -out CleanMate.key 2048

# Generate a Certificate Signing Request (CSR)
openssl req -new -key CleanMate.key -out CleanMate.certSigningRequest -subj "/emailAddress=vgcman1993@gmail.com/CN=CleanMate iOS Distribution/C=US"

echo "=========================================="
echo "Certificate Signing Request has been generated!"
echo "=========================================="
echo ""
echo "Please follow these steps:"
echo ""
echo "1. Go to https://developer.apple.com/account/resources/certificates/list"
echo "2. Sign in with your Apple ID (vgcman1993@gmail.com)"
echo ""
echo "3. Get your Team ID:"
echo "   - Look at the top right of the page"
echo "   - Your Team ID is shown there (format: XXXXXXXXXX)"
echo ""
echo "4. Create Distribution Certificate:"
echo "   - Click [+] to add a new certificate"
echo "   - Select 'Apple Distribution'"
echo "   - Upload the CSR file: certificates/CleanMate.certSigningRequest"
echo "   - Download the certificate"
echo ""
echo "5. Go to App Store Connect (https://appstoreconnect.apple.com)"
echo "   - Click on 'Users and Access'"
echo "   - Your Team ID is shown at the top of the page"
echo ""
echo "6. Generate App-Specific Password:"
echo "   - Go to https://appleid.apple.com"
echo "   - Sign in with your Apple ID"
echo "   - Go to Security > App-Specific Passwords"
echo "   - Click [+] to generate a new password"
echo "   - Name it 'CleanMate Fastlane'"
echo ""
echo "After you have downloaded the certificate:"
echo "1. Move it to the certificates directory"
echo "2. Run: security create-keychain -p [keychain-password] CleanMate.keychain"
echo "3. Run: security import [downloaded-certificate].cer -k CleanMate.keychain -T /usr/bin/codesign"
echo "4. Run: security import CleanMate.key -k CleanMate.keychain -T /usr/bin/codesign"
echo "5. Run: security export -k CleanMate.keychain -t identities -f pkcs12 -o CleanMate.p12"
echo ""
echo "Then encode the certificate:"
echo "base64 -i CleanMate.p12 | pbcopy"
echo ""
echo "This will copy the base64-encoded certificate to your clipboard."
echo "Add this as the CERTIFICATE_BASE64 secret in your GitHub repository."
