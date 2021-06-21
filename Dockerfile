FROM python:3.9-alpine

RUN mkdir -p /opt
WORKDIR /opt

RUN apk add --no-cache bash postgresql-client
RUN pip install awscli

COPY run_backup.sh /opt/
COPY extract_db_params_from_env.py  /opt/
ENTRYPOINT ["/bin/bash", "./run_backup.sh"]
