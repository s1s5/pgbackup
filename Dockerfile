FROM python:3.12-alpine

RUN mkdir -p /opt
WORKDIR /opt

RUN apk add --no-cache bash postgresql-client gnupg curl
RUN pip install awscli

COPY run_backup.sh /opt/
COPY extract_db_params_from_env.py  /opt/

CMD ["/bin/bash", "./run_backup.sh"]
