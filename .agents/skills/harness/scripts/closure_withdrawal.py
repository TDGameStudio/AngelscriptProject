"""Compile an exact withdrawal without changing refs, live files or the live index.

The returned before/after images are consumed by the journalled closure owner.
No restore/reset command is used. A baseline plus an optional explicit retained
patch proves the resulting selected implementation, including shared-file hunks.
"""
import base64
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile


def compile_withdrawal(request):
    root = Path(request['root']).resolve()
    env = os.environ.copy()

    def git(*args, input=None, cwd=None, environment=None):
        result = subprocess.run(['git', '-C', str(cwd or root), *args], input=input,
                                stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                env=environment or env)
        if result.returncode:
            raise ValueError(result.stderr.decode('utf-8', errors='replace').strip())
        return result.stdout

    def paths_between(a, b):
        return [p.decode('utf-8') for p in git('diff', '--name-only', '-z', a, b, '--').split(b'\0') if p]

    def contained(name, scopes):
        return any(name == s.rstrip('/') or name.startswith(s.rstrip('/') + '/') for s in scopes)

    def safe(name):
        if not name or '\\' in name or ':' in name or name.startswith('/') or any(p in ('', '.', '..', '.git') for p in name.split('/')):
            raise ValueError('Unsafe withdrawal path: ' + name)
        path = root / name
        for parent in (path, *path.parents):
            if parent == root:
                break
            if parent.is_symlink() or (parent.exists() and getattr(parent.lstat(), 'st_file_attributes', 0) & 0x400):
                raise ValueError('Withdrawal path contains a link or reparse point: ' + name)
        if path.exists() and not path.is_file():
            raise ValueError('Withdrawal requires regular files: ' + name)
        return path

    temp_root = root / 'Saved' / 'AgentTemp' / 'closure-withdrawal'
    temp_root.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=temp_root) as directory:
        temp = Path(directory)
        env['GIT_INDEX_FILE'] = str(temp / 'index')
        checkpoint = request['tree']
        reference = git('rev-parse', '--verify', request['reference'] + '^{commit}').decode().strip()
        git('read-tree', checkpoint)
        git('apply', '--cached', '--whitespace=nowarn', '-', input=request['patch'].encode('utf-8'))
        after_tree = git('write-tree').decode().strip()
        changed = paths_between(checkpoint, after_tree)
        if not changed:
            raise ValueError('Withdrawal patch has no selected change.')
        for name in changed:
            safe(name)
            if not contained(name, request['scopes']) or not contained(name, request['ownedScopes']):
                raise ValueError('Withdrawal exceeds checkpoint ownership: ' + name)
            for tree in (checkpoint, after_tree):
                mode = git('ls-tree', tree, '--', name).split(b' ', 1)[0]
                if mode and mode not in (b'100644', b'100755'):
                    raise ValueError('Withdrawal requires ordinary file modes: ' + name)

        # Build the exact accepted remaining implementation from the baseline.
        git('read-tree', reference)
        retained = request.get('retainedPatch', '')
        if retained:
            git('apply', '--cached', '--whitespace=nowarn', '-', input=retained.encode('utf-8'))
        expected_tree = git('write-tree').decode().strip()
        retained_paths = paths_between(reference, expected_tree)
        if request['kind'] == 'abandoned' and retained_paths:
            raise ValueError('Abandoned closure cannot silently retain implementation.')
        for name in retained_paths:
            if not contained(name, request['ownedScopes']):
                raise ValueError('Carryover exceeds checkpoint ownership: ' + name)
        mismatch = git('--literal-pathspecs', 'diff', '--name-only', '-z', expected_tree, after_tree, '--', *request['ownedScopes'])
        if mismatch:
            raise ValueError('Withdrawal result differs from the named baseline and explicit carryover patch.')

        # Apply only to copies of the actual live files, retaining other hunks.
        work = temp / 'work'
        work.mkdir()
        images = {}
        for name in changed:
            path = safe(name)
            before = path.read_bytes() if path.exists() else None
            images[name] = {'before': None if before is None else base64.b64encode(before).decode()}
            if before is not None:
                target = work / name
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(before)
        copy_env = env.copy()
        copy_env['GIT_DIR'] = git('rev-parse', '--absolute-git-dir').decode().strip()
        copy_env['GIT_WORK_TREE'] = str(work)
        git('apply', '--whitespace=nowarn', '-', input=request['patch'].encode('utf-8'), cwd=work, environment=copy_env)
        for name in changed:
            target = work / name
            images[name]['after'] = base64.b64encode(target.read_bytes()).decode() if target.exists() else None
        return {'tree': after_tree, 'reference': reference, 'files': images, 'retainedPaths': retained_paths}


if __name__ == '__main__':
    try:
        print(json.dumps(compile_withdrawal(json.load(sys.stdin)), ensure_ascii=False))
    except (ValueError, OSError, KeyError) as error:
        print(json.dumps({'error': str(error)}))
        sys.exit(1)
