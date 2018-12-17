
################ ################################################## ########
################ Module [[[security group]]] Output Variables List. ########
################ ################################################## ########

### ################################## ###
### [[output]] out_public_ip_addresses ###
### ################################## ###

output out_public_ip_addresses
{
    value = "${ aws_instance.nodes.*.public_ip }"
}


### ################################### ###
### [[output]] out_private_ip_addresses ###
### ################################### ###

output out_private_ip_addresses
{
    value = "${ aws_instance.nodes.*.private_ip }"
}
