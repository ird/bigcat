# port to host the server on
port = "80"
# eu-west-2         = London
# ap-southeast-2    = Sydney
region = "eu-west-2"
ssh_key_name = "default"
ssh_private_key_path = "~/.ssh/default"
ssh_public_key_path = "~/.ssh/default.pub"
client_key_output_path = "~/Desktop/client.ovpn"

images = {
    "eu-west-2" = "ami-fcc4db98"
    "ap-southeast-2" = "ami-33ab5251"
}
