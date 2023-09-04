FROM python:3

WORKDIR /app/

RUN git clone https://github.com/NickBorgers/node-red.git

COPY requirements.txt /app/
RUN pip install -r /app/requirements.txt

COPY server.py /app/server.py
COPY static /app/static

CMD python -u server.py
