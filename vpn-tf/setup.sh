#!/bin/bash

# generate server ca
make-cadir /tmp/openvpn/ca

# copy pre-made configs
cp /tmp/openvpn/configs/vars /tmp/openvpn/ca/vars
source /tmp/openvpn/ca/vars
/tmp/openvpn/ca/clean-all

# build root ca
"$EASY_RSA/pkitool" --initca

# build server certificate and key pair
"$EASY_RSA/pkitool"  --server server

# build Diffie-Hellman parameters for key exchange
$OPENSSL dhparam -out ${KEY_DIR}/dh${KEY_SIZE}.pem ${KEY_SIZE}
openvpn --genkey --secret /tmp/openvpn/ca/keys/ta.key

# build client key
"$EASY_RSA/pkitool" client

# configure openvpn
echo "Moving files to /etc/openvpn"
sudo cp /tmp/openvpn/ca/keys/ca.crt /tmp/openvpn/ca/keys/server.crt /etc/openvpn
sudo cp /tmp/openvpn/ca/keys/server.key /etc/openvpn
sudo cp /tmp/openvpn/ca/keys/ta.key /tmp/openvpn/ca/keys/dh2048.pem /etc/openvpn
sudo cp /tmp/openvpn/configs/server.conf /etc/openvpn/server.conf

# networking settings
sudo sysctl -w net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE

# client config
# stolen from: digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-16-04
KEY_DIR=/tmp/openvpn/ca/keys
OUTPUT_DIR=/tmp/openvpn/client-configs/files
BASE_CONFIG=/tmp/openvpn/client-configs/base.conf
cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/client.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/client.key \
    <(echo -e '</key>\n<tls-auth>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-auth>') \
    > ${OUTPUT_DIR}/client.ovpn

