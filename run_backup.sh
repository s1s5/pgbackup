#!/bin/bash
# -*- mode: shell-script -*-

set -eu  # <= 0以外が返るものがあったら止まる, 未定義の変数を使おうとしたときに打ち止め

eval `python extract_db_params_from_env.py`
echo "backup ${PG_HOSTNAME}/${PG_DATABASE}"

pg_isready -h ${PG_HOSTNAME} -d ${PG_DATABASE} -U ${PG_USER}
if [ $? != 0 ]; then
    echo "postgres not up"
    exit 1
fi

export BACKUP_FILENAME=/tmp/backup.sql.gz
export DST_NAME=`date +"%Y%m%d%H%M%S"`.sql.gz
pg_dump -h ${PG_HOSTNAME} -d ${PG_DATABASE} -U ${PG_USER} -Z 6 -f ${BACKUP_FILENAME}

if [ "${BACKUP_ENCRYPT_KEY:-}" != "" ] ; then
    echo "encrypting file"
    export GNUPGHOME=/tmp/
    echo -n ${BACKUP_ENCRYPT_KEY} | gpg --batch --no-tty -o ${BACKUP_FILENAME}.gpg --cipher-algo AES256 --passphrase-fd 0 -c ${BACKUP_FILENAME}
    rm ${BACKUP_FILENAME}

    export BACKUP_FILENAME=${BACKUP_FILENAME}.gpg
    export DST_NAME=${DST_NAME}.gpg
fi

dst_path=s3://${S3_BUCKET_NAME}/${S3_PATH}/`date +"%Y-%m"`/${DST_NAME}
echo "copy file to aws -> ${dst_path}"
aws s3 cp ${BACKUP_FILENAME} ${dst_path}

if [ "${POST_HOOK:-}" != "" ] ; then
    ${POST_HOOK}
fi

rm -f ${BACKUP_FILENAME}
