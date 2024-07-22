# OMS (Order Management System)

## Local Development Environment Setup

This section explains how to set up and use the local development environment for working with infrastructure and services. The provided `Makefile` includes various commands to manage the local stack and service infrastructure.

### Prerequisites

- Docker
- Docker Compose
- Terraform
- AWS CLI

### General Commands

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


### Services commands
#### Localstack healthcheck
```sh
http://localhost:4566/_localstack/health
```

#### API Gateway
How to get the gateway endpoint:
```sh
aws --endpoint-url=http://localhost:4566 --region eu-central-1 events describe-event-bus
```

This will return the event buses list with their name and ARN. We can use the EventBridge endpoint configured for Localstack in `provider.tf`, and append the ARN.

```sh
http://eventbridge.localhost.localstack.cloud:4566/arn:aws:events:eu-central-1:000000000000:event-bus/default
```

To be able to send events to EventBridge we can use Postman configured with the following headers:
| Header         | Value                       |
|----------------|-----------------------------|
| Content-Type   | `application/x-amz-json-1.1`|
| X-Amz-Target   | `AWSEvents.PutEvents`       |
| X-Amz-Date     | `<AWS Date>`                |

As Authorization method we will use `AWS Signature`.

#### SQS
```sh
aws --endpoint-url=http://sqs.localhost.localstack.cloud:4566 sqs list-queues
```

#### Lambda
```sh
aws --endpoint-url=http://lambda.localhost.localstack.cloud:4566 lambda list-functions
```

#### DynamoDB
