"""Read actual repository and host snapshot identities without inventing a root HEAD."""
import hashlib
import json
from pathlib import Path
import subprocess

from draft_record import local_path


def git(root, *arguments):
    result = subprocess.run(['git', '-C', str(root), *arguments], capture_output=True)
    if result.returncode:
        raise ValueError(result.stderr.decode('utf8', errors='replace').strip())
    return result.stdout


def repository(root, path, baseline=None):
    head = git(root, 'rev-parse', 'HEAD').decode().strip()
    scope = ['.', ':(exclude)openspec'] if path == '.' else ['.']
    dirty = git(root, 'status', '--porcelain=v1', '-z', '--untracked-files=all', '--', *scope)
    digest = hashlib.sha256(dirty)
    digest.update(git(root, 'diff', '--binary', 'HEAD', '--', *scope))
    # Untracked source is not contained in git diff. Retain content identity too.
    for name in git(root, 'ls-files', '--others', '--exclude-standard', '-z', '--', *scope).decode('utf8').split('\0'):
        if name:
            file = local_path(root, name)
            if file.is_file():
                digest.update(name.encode('utf8'))
                digest.update(hashlib.sha256(file.read_bytes()).digest())
    return {'path': path, 'mode': 'Worktree', 'baseCommit': baseline or head,
            'head': head, 'branch': git(root, 'branch', '--show-current').decode().strip(),
            'dirty': bool(dirty), 'workingStateSha256': digest.hexdigest(),
            'dirtyPaths': [x for x in dirty.decode('utf8').split('\0') if x]}


def capture(context):
    root = Path(context['WorkspaceRoot'])
    primary = Path(context['PrimaryRoot'])
    result = {'recordBaseCommit': git(primary, 'rev-parse', 'HEAD').decode().strip(), 'repositories': []}
    if context['Topology'] == 'Replica':
        descriptor = json.loads((root / '.harness/workspace.json').read_text('utf8'))
        result['host'] = {'baseCommit': descriptor['HostBaseCommit'], 'files': [
            {'path': path, 'baselineSha256': entry['sha256'],
             'sha256': hashlib.sha256(local_path(root, path).read_bytes()).hexdigest() if local_path(root, path).is_file() else None}
            for path, entry in descriptor['HostFiles'].items()]}
        for entry in descriptor['Repositories'].values():
            if entry['Mode'] == 'Worktree':
                result['repositories'].append(repository(root / entry['Path'], entry['Path'], entry['BaseCommit']))
            else:
                result['repositories'].append({'path': entry['Path'], 'mode': 'Snapshot', 'baseCommit': entry['BaseCommit'],
                                               'sourceSha256': hashlib.sha256(json.dumps(entry['Files'], sort_keys=True).encode()).hexdigest()})
    else:
        result['host'] = repository(root, '.')
        plugins = root / 'Plugins'
        if plugins.exists():
            for plugin in plugins.iterdir():
                if plugin.is_dir() and (plugin / '.git').exists():
                    result['repositories'].append(repository(plugin, 'Plugins/' + plugin.name))
    return result
