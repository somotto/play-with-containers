#!/bin/bash
cd $APP_PATH
python3 -m venv venv
source ./venv/bin/activate
pip install --no-cache-dir -r requirements.txt
pm2 start server.py --interpreter python3
