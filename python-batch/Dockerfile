FROM python:3.6-slim

ARG WEBHOOK_URL="Undefined"
ENV WEBHOOK_URL $WEBHOOK_URL
ARG BUCKET_NAME="Undefined"
ENV BUCKET_NAME $BUCKET_NAME

COPY script .
RUN pip install -r requirements.txt

RUN chmod +x ./entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]
