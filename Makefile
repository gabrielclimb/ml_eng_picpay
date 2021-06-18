mkdir libs
pip install -r app/requirements.txt -t libs
zip -qr libs.zip libs
zip app/app.zip app/app.py
rm -r libs