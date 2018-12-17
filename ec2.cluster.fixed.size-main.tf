
/*
 | --
 | -- This ec2 instance resource creates a fixed size cluster containing
 | -- anything from 1 to n nodes.
 | --
 | -- This implements the middle of the 3 layered cluster architecture.
 | -- This cluster layer is concerned with instance types, storage sizes
 | -- and the underlying machine images.
 | --
 | -- This middle layer accepts user data configuration from the systemd
 | -- services layer and network concerns like subnet IDs and security
 | -- groups from the network layer.
 | --
 | -- We hardcode an outgoing routing dependency to enforce its precedence
 | -- over instance creation within private subnets.
 | --
*/
resource aws_instance nodes
{
    count = "${var.in_node_count}"
    key_name = "${ element( aws_key_pair.ssh.*.id, 0 ) }"

    instance_type          = "${ var.in_instance_type }"
    ami                    = "${ var.in_ami_id }"
    subnet_id              = "${ element( var.in_subnet_ids, count.index ) }"
    user_data              = "${ var.in_user_data }"
    vpc_security_group_ids = [ "${ var.in_security_group_ids }" ]

    tags
    {
        Name     = "ec2-${ var.in_ecosystem_name }-${ var.in_tag_timestamp }-${ ( count.index + 1 ) }"
        Class    = "${ var.in_ecosystem_name }"
        Instance = "${ var.in_ecosystem_name }-${ var.in_tag_timestamp }"
        Desc     = "This cluster node no.${ ( count.index + 1 ) } of ${ var.in_node_count } for ${ var.in_ecosystem_name } ${ var.in_tag_description }"
        Routing  = "This ec2 instance can connect externally through route ${ element( var.in_route_dependency, count.index ) } that serves subnet ${ element( var.in_subnet_ids, count.index ) }."
    }
}


/*
 | --
 | -- This bastion host can be used when one needs to get to those
 | -- hard to reach finnickety instances in private subnets.
 | --
 | --   1. replace <<public-ip>> with the bastion's PUBLIC IP address or DNS name
 | --   2. replace <<private-ip>> with the node's PRIVATE IP address or DNS name
 | --
 | --    scp -C -i bastion-private-key.pem bastion-private-key.pem core@<<public-ip>>:~/bastion-private-key.pem
 | --    ssh core@<<public-ip>> -i bastion-private-key.pem
 | --    ssh core@<<private-ip>> -i bastion-private-key.pem
 | --
 | --
*/
resource aws_instance bastion
{
    count = "${ signum( length( var.in_ssh_public_key ) ) }"
    key_name = "${ element( aws_key_pair.ssh.*.id, 0 ) }"

    instance_type          = "${ var.in_instance_type }"
    ami                    = "${ var.in_ami_id }"
    subnet_id              = "${ var.in_bastion_subnet_id }"
    vpc_security_group_ids = [ "${ var.in_security_group_ids }" ]

    tags
    {
        Name     = "bastion-ec2-${ var.in_ecosystem_name }-${ var.in_tag_timestamp }"
        Class    = "${ var.in_ecosystem_name }"
        Instance = "${ var.in_ecosystem_name }-${ var.in_tag_timestamp }"
        Desc     = "This bastion instance that can contact ${ var.in_node_count } nodes ${ var.in_tag_description }"
    }
}


resource aws_key_pair ssh
{
    count = "${ signum( length( var.in_ssh_public_key ) ) }"
    key_name = "key-4-${ var.in_ecosystem_name }-${ var.in_tag_timestamp }"
    public_key = "${ var.in_ssh_public_key }"
}
