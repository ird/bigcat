
# install dependancies
sudo apt-get -q update
sudo apt-get -q -y install openvpn easy-rsa

# generate server ca
# rm -rf openvpn-ca
make-cadir openvpn-ca
# copy pre-made configs
cp configs/vars openvpn-ca/vars
source openvpn-ca/vars
./openvpn-ca/clean-all
export EASY_RSA="${EASY_RSA:-./openvpn-ca}"
# build root ca
"$EASY_RSA/pkitool" --initca
# build server certificate and key pair
"$EASY_RSA/pkitool"  --server server
# build Diffie-Hellman parameters for key exchange
$OPENSSL dhparam -out ${KEY_DIR}/dh${KEY_SIZE}.pem ${KEY_SIZE}
openvpn --genkey --secret openvpn-ca/keys/ta.key

# configure openvpn
sudo cp openvpn-ca/keys/ca.crt openvpn-ca/keys/server.crt /etc/openvpn
sudo cp openvpn-ca/keys/server.key /etc/openvpn
sudo cp openvpn-ca/keys/ta.key openvpn-ca/keys/dh2048.pem /etc/openvpn

sudo cp configs/server.conf /etc/openvpn.conf

# start openvpn
sudo systemctl start openvpn@server
