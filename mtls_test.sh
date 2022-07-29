DEFAULT_COLOR='\033[0m' 
BOLD_CYAN='\033[1;35m' 
BOLD_YELLOW='\033[1;33m'



# start clean by deleting old certs
rm -rf certs

mkdir certs
cd certs

printf "${BOLD_YELLOW}Step1: Create a root key signing authority."
printf "This shall serve as root CA for signing and verifying both client and server certificates"
printf "${DEFAULT_COLOR} ->"
echo
# save password in a file for server certificate
printf secret > ca_passphrase.txt

# generate 4096 bit RSA private key in des3 fromat. This will require passphrase
openssl genrsa -des3 -passout file:ca_passphrase.txt -out ca.key 4096

# convert ca.key from des3 to RSA format. This too shall require passphrase
openssl rsa -passin file:ca_passphrase.txt -in ca.key -out ca.key

# now create a certificate (aka public key of ca.key + signature) for this private key
openssl req -new -passin file:ca_passphrase.txt -x509 -days 3650 -key ca.key -subj "/CN=*.test.server" -out ca.crt
printf "${BOLD_CYAN}Certificate authority generated."
printf "Press enter to continue."
printf "${DEFAULT_COLOR} ->"
echo
read continue_input
echo ""
echo ""



printf "${BOLD_YELLOW}Step 2: Create the certificate for the SERVER"
printf "${DEFAULT_COLOR} ->"
echo
# save password in a file for server certificate
printf secret > passphrase.txt

# generate a 2048 bit private key for server in des3 format
openssl genrsa -des3 -passout file:passphrase.txt -out server.key 2048

# use this private key to create a certificate signing request (CSR) for server
openssl req -new -passin file:passphrase.txt -key server.key -subj "/CN=*.test.server" -out server.csr

# now create a certificate (aka public key of server.key + signature) for this private key
# we are making this certificate valid for 365 days. Also sign it with the certificate authority
openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt
printf "${BOLD_CYAN}Certificate for SERVER created."
printf "Press enter to continue."
printf "${DEFAULT_COLOR} ->"
echo
read continue_input
echo ""
echo ""


printf "${BOLD_YELLOW}Step 3: Create the certificate for the CLIENT"
printf "${DEFAULT_COLOR} ->"
echo
# save password in a file for server certificate
printf secret > client_passphrase.txt

# generate a 2048 bit private key for server in des3 format
openssl genrsa -des3 -passout file:client_passphrase.txt -out client.key 2048

# convert client.key from des3 to RSA format.
openssl rsa -passin file:client_passphrase.txt -in client.key -out client.key

# use this private key to create a certificate signing request (CSR) for server
openssl req -new -key client.key -subj "/CN=*.test.client" -out client.csr

# now create a certificate (aka public key of server.key + signature) for this private key
# we are making this certificate valid for 365 days. Also sign it with the certificate authority
openssl x509 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt
printf "${BOLD_CYAN}Certificate for CLIENT created."
printf "Press enter to continue."
printf "${DEFAULT_COLOR} ->"
echo
read continue_input
echo ""
echo ""

printf "${BOLD_YELLOW}Now we shall use these certificates to run nginx with mTLS in docker."
printf "Press enter to continue."
printf "${DEFAULT_COLOR} ->"
echo
read continue_input

cd ../

docker run --rm --name mtls-nginx -p 443:443 -v $(pwd)/certs/ca.crt:/etc/nginx/mtls/ca.crt -v $(pwd)/certs/server.key:/etc/nginx/certs/tls.key -v $(pwd)/certs/server.crt:/etc/nginx/certs/tls.crt -v $(pwd)/nginx.mtls.conf:/etc/nginx/conf.d/nginx.conf -v $(pwd)/certs/passphrase.txt:/etc/nginx/certs/password nginx
