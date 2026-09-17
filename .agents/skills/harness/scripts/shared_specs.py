"""Short, optimistic writes to canonical specs shared by execution workspaces."""
import hashlib
import json
from pathlib import Path
import re
import sys
import uuid

from draft_record import locked, local_path


def operate(root, action, spec, expected='', content=''):
    if not re.fullmatch(r'[a-z0-9][a-z0-9-]*(?:/[a-z0-9][a-z0-9-]*)+', spec):
        raise ValueError('An exact domain/capability ID is required')
    target = local_path(root, 'openspec/specs/' + spec + '/spec.md')
    def read():
        data = target.read_bytes()
        return {'spec': spec, 'sha256': hashlib.sha256(data).hexdigest(), 'content': data.decode('utf-8-sig')}
    if action == 'read':
        return read()
    if action != 'write':
        raise ValueError('Unknown shared spec operation')
    with locked(local_path(root, 'Saved/Harness/SharedSpecs/write.lock')):
        previous = read()
        if previous['sha256'] != expected:
            raise ValueError('Spec changed; reread and merge against the current content')
        temporary = target.with_name(target.name + '.' + uuid.uuid4().hex + '.tmp')
        try:
            temporary.write_text(content, encoding='utf8', newline='\n')
            temporary.replace(target)
        finally:
            temporary.unlink(missing_ok=True)
        return read()


if __name__ == '__main__':
    try:
        request = json.load(sys.stdin)
        print(json.dumps(operate(**request), ensure_ascii=False))
    except (ValueError, OSError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
