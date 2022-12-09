FROM ubuntu:jammy-20221130

RUN apt update && apt install -y python3 python3-pip yamllint

COPY requirements.txt /app/requirements.txt

COPY validate_spotify_uris.py /app/validate_spotify_uris.py

WORKDIR /app/

RUN pip install -r requirements.txt