# bigcat - terraform templates

## simple-tf
Template to deploy a single EC2 t2.micro instance to the AWS Frankfurt Region

## vpn-tf
Terraform script to deploy an openvpn server to one of 3 regions, build a CA and SCP client .ovpn files back to the user. Automates the deployment of a private VPN server in one easy step

```sh
# plan and deploy the instance. 
terraform plan -var 'region=eu-west-2'
terraform apply -var 'region=eu-west-2'
# set the destination for the config file in terraform.tfvars, pass as an argument or use the default
# connect to your vpn
openvpn --config client.ovpn
terraform destroy -var 'region=eu-west-2'
```
