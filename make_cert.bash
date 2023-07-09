#!/bin/sh

echo "making cert for ip adress based on

 this one call it like this 
 make_cert.sh | bash -s 127.0.0.1
 
 REF:https://medium.com/@antelle/how-to-generate-a-self-signed-ssl-certificate-for-an-ip-address-f0dd8dddf754
 online call it like this curl -sS https://raw.githubusercontent.com/antelle/generate-ip-cert/master/generate-ip-cert.sh | bash -s 127.0.0.1
"
IP=$(echo $1 | egrep -o "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$")

if [ ! $IP ]
then
    echo "Usage: generate-ip-cert.sh 127.0.0.1"
    exit 1
fi

echo "[req]
default_bits  = 2048
distinguished_name = req_distinguished_name
req_extensions = req_ext
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
countryName = XX
stateOrProvinceName = N/A
localityName = N/A
organizationName = Self-signed certificate
commonName = $IP: Self-signed certificate

[req_ext]
subjectAltName = @alt_names

[v3_req]
subjectAltName = @alt_names

[alt_names]
IP.1 = 127.0.0.1
IP.2 = $IP
" > san.cnf

openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout key.pem -out cert.pem -config san.cnf
rm san.cnf
