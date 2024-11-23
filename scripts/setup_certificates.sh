#!/bin/bash

# Create directories
mkdir -p certificates
cd certificates

# Generate distribution certificate
openssl genrsa -out CleanMate_Distribution.key 2048
openssl req -new -key CleanMate_Distribution.key -out CleanMate_Distribution.csr -subj "/emailAddress=vgcman16@gmail.com/CN=CleanMate Distribution/C=US"

echo "Distribution CSR generated at: certificates/CleanMate_Distribution.csr"
echo "Please follow these steps:"
echo "1. Go to https://developer.apple.com/account/resources/certificates/list"
echo "2. Click the + button to create a new certificate"
echo "3. Select 'Apple Distribution'"
echo "4. Upload the CSR file (CleanMate_Distribution.csr)"
echo "5. Download the generated certificate"
echo "6. Convert to p12:"
echo "   security create-keychain -p [keychain-password] CleanMate.keychain"
echo "   security import [downloaded-certificate].cer -k CleanMate.keychain -T /usr/bin/codesign"
echo "   security import CleanMate_Distribution.key -k CleanMate.keychain -T /usr/bin/codesign"
echo "   security export -k CleanMate.keychain -t identities -f pkcs12 -o CleanMate_Distribution.p12"
echo ""
echo "After generating the p12 file, run:"
echo "base64 -i CleanMate_Distribution.p12 | pbcopy"
echo ""
echo "This will copy the base64-encoded certificate to your clipboard."
echo "Add this as the CERTIFICATE_BASE64 secret in your GitHub repository."
