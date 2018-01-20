
# install dependancies
sudo apt-get update
sudo apt install openvpn easy-rsa

# generate server ca
# rm -rf openvpn-ca
make-cadir openvpn-ca
cp confs/vars openvpn-ca/vars
source openvpn-ca/vars
./openvpn-ca/clean-all
export EASY_RSA="${EASY_RSA:-./openvpn-ca}"
"$EASY_RSA/pkitool" --initca
"$EASY_RSA/pkitool"  --server server
./openvpn-ca/build-dh
