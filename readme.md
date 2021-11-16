# backup postgres -> s3
set environment
``` yaml
- name: DATABASE_URL
  value: psql://user:pass@127.0.0.1:8458/db
- name: BACKUP_ENCRYPT_KEY
  value: some-key-this-is-not-required
- name: S3_BUCKET_NAME
  value: backup-bucket
- name: S3_PATH
  value: path/to/backup
- name: AWS_ACCESS_KEY_ID
  value: key
- name: AWS_SECRET_ACCESS_KEY
  value: secret
- name: AWS_DEFAULT_REGION
  value: region
```

- backup to `s3://${S3_BUCKET_NAME}/${S3_PATH}/<year>-<month>/<datetime>.sql.gz`

# backup postgres -> dropbox
- image: s1s5/pgbackup:dropbox
set environment
``` yaml
- name: DATABASE_URL
  value: psql://user:pass@127.0.0.1:8458/db
- name: BACKUP_ENCRYPT_KEY
  value: some-key-this-is-not-required
- name: DROPBOX_TOKEN
  value: access-token
- name: DROPBOX_PATH
  value: path/to/backup
```
- backup to `${DROPBOX_PATH}/<year>-<month>/<datetime>.sql.gz`


# decrypt backup
- `echo -n ${BACKUP_ENCRYPT_KEY} | gpg --batch --yes --no-tty -o dst.sql.gz --passphrase-fd 0 -d src.sql.gz.gpg`
