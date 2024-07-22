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

deploy-service-infra:
	@if [ -z "$(service)" ]; then \
		echo "Service name is not provided"; \
		exit 1; \
	fi
	cd microservices/$(service)/terraform && terraform init && terraform apply -auto-approve

zip:
	cd microservices/order-processing/src && zip index.zip index.js