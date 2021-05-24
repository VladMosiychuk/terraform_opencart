# Terraform Opencart

This project was made in SoftServe Academy during DevOps Course.

## Prerequirements

To run this project yourself you need to install Docker, Docker Compose, AWS CLI and Terraform.

### Installation tutorials listed below.
- [Docker](https://docs.docker.com/engine/install/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

P.S. Don't forget to [configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) your AWS CLI.

## Step 1: Create `.env` file in root directory

Use `.env.example` as a refference. 

```bash
MYSQL_ROOT_PASSWORD=YOUR_ROOT_PASSWORD
MYSQL_DATABASE=OPENCART_DB_NAME
MYSQL_USER=OPENCART_DB_USER
MYSQL_PASSWORD=OPENCAER_DB_PASSWORD
```

## Step 2: Build images using docker compose

```bash
>> docker-compose build
```

After build is done verify that images are created successfully.

```bash
>> docker images

REPOSITORY            TAG       IMAGE ID       CREATED         SIZE
opencart              0.1       28c64ccca3ef   7 seconds ago   444MB
mymysql               0.1       c6e860ae4835   4 minutes ago   562MB
```

## Step 3: Run deploy script

It will create new repositories for Opencart and MySQL and upload images created on previous step to ECR.  

```bash
>> bash deploy.sh
```

## Step 4: Create `terraform.tfvars` file in `aws` folder

Use `terraform.tfvars.example` as a refference.

```bash
aws_region = "us-east-1"
aws_availability_zone = "us-east-1a"
aws_access_key = "INSERT YOUR ACCESS KEY HERE"
aws_secret_key = "INSERT YOU SECRET KEY HERE"
```

## Step 5: Initialize Terraform and Create Infrastucture

```bash
>> terraform init
>> terraform apply
```

## Congratulations! Your Opencart store is Up & Running on AWS!

To find out Public IP of Opencart run `get_ip.sh` 

```bash
>> bash get_ip.sh
Your Public IP is: XXX.XXX.XXX.XXX
```

## Step 6: Destroy your infrastructure

```bash
>> terraform destroy
>> bash destructor.sh
```
