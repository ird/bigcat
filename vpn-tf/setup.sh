# generate server ca
echo "Making CA dir from template"
make-cadir /tmp/openvpn/ca
# copy pre-made configs
cp /tmp/openvpn/configs/vars /tmp/openvpn/ca/vars
source /tmp/openvpn/ca/vars
/tmp/openvpn/ca/clean-all
echo "Building CA and server cert"
export EASY_RSA="${EASY_RSA}"
# build root ca
"$EASY_RSA/pkitool" --initca
# build server certificate and key pair
"$EASY_RSA/pkitool"  --server server
# build Diffie-Hellman parameters for key exchange
$OPENSSL dhparam -out ${KEY_DIR}/dh${KEY_SIZE}.pem ${KEY_SIZE}
openvpn --genkey --secret /tmp/openvpn/ca/keys/ta.key

# configure openvpn
echo "Moving files to /etc/openvpn"
sudo cp /tmp/openvpn/ca/keys/ca.crt /tmp/openvpn/ca/keys/server.crt /etc/openvpn
sudo cp /tmp/openvpn/ca/keys/server.key /etc/openvpn
sudo cp /tmp/openvpn/ca/keys/ta.key /tmp/openvpn/ca/keys/dh2048.pem /etc/openvpn
sudo cp configs/server.conf /etc/openvpn/server.conf

# start openvpn
sudo systemctl start openvpn@server
