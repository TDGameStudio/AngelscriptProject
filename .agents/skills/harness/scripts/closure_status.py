"""Read close persistence without advancing queues or repairing operations."""
import hashlib
import json
from pathlib import Path
import re
import subprocess

from draft_record import local_path


def journal_path(context, change):
    identity = json.dumps([context['OpenSpecRoot'].lower(), change], ensure_ascii=False, separators=(',', ':'))
    key = hashlib.sha256(identity.encode('utf8')).hexdigest()
    return local_path(context['OpenSpecRoot'], 'Saved/Harness/ChangeClosures/' + key + '.json')


def archive_persisted(root, archive, commit='HEAD'):
    """Prove every archived blob is in Git, respecting attributes/line endings."""
    relative = archive.relative_to(root).as_posix()
    if commit != 'HEAD' and not re.fullmatch(r'[0-9a-f]{40}(?:[0-9a-f]{24})?', commit):
        raise ValueError('Close record commit is not an exact Git object identity')

    def git(*args):
        result = subprocess.run(['git', '-C', str(root), *args], capture_output=True)
        return result.stdout if result.returncode == 0 else None

    if git('merge-base', '--is-ancestor', commit, 'HEAD') is None:
        return False
    tree = git('ls-tree', '-r', '-z', commit, '--', relative)
    if tree is None:
        return False
    entries = {}
    for row in tree.split(b'\0'):
        if not row:
            continue
        metadata, name = row.split(b'\t', 1)
        mode, kind, sha = metadata.split()
        if mode not in (b'100644', b'100755') or kind != b'blob':
            return False
        entries[name.decode('utf8')] = sha
    files = {p.relative_to(root).as_posix(): p for p in archive.rglob('*') if p.is_file()}
    if not entries or set(entries) != set(files):
        return False
    for name, path in files.items():
        local_path(root, name)  # existing containment and reparse guards
        blob = git('hash-object', '--path=' + name, '--', str(path))
        if blob is None or blob.strip() != entries[name]:
            return False
    return True


def inspect_closure(context, item, record, kind=None):
    path = journal_path(context, item['changeId'])
    state = json.loads(path.read_text('utf-8-sig')) if path.exists() else None
    receipt_path = record / 'attachments/data/harness-closure.json'
    receipt = json.loads(receipt_path.read_text('utf-8-sig')) if receipt_path.exists() else None
    if state is None and receipt is None:
        return None  # Accepted historical archive contract remains separate.
    if state is not None:
        if (state.get('schema') != 1 or state.get('uid') != item['uid'] or state.get('change') != item['changeId']
                or Path(state.get('recordRoot', '')) != Path(context['OpenSpecRoot'])
                or state.get('stage') not in ('prepared', 'implementation-saved', 'withdrawal-saved', 'archive-ready', 'archived', 'complete')):
            raise ValueError('Close recovery journal identity or stage is invalid')
        if kind is not None and state.get('kind') != kind:
            raise ValueError('Close journal outcome differs from the archive')
    if receipt is not None:
        gate = receipt.get('gate', {})
        if (receipt.get('schema') != 1 or receipt.get('uid') != item['uid']
                or (kind is not None and receipt.get('kind') != kind)
                or gate.get('Decision') != 'close' or gate.get('TargetChange') != item['changeId']
                or not gate.get('DecisionSource') or not receipt.get('revision')
                or gate.get('HandoffRevision') != receipt.get('revision')):
            raise ValueError('Close receipt identity or actual decision is invalid')
        if state is not None and (receipt.get('revision') != state.get('revision') or gate != state.get('gate')):
            raise ValueError('Close receipt differs from its saved exact decision')
    stage = state['stage'] if state is not None else 'archived'
    if kind is None and state is None:
        raise ValueError('Active close receipt is missing its exact recovery journal')
    pending = dict(recordState='close-pending', closeStage=stage, closureKind=kind or state['kind'],
                   recordIssues=['The accepted close operation has pending commit or archive stages; recover it before queue advancement.'])
    if kind is None or (state is not None and stage != 'complete'):
        return pending
    if receipt is None:
        raise ValueError('Completed close journal is missing its archived receipt')
    commit = state.get('recordCommit') if state is not None else 'HEAD'
    if not commit or not archive_persisted(Path(context['OpenSpecRoot']), record, commit):
        return {**pending, 'recordIssues': ['Canonical archive commit is missing or differs from the archived bytes; recover the exact close operation.']}
    return dict(recordState='archive-pending', closeStage='complete', closureKind=kind, recordIssues=[])
