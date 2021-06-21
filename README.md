# Machine Learning Engineer - PicPay
Teste para Ml. Eng. no PicPay

![Diagrama](figuras/Diagrama.png)

O Projeto foi separado em 4 partes

1. Ingestão de dados
2. Data Lake
3. Disponibilização dos dados (Consulta)
4. Produtiza (Treino e Modelo em produçao)

Para a construção das partes 1, 2 e 3 utilizei o `terraform` e para o deploy do modelo em lambda utilizei o framework [bentoml](https://docs.bentoml.org/en/latest/)


O projeto consiste em coletar os dados da PunkAPI, que é uma api com informações de cerveja da cervejaria BrewDog. Após a coleta dos dados, ele é enviado, via lambda, ao Kinesis que distribui esses dados em dois seguimentos:, 
 - Raw: Utilizando o Kinesis Firehose, o dado é armazenado no S3, no bucket `raw`, no mesmo estado que foi coletado (dado cru).
 - Cleaned: Utilizando o Kinesis Firehose e uma lambda, o dado capturado é manipulado, deixando somente as informações de id,
name, abv, ibu, target_fg, target_og, ebc, srm e ph das cervejas e salvo no S3, no bucket `cleaned`. Para esse bucket é também criado uma tabela para que os dados sejam acessados, isso é feito utilizando o Glue Crawler e o Glue Data Catalog.

Com a tabela criada, leio os dados da tabela e treino o modelo para inferir o IBU de uma cerveja baseado nos dados que a api fornece (`name`, `abv`, `ibu`, `target_fg`, `target_og`, `ebc`, `srm`, `ph`)
***
## Estrura de pastas

```

├── docs
│   └── desafio_-_machine_learning_platform_engineer.pdf
├── figuras
├── lambdas
│   ├── lambda_databeer_transformation
│   └── lambda_punkapi
├── main.tf
├── model
│   ├── bentoml
│   ├── imagens
│   ├── model.ipynb
│   ├── serving
│   └── utils
├── requirements.txt
├── terraform
│   ├── README.md
│   ├── consulta
│   ├── ingestao_dados
│   └── lake
├── terraform.tfstate
├── terraform.tfstate.backup
└── variables.sh
```
- **lambdas**: 
- **model**: Tudo relacionado ao modelo está nessa pasta. O notebook utilizado para o desenvolvimento é o arquivo `model.ipynb`.
    - *bentoml*: Todos os arquivos necessários para deploy do modelo em lambda utilizando o bentoml.
    - *serving*:
    - *utils* : Módulo com funções em python uteis ao modelo.
- **terraform**: Todo o código terraform do projeto está nessa pasta, separado segundo o diagrama apresentado:
    - *consulta*: Códgio que cria toda a estrutura de tabelas no glue
    - *ingestao_dados*: Código que cria a parte do CloudWatch Event e da lambda de ingestão
    - *lake*: Código para o Kinesis, Kinesis Firehose, Lambda e S3  


***

## Como utilizar esse repositório.

Primeiro, você deve definir algumas variáveis de ambiente.

```bash
export BENTOML_HOME="model/bentoml"
export AWS_ACCESS_KEY_ID="<sua acess key aws>"
export AWS_SECRET_ACCESS_KEY="<sua secret acess key aws>"
export AWS_DEFAULT_REGION="<sua region aws>"
```

Com as variáveis definidas, podemos iniciar o deploy da aplicação.

Para isso vamos usar uma arquivo `Makefile` para tornar o processo mais simples.

Você pode ver o que cada função do `Makefile` faz rodando `make help`, mas o processo será:

1. `make venv` 
2. `make deploy_infra`
3. `make deploy_model`
***
### Acessos na AWS
Para poder executar o projeto de forma correta, é preciso ter acesso aos seguintes serviços:
- Kinesis
- KinesisFirehose
- S3
- Glue
- IAM
- CloudWatch
- Lambda
***

## Teste Local do Modelo

É possivel testar a api do modelo localmente, para isso, execute o seguinte comando:

```bash
make serve
```
Um servidor local irá export um URL para acessar o Swagger/OpenAPI.
![Diagrama](figuras/Swagger.png)

No endpoint predict há um exemplo de como fazer o request.
