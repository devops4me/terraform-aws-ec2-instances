
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
resource aws_instance nodes {

    count = var.in_node_count

    user_data              = var.in_user_data
    iam_instance_profile   = var.in_iam_instance_profile
    key_name               = aws_key_pair.ssh.id

    ami                    = var.in_ami_id
    subnet_id              = element( var.in_subnet_ids, count.index )
    vpc_security_group_ids = [ var.in_security_group_ids ]
    instance_type          = var.in_instance_type

    tags
    {
        Name     = "ec2-${ var.in_ecosystem_name }-${ var.in_tag_timestamp }-${ ( count.index + 1 ) }"
        Class    = var.in_ecosystem_name
        Instance = "${ var.in_ecosystem_name }-${ var.in_tag_timestamp }"
        Desc     = "This cluster node no.${ ( count.index + 1 ) } of ${ var.in_node_count } for ${ var.in_ecosystem_name } ${ var.in_tag_description }"
        Depend   = "Either default or actual dependency to ensure the instance is created after NAT gateway ${ element( var.in_route_dependency, count.index ) } in subnet ${ element( var.in_subnet_ids, count.index ) }."
    }
}


/*
 | -- It is recommended that you pass in a SSH public key through
 | -- an environment variable named TF_VAR_in_ssh_public_key
 | --
 | -- The environment variable shields the public key contents
 | -- from the public repository.
 | --
*/
resource aws_key_pair ssh {

    key_name = "key-4-${ var.in_ecosystem_name }-${ var.in_tag_timestamp }"
    public_key = var.in_ssh_public_key
}
