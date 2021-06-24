# Makefile
.PHONY: help
help:
	@echo "Comandos:"
	@echo "venv         : Cria o ambiente virtual com as libs necessárias"
	@echo "test         : Testa o código da lambda."
	@echo "aws_variables: Checa se as variáveis de ambiente da AWS foram definidas."
	@echo "terraform    : Roda o commando terraform apply."
	@echo "deploy_infra : Roda o teste das lambdas, o aws_variable e o terraform apply"
	@echo "retrain      : Roda o retreino do modelo coletando os dado via athena e s3"
	@echo "serve        : Serve o modelo localmente usando o bentoml"
	@echo "serve_docker : Serve o modelo localmente usando o docker"
	@echo "deploy_model : Faz o deploy do modelo em uma lambda na aws"

# Environment
.ONESHELL:
venv:
	@echo "Criando ambiente virtual"
	@python3 -m venv venv && \
	source venv/bin/activate && \
	pip install --upgrade pip && \
	pip install -r requirements.txt

# Test
.PHONY: test
test:
	@( \
		source venv/bin/activate ; \
		pytest lambdas/ ; \
	)

.PHONY: check_aws
check_aws: 
	@bash -c 'if [ -z ${AWS_ACCESS_KEY_ID} ]; then erro echo "AWS_ACCESS_KEY_ID não foi definida"   ; else echo "AWS_ACCESS_KEY_ID = '$(AWS_ACCESS_KEY_ID)'"; fi'
	@bash -c 'if [ -z ${AWS_SECRET_ACCESS_KEY} ]; then echo "AWS_SECRET_ACCESS_KEY não foi definida"; else echo "AWS_SECRET_ACCESS_KEY = '$(AWS_SECRET_ACCESS_KEY)'"; fi'
	@bash -c 'if [ -z ${AWS_DEFAULT_REGION} ]; then echo "AWS_DEFAULT_REGION não foi definida" ; else echo "AWS_DEFAULT_REGION = '$(AWS_DEFAULT_REGION)'"; fi'

.PHONY: terraform
terraform: 
	@terraform init
	@terraform apply

.PHONY: deploy_infra
deploy_infra: test check_aws terraform

.PHONY: retrain
retrain:
	@echo "Começando o retreino do modelo"

	@source venv/bin/activate && \
	python3 model/retrain.py --version $(version)

.PHONY: serve
serve:
	@source venv/bin/activate && \
	bentoml serve BeerPredictionService:$(version)

.PHONY: serve_docker
serve_docker:
	@docker run -p 5000:5000 gabrielclimb/picpay-ibu-predict:v1

.PHONY: deploy_model
deploy_model:
	@source venv/bin/activate && \
	bentoml ec2 deploy ibu-model-deployment -b BeerPredictionService:$(version)
