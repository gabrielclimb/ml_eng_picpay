# Criando uma layer para lambda
Para criar uma layer para as lambdas é necessário zipar as dependencias do script:

```bash
mkdir python
pip install -r requirements.txt -t python

# remover arquivos e pastas não necessários.
find . -type d -name 'tests' -prune -exec rm -rf {} \;
find . -type d -name '__pycache__' -prune -exec rm -rf {} \;
find . -type d -name '*-info' -prune -exec rm -rf {} \;
find python -name \*.txt -delete

# zipar as dependências.
zip -qr python.zip python
rm -r python  
```