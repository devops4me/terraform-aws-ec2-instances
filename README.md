
# Create One or More EC2 Instances

This reusable module **creates a fixed number of ec2 instances** as opposed to its sister module that creates an **auto-scaling ec2 instance cluster**. Like its sister, you need to tell this module
- which AMI to use
- the instance profiles that allow access to AWS resources
- the SSH public key for accessing the instance
- the user data that will bootstrap the waking instance
- the public/private subnets (hence zones) each instance is in
- the security groups to constrain ingress and egress traffic


## Module Usage

    module ec2-instances
    {
        source  = "devops4me/ec2-instances/aws"
        version = "~> 1.0.0"

        in_vpc_cidr            = "10.245.0.0/16"
        in_num_private_subnets = 6
        in_num_public_subnets  = 3
    }


---


## Module Inputs

| Input Variable             | Type    | Description                                                   | Default        |
|:-------------------------- |:-------:|:------------------------------------------------------------- |:--------------:|
| **`in_vpc_cidr`**          | string  | The VPC's Cidr defining the range of available IP addresses   | 10.42.0.0/16   |
| **`in_num_private_subnets`** | number | Number of private subnets to create across availability zones | 3              |
| **`in_num_public_subnets`**  | number | Number of public subnets to create across availability zones. If one or more an internet gateway and route to the internet will be created regardless of the value of the in_create_gateway boolean variable. | 3 |
| **`in_create_public_gateway`** | bool | if true create an internet gateway and routes so services can access the internet. | true |
| **`in_create_private_gateway`** | bool | if true creates a NAT gateway and private routes for egress access from private subnets. | true |
| **`in_subnets_max`** | number | 2 to the power of this is the [max number of carvable subnets](https://www.devopswiki.co.uk/vpc/network-cidr) So 2<sup>4</sup> = 16 subnets | 4 |


### Optional Resource Tag Inputs

Most organisations have a mandatory set of tags that must be placed on AWS resources for cost and billing reports. Typically they denote owners and specify whether environments are prod or non-prod.

| Input Variable    | Variable Description | Input Example
|:----------------- |:-------------------- |:----- |
**`in_ecosystem`** | the ecosystem (environment) name these resources belong to | **`my-app-test`** or **`kubernetes-cluster`**
**`in_timestamp`** | the timestamp in resource names helps you identify which environment instance resources belong to | **`1911021435`** as **`$(date +%y%m%d%H%M%S)`**
**`in_description`** | a human readable description usually stating who is creating the resource and when and where | "was created by $USER@$HOSTNAME on $(date)."

Try **`echo $(date +%y%m%d%H%M%S)`** to check your timestamp and **`echo "was created by $USER@$HOSTNAME on $(date)."`** to check your description. Here is how you can send these values to terraform.

```
export TF_VAR_in_timestamp=$(date +%y%m%d%H%M%S)
export TF_VAR_in_description="was created by $USER@$HOSTNAME on $(date)."
```


---


## output variables

Here are the most popular **output variables** exported from this VPC and subnet creating module.

| Exported | Type | Example | Comment |
|:-------- |:---- |:------- |:------- |
**`out_vpc_id`** | String | vpc-1234567890 | the **VPC id** of the just-created VPC
**`out_rtb_id`** | String | "rtb-2468013579" | ID of the VPC's default route table
**`out_subnet_ids`** | List of Strings | [ "subnet-545123498798345", "subnet-83507325124987" ] | list of **all private and public** subnet ids
**`out_private_subnet_ids`** | List of Strings | [ "subnet-545123498798345", "subnet-83507325124987" ] | list of **private** subnet ids
**`out_public_subnet_ids`** | List of Strings |  [ "subnet-945873408204034", "subnet-8940202943031" ] | list of **public** subnet ids


---


## Architecture | The 3 Layers of a Cluster

Use **ignition** to bootstrap and configure this ec2 instance cluster so that your infrastructure code **separates the following concerns**

- VPCs, subnets, security groups, routes and load balancers **to build the network**
- either a **fixed size** or auto-scaling modus operandi **to build the cluster**
- **systemd unit files** given to ignition **to build the node** with microservices

### Why separate the concerns I hear you ask?

The infrastructure that devops4me presents **delineates the network** configuration **from the clustering** mechanism, **from the node's dockerized microservices** configuration c/o the systemd unit files.

This separation of concerns enables you to

- reuse the **[network code](https://github.com/devops4me/terraform-aws-vpc-network)** in a serverless architecture like EKS, RDS or AWS Elasticsearch
- **reuse this ec2 clusterer** for **etcd clusters**, **rabbitmq clusters** or even **jenkins clusters**
- **reuse the systemd unit files** without being tied down to an instance type, storage size, AMI or even cloud!
