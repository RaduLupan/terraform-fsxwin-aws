# terraform-fsxwin-aws
This repository contains Terraform configurations that deploy an [Amazon FSx for Windows File Server](https://docs.aws.amazon.com/fsx/latest/WindowsGuide/what-is.html) and an associated Windows EC2 instance used for configuring the FSx file system.

## Prerequisites
* [Amazon Web Services (AWS) account](http://aws.amazon.com/).
* Terraform 0.14 installed on your computer. Check out HasiCorp [documentation]([https://learn.hashicorp.com/terraform/azure/install](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)) on how to install Terraform.

## Quick start

1. Configure your [AWS access 
keys](http://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) as 
environment variables:

```
$ export AWS_ACCESS_KEY_ID=(your access key id)
$ export AWS_SECRET_ACCESS_KEY=(your secret access key)
```

2. Clone this repository:

```
$ git clone https://github.com/RaduLupan/terraform-fsxwin-aws.git
$ cd terraform-fsxwin-aws
```
3. Deploy Amazon FSx for Windows File Server:

```
$ cd deploy
$ terraform init
$ terraform apply
```
4. Deploy an AD domain-joined EC2 instance to use for configuring the FSx file system:

```
$ cd configure
$ terraform init
$ terraform apply
```

## Resources
[Best Practices for Administering Amazon FSx File Systems](https://docs.aws.amazon.com/fsx/latest/WindowsGuide/admin-best-practices-fsxw.html)
