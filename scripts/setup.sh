#!/bin/bash

apt-get update && apt-get install -y \
    python3.10 python3.10-venv python3-pip \
    nodejs \
    npm

    npm install pm2 -g