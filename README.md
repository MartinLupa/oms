# OMS (Order Management System)

## Local Development Environment Setup

This section explains how to set up and use the local development environment for working with infrastructure and services. The provided `Makefile` includes various commands to manage the local stack and service infrastructure.

### Prerequisites

- Docker
- Docker Compose
- Terraform
- AWS CLI

### Commands

#### Setup LocalStack

To start LocalStack, which simulates AWS services locally, use the following command:

```sh
make setup-localstack
```
This command will start LocalStack using Docker Compose. LocalStack will be available at http://localhost:4566.


#### Destroy LocalStack
```sh
make destroy-localstack
```
This command will bring down the LocalStack Docker containers.

#### Using AWS CLI with LocalStack
You can leverage the AWS CLI to interact with the simulated AWS services provided by LocalStack. For example, to list DynamoDB tables, use:

```sh
aws --endpoint-url=<service_endpoint> <aws_service_name> <aws_service_specific_command>

# Example:
aws --endpoint-url=http://s3.localhost.localstack.cloud:4566 s3 ls
```

