# ec2 instance cluster | fixed size

This reusable module **creates a fixed number of ec2 instances** as opposed to its sister module that creates an **auto-scaling ec2 instance cluster**. Like its sister, you need to tell this module which AMI to use and also give it the user data necessary to boostrap each node.


## Usage

## Module Inputs

## Module Outputs

## Ignition User Data Input Example

Ignition config is in JSON format and is not designed to be human readable. This example demonstrates how the terraform ignition provider reads the systemd unit files and then **transpiles it** to the JSON code below which is passed into the **user data input variable** in this module.

### The SystemD Unit File

```ini
[Unit]
Description=Sets up the inbuilt CoreOS etcd 3 key value store
Requires=coreos-metadata.service
After=coreos-metadata.service

[Service]
EnvironmentFile=/run/metadata/coreos
ExecStart=/usr/lib/coreos/etcd-wrapper $ETCD_OPTS \
  --listen-peer-urls="http://$${COREOS_EC2_IPV4_LOCAL}:2380" \
  --listen-client-urls="http://0.0.0.0:2379" \
  --initial-advertise-peer-urls="http://$${COREOS_EC2_IPV4_LOCAL}:2380" \
  --advertise-client-urls="http://$${COREOS_EC2_IPV4_LOCAL}:2379" \
  --discovery="${file_discovery_url}"
```

### The Transpiled Ignition Configuration

```json
{
   "ignition":{
      "config":{

      },
      "timeouts":{

      },
      "version":"2.1.0"
   },
   "networkd":{

   },
   "passwd":{

   },
   "storage":{

   },
   "systemd":{
      "units":[
         {
            "dropins":[
               {
                  "contents":"[Unit]\nDescription=Sets up the inbuilt CoreOS etcd 3 key value store\nRequires=coreos-metadata.service\nAfter=coreos-metadata.service\n\n[Service]\nEnvironmentFile=/run/metadata/coreos\nExecStart=\nExecStart=/usr/lib/coreos/etcd-wrapper $ETCD_OPTS \\\n  --listen-peer-urls=\"http://${COREOS_EC2_IPV4_LOCAL}:2380\" \\\n  --listen-client-urls=\"http://0.0.0.0:2379\" \\\n  --initial-advertise-peer-urls=\"http://${COREOS_EC2_IPV4_LOCAL}:2380\" \\\n  --advertise-client-urls=\"http://${COREOS_EC2_IPV4_LOCAL}:2379\" \\\n  --discovery=\"https://discovery.etcd.io/93d2817eddad15fe6ba844e292e5c11a\"\n",
                  "name":"20-clct-etcd-member.conf"
               }
            ],
            "enabled":true,
            "name":"etcd-member.service"
         }
      ]
   }
}
```

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
