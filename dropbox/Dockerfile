FROM python:3.9-alpine

RUN mkdir -p /opt
WORKDIR /opt

RUN apk add --no-cache bash postgresql-client gnupg curl
RUN pip install dropbox

COPY run_backup.sh /opt/
COPY extract_db_params_from_env.py  /opt/
COPY upload.py  /opt/

CMD ["/bin/bash", "./run_backup.sh"]
