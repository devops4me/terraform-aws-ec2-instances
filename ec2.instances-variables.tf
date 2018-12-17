
### ###################################################### ###
### [[fixed-size-ec2-cluster-module]] Input Variables List ###
### ###################################################### ###


### ########################## ###
### [[variable]] in_node_count ###
### ########################## ###

variable in_node_count
{
    description = "The number of nodes that this fixed size ec2 instance cluster should bring up."
    default     = "4"
}

### ######### ###
### in_ami_id ###
### ######### ###

variable in_ami_id
{
    description = "The ID of the EC2 machine image (AMI) that each instance will boot up from."
}


### ############ ###
### in_user_data ###
### ############ ###

variable in_user_data
{
    description = "The body of text responsible for bootrapping the node."
}


### ############################# ###
### [[variable]] in_instance_type ###
### ############################# ###

variable "in_instance_type"
{
    description = "The ec2 instance type (default is t2.medium) that will make up the fixed size ec2 cluster nodes."
    default = "t2.medium"
}


### ############# ###
### in_subnet_ids ###
### ############# ###

variable in_subnet_ids
{
    description = "The list of subnet IDs each instance will join using modulus wrap-round arithmetic."
    type        = "list"
}


### ##################### ###
### in_security_group_ids ###
### ##################### ###

variable in_security_group_ids
{
    description = "The identifiers of the (usually 1) security group that the nodes will identify with."
    type        = "list"
}


### ################# ###
### in_ecosystem_name ###
### ################# ###

variable in_ecosystem_name
{
    description = "Creational stamp binding all infrastructure components created on behalf of this ecosystem instance."
}


### ################ ###
### in_tag_timestamp ###
### ################ ###

variable in_tag_timestamp
{
    description = "A timestamp for resource tags in the format ymmdd-hhmm like 80911-1435"
}


### ################## ###
### in_tag_description ###
### ################## ###

variable in_tag_description
{
    description = "Ubiquitous note detailing who, when, where and why for every infrastructure component."
}


/*
 | --
 | -- IMPORTANT - DO NOT LET TERRAFORM BRING UP EC2 INSTANCES INSIDE PRIVATE
 | -- SUBNETS BEFORE (SLOW TO CREATE) NAT GATEWAYS ARE UP AND RUNNING.
 | --
 | -- Suppose systemd on bootup wants to get a rabbitmq docker image as
 | -- specified by a service unit file. Terraform will quickly bring up ec2
 | -- instances and then proceed to slowly create NAT gateways. To avoid
 | -- these types of bootup errors we must declare explicit dependencies to
 | -- delay ec2 creation until the private gateways and routes are ready.
 | --
*/
variable in_route_dependency
{
    description = "Aids creation of explicit dependency for instances brought up in private subnets."
    type        = "list"
    default     = [ "xxxxxx" ]
}


#########################################################
############## ++++++++++++++++++++++++++ ###############
############## Troubleshoot-ing Variables ###############
############## ++++++++++++++++++++++++++ ###############


### #################### ###
### in_bastion_subnet_id ###
### #################### ###

variable in_bastion_subnet_id
{
    description = "The public subnet into which to create the bastion host."
    default = ""
}


### ################# ###
### in_ssh_public_key ###
### ################# ###

variable in_ssh_public_key
{
    description = "The public key for accessing both the DMZ bastion and the nodes behind enemy lines."
    default = ""
}


