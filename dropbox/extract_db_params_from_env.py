import os
from urllib.parse import urlparse


def main(db_url):
    parsed = urlparse(db_url)
    for key, value in [
            ('PG_USER', parsed.username),
            ('PGPASSWORD', parsed.password),
            ('PG_HOSTNAME', parsed.hostname),
            ('PG_DATABASE', parsed.path[1:]),
    ]:
        print('export {}={}'.format(key, value))


if __name__ == '__main__':
    main(os.environ['DATABASE_URL'])
