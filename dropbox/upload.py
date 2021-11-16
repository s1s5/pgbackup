import hashlib
import os

import dropbox


def upload(dbx, local_file_path, dbx_target_path):
    chunk_size = 4 * 1024 * 1024

    f = open(local_file_path, "rb")
    file_size = os.path.getsize(local_file_path)
    content_hash = hashlib.sha256()

    def _get_data(_all=False):
        data = f.read() if _all else f.read(chunk_size)
        content_hash.update(hashlib.sha256(data).digest())
        return data

    if file_size <= chunk_size:
        m = dbx.files_upload(_get_data(_all=True), dbx_target_path)
        assert content_hash.hexdigest() == m.content_hash
        return m

    sr = dbx.files_upload_session_start(_get_data())
    cursor = dropbox.files.UploadSessionCursor(session_id=sr.session_id, offset=f.tell())
    commit = dropbox.files.CommitInfo(path=dbx_target_path)

    while (file_size - f.tell()) > chunk_size:
        dbx.files_upload_session_append(_get_data(), cursor.session_id, cursor.offset)
        cursor.offset = f.tell()

    m = dbx.files_upload_session_finish(_get_data(), cursor, commit)
    assert file_size == f.tell() and content_hash.hexdigest() == m.content_hash
    return m


def main(token, src, dst):
    dbx = dropbox.Dropbox(token)
    upload(dbx, src, dst)


def __entry_point():
    import argparse
    parser = argparse.ArgumentParser(
        description=u'',  # プログラムの説明
    )
    # parser.add_argument("args", nargs="*")
    parser.add_argument("--token", default=os.environ.get('DROPBOX_TOKEN'))
    parser.add_argument("--src")
    parser.add_argument("--dst")
    # parser.add_argument("--int-value", type=int)
    # parser.add_argument('--move', choices=['rock', 'paper', 'scissors'])
    main(**dict(parser.parse_args()._get_kwargs()))


if __name__ == '__main__':
    __entry_point()
