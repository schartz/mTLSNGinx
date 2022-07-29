mkdir certs
cd certs

# generate 4096 bit RSA key in des3 fromat. This will require passphrase
openssl genrsa -des3 -out ca.key 4096


openssl rsa -in ca.key -out ca.key
openssl req -new -x509 -days 3650 -key ca.key -subj "/CN=*.test.server" -out ca.crt



echo "First we will generate the certificate for the SERVER"
printf test > passphrase.txt
openssl genrsa -des3 -passout file:passphrase.txt -out server.key 2048
openssl req -new -passin file:passphrase.txt -key server.key -subj "/CN=*.test.server" -out server.csr
openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt
echo "Certificate for SERVER generated."
echo "Press enter to continue."
read continue_input


echo "Now we will generate the certificate for the CLIENT"
printf test > client_passphrase.txt
openssl genrsa -des3 -passout file:client_passphrase.txt -out client.key 2048
openssl rsa -passin file:client_passphrase.txt -in client.key -out client.key
openssl req -new -key client.key -subj "/CN=*.test.client" -out client.csr

##Sign the certificate with the certificate authority
openssl x509 -req -days 365 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt
echo "Certificate for CLIENT generated."
echo "Press enter to continue."
read continue_input

echo "Now we shall use these certificates to run nginx with mTLS in docker."
echo "Press enter to continue."
read continue_input

cd ../

docker run --rm --name mtls-nginx -p 443:443 -v $(pwd)/certs/ca.crt:/etc/nginx/mtls/ca.crt -v $(pwd)/certs/server.key:/etc/nginx/certs/tls.key -v $(pwd)/certs/server.crt:/etc/nginx/certs/tls.crt -v $(pwd)/nginx.mtls.conf:/etc/nginx/conf.d/nginx.conf -v $(pwd)/certs/passphrase.txt:/etc/nginx/certs/password nginx
