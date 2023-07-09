#!/bin/bash

function make_ssl() {
  local THISIP=$(myip | tail -1)
  local code="#!/bin/bash
#using: OpenSSL 1.1.1c FIPS  28 May 2019 / CentOS Linux release 8.2.2004

C=US ; ST=Confusion ; L=Anywhere ; O=Private\ Subnet ; EMAIL=admin@$THISIP
BITS=2048
CN=RFC1918
DOM=$THISIP
SUBJ="/C=\$C/ST=\$ST/L=\$L/O=\$O/CN=\$CN.\$DOM"

openssl genrsa -out ip.key \$BITS

SAN='\n[SAN]\nsubjectAltName=IP:192.168.1.0,IP:192.168.1.1,IP:192.168.1.2,IP:192.168.1.3,IP:192.168.1.4,IP:192.168.1.5,IP:192.168.1.6,IP:192.168.1.7,IP:192.168.1.8,IP:192.168.1.9,IP:192.168.1.10'

cp /etc/pki/tls/openssl.cnf /tmp/openssl.cnf
echo -e "\$SAN" >> /tmp/openssl.cnf

openssl req -subj "\$SUBJ" -new -x509 -days 10950 \
    -key ip.key -out ip.crt -batch \
    -set_serial 168933982 \
    -config /tmp/openssl.cnf \
    -extensions SAN

openssl x509 -in ip.crt -noout -text
"
echo running code:
 echo $code

 #!/bin/bash
#using: OpenSSL 1.1.1c FIPS  28 May 2019 / CentOS Linux release 8.2.2004

C=US ; ST=Confusion ; L=Anywhere ; O=Private\ Subnet ; EMAIL=admin@$THISIP
BITS=2048
CN=RFC1918
DOM=$THISIP
SUBJ="/C=$C/ST=$ST/L=$L/O=$O/CN=$CN.$DOM"

openssl genrsa -out ip.key $BITS

SAN='\n[SAN]\nsubjectAltName=IP:'
SAN="$SAN$THISIP"
SAN="$SAN,IP:192.168.1.0,IP:192.168.1.1,IP:192.168.1.2,IP:192.168.1.3,IP:192.168.1.4,IP:192.168.1.5,IP:192.168.1.6,IP:192.168.1.7,IP:192.168.1.8,IP:192.168.1.9,IP:192.168.1.10"

cp /etc/pki/tls/openssl.cnf /tmp/openssl.cnf
echo -e "$SAN" >> /tmp/openssl.cnf

openssl req -subj "$SUBJ" -new -x509 -days 10950 \
    -key ip.key -out ip.crt -batch \
    -set_serial 168933982 \
    -config /tmp/openssl.cnf \
    -extensions SAN

openssl x509 -in ip.crt -noout -text
}

make_ssl

