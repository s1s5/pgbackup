#!/bin/bash
# -*- mode: shell-script -*-

set -eu  # <= 0以外が返るものがあったら止まる, 未定義の変数を使おうとしたときに打ち止め

eval `python extract_db_params_from_env.py`
echo "backup ${PG_HOSTNAME}/${PG_DATABASE}"

export BACKUP_FILENAME=/tmp/backup.sql.gz
pg_dump -h ${PG_HOSTNAME} -d ${PG_DATABASE} -U ${PG_USER} | gzip -9 -c > ${BACKUP_FILENAME}

if [ ""${BACKUP_ENCRYPT_KEY} != "" ] ; then
    export GNUPGHOME=/tmp/
    echo -n ${BACKUP_ENCRYPT_KEY} | gpg --no-tty -o ${BACKUP_FILENAME}.gpg --cipher-algo AES256 --passphrase-fd 0 -c ${BACKUP_FILENAME}
    rm ${BACKUP_FILENAME}
    FILENAME=${BACKUP_FILENAME}.gpg
fi

dst_path=s3://${S3_BUCKET_NAME}/${S3_PATH}/`date +"%Y-%m"`/`date +"%Y%m%d%H%M%S"`.sql.gz
echo "copy file to aws -> ${dst_path}"
aws s3 cp ${BACKUP_FILENAME} ${dst_path}

rm -f ${BACKUP_FILENAME}
