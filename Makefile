.PHONY: setup-localstack destroy-localstack

clean-terraform:
	find . -name ".terraform" -type d -exec rm -rf {} +
	find . -name ".terraform.lock.hcl" -type f -exec rm -f {} +
	find . -name "terraform.tfstate" -type f -exec rm -f {} +
	find . -name "terraform.tfstate.backup" -type f -exec rm -f {} +

# Commands for setting up localstack and deploying global infra
setup-localstack:
	docker-compose -f localstack/docker-compose.yml up -d

destroy-localstack:
	docker-compose -f localstack/docker-compose.yml down

deploy-global-infra:
	cd global-infra/terraform && terraform init && terraform apply -var="use_localstack=true" -auto-approve

destroy-global-infra:
	cd global-infra/terraform && terraform destroy -auto-approve

# Command to deploy a specific microservice's infrastructure
deploy-service-infra:
	@if [ -z "$$1" ]; then \
		echo "Service name is not provided"; \
		exit 1; \
	fi
	cd microservices/$$1/infra/terraform && terraform init && terraform apply -var="use_localstack=true" -auto-approve

# Command to deploy all microservices' infrastructure
deploy-all-services:
	for dir in $(shell ls -d microservices/*/infra/terraform); do \
		SERVICE=$$(basename $$(dirname $$dir)); \
		make deploy-service-infra SERVICE=$$SERVICE; \
	done