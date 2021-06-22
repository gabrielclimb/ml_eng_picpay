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
	@echo "serve        : Serve o modelo localmente"
	@echo "deploy_model : Faz o deploy do modelo em uma lambda na aws"


# Environment
.ONESHELL:
venv:
	python -m venv venv && \
	source venv/bin/activate && \
	pip install --upgrade pip && \
	pip install -r requirements.txt

clean:
	find . -type f -name '*.pyc' -delete

# Test
.PHONY: test
test:
	@( \
		source venv/bin/activate ; \
		pytest lambdas/ ; \
	)

.PHONY: aws_variables
aws_variables_check: 
	@bash -c 'if [ -z ${AWS_ACCESS_KEY_ID} ]; then erro echo "AWS_ACCESS_KEY_ID não foi definida"   ; else echo "AWS_ACCESS_KEY_ID = '$(AWS_ACCESS_KEY_ID)'"; fi'
	@bash -c 'if [ -z ${AWS_SECRET_ACCESS_KEY} ]; then echo "AWS_SECRET_ACCESS_KEY não foi definida"; else echo "AWS_SECRET_ACCESS_KEY = '$(AWS_SECRET_ACCESS_KEY)'"; fi'
	@bash -c 'if [ -z ${AWS_DEFAULT_REGION} ]; then echo "AWS_DEFAULT_REGION não foi definida" ; else echo "AWS_DEFAULT_REGION = '$(AWS_DEFAULT_REGION)'"; fi'

.PHONY: terraform
terraform: 
	@terraform init
	@terraform apply

.PHONY: deploy_infra
deploy_infra: test aws_variables_check terraform

.PHONY: retrain
retrain:
	@echo "Começando o retreino do modelo"
	@source venv/bin/activate && \
	python model/serving/retrain.py --version $(version)

.PHONY: serve
serve:
	@source venv/bin/activate && \
	bentoml serve BeerPredictionService:v1

.PHONY: deploy_model
deploy_model:
	@sudo sh variables.sh
	bentoml lambda deploy my-first-lambda-deployment -b BeerPredictionService:v1
