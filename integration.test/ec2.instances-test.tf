

locals
{
    ecosystem_name = "instance-cluster"
    node_count     = 5
}


module instance-cluster
{
    source                 = ".."

    in_node_count         = "${ local.node_count }"
    in_ami_id             = "${ module.coreos-ami-id.out_ami_id }"
    in_subnet_ids         = "${ module.vpc-network.out_public_subnet_ids }"
    in_security_group_ids = [ "${ module.security-group.out_security_group_id }" ]
    in_user_data          = "${ module.rabbitmq-cloud-config.out_ignition_config }"
    in_ssh_public_key     = "${ tls_private_key.generated.public_key_openssh }"

    in_ecosystem_name     = "${ local.ecosystem_name }"
    in_tag_timestamp      = "${ module.resource-tags.out_tag_timestamp }"
    in_tag_description    = "${ module.resource-tags.out_tag_description }"
}


/*
 | -- This generated private key will be ejected into the state file.
 | -- For long lived scenarios a better strategy is to pass in public
 | -- keys that have their private counterpart secured.
 | --
*/
resource tls_private_key generated
{
    algorithm   = "ECDSA"
    ecdsa_curve = "P521"
}


module rabbitmq-cloud-config
{
    source        = "github.com/devops4me/rabbitmq-systemd-cloud-config"
    in_node_count = "${ local.node_count }"
}


/*
 | --
 | -- This module creates a VPC and then allocates subnets in a round robin manner
 | -- to each availability zone. For example if 8 subnets are required in a region
 | -- that has 3 availability zones - 2 zones will hold 3 subnets and the 3rd two.
 | --
 | -- Whenever and wherever public subnets are specified, this module knows to create
 | -- an internet gateway and a route out to the net.
 | --
*/
module vpc-network
{
    source                 = "github.com/devops4me/terraform-aws-vpc-network"
    in_vpc_cidr            = "10.66.0.0/16"
    in_num_public_subnets  = 3
    in_num_private_subnets = 0

    in_ecosystem_name     = "${ local.ecosystem_name }"
    in_tag_timestamp      = "${ module.resource-tags.out_tag_timestamp }"
    in_tag_description    = "${ module.resource-tags.out_tag_description }"
}


/*
 | --
 | -- The security group needs to allow ssh for troubleshooting logins
 | -- and http plus https to test the load balancers viability against
 | -- a fleet of web servers.
 | --
*/
module security-group
{
    source       = "github.com/devops4me/terraform-aws-security-group"
    in_ingress   = [ "rmq-admin" ]
    in_vpc_id    = "${ module.vpc-network.out_vpc_id }"

    in_ecosystem_name     = "${ local.ecosystem_name }"
    in_tag_timestamp      = "${ module.resource-tags.out_tag_timestamp }"
    in_tag_description    = "${ module.resource-tags.out_tag_description }"
}


/*
 | --
 | -- This module dynamically acquires the HVM CoreOS AMI ID for the region that
 | -- this infrastructure is built in (specified by the AWS credentials in play).
 | --
*/
module coreos-ami-id
{
    source = "github.com/devops4me/terraform-aws-coreos-ami-id"
}


module resource-tags
{
    source = "github.com/devops4me/terraform-aws-resource-tags"
}


### ##################################### ###
### [ outputs ] fixed size cluster module ###
### ##################################### ###

output out_rmq_password
{
    value = "${ module.rabbitmq-cloud-config.out_rmq_password }"
}

output out_public_ip_addresses
{
    value = "${ module.instance-cluster.out_public_ip_addresses }"
}

output out_private_ip_addresses
{
    value = "${ module.instance-cluster.out_private_ip_addresses }"
}
