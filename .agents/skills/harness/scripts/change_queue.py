"""Durable local Change queue; the calling agent owns execution.

Short OS locks protect record transactions, not chat lifetimes. A journal makes
the canonical assignment and local queue recoverable across interrupted writes.
"""
import argparse
import json
from pathlib import Path
import re
import sys
import uuid

sys.path.insert(0, str(Path(__file__).parent))
from draft_record import locked, local_path, save_state
from closure_status import inspect_closure


def record_identity(path):
    text = path.read_text('utf-8-sig')
    values = {}
    for key in ('uid', 'id'):
        match = re.search(r'^  ' + key + r':\s*(\S+)\s*$', text, re.M)
        if not match:
            raise ValueError('Change manifest lacks ' + key)
        values[key] = match[1].strip('\"\'')
    values['completed'] = bool(re.search(r'^closure:\s*\n(?:  [^\n]*\n)*?  kind: completed\s*$', text, re.M))
    closure = re.search(r'^closure:\s*\n(?:  [^\n]*\n)*?  kind: (completed|abandoned|superseded)\s*$', text, re.M)
    values['closureKind'] = closure[1] if closure else None
    return values


def change_path(context, change_id):
    if not re.fullmatch(r'[a-z0-9][a-z0-9-]*/[a-z0-9][a-z0-9-]*', change_id):
        raise ValueError('Invalid exact Change ID')
    return local_path(context['OpenSpecRoot'], 'openspec/changes/' + change_id)


def current(state):
    return next((item for item in state['items'] if item['disposition'] == 'pending'), None)


def authorized_pending(state):
    """Return the remaining fixed controller scope, without authorizing new items."""
    owner = state.get('controller')
    if not owner or 'authorizedUids' not in owner:
        raise ValueError('Controller authorization is missing; release and explicitly claim the queue again')
    authorized = owner['authorizedUids']
    if not isinstance(authorized, list) or len(authorized) != len(set(authorized)):
        raise ValueError('Controller authorization is invalid')
    by_uid = {item['uid']: item for item in state['items']}
    if any(uid not in by_uid or by_uid[uid]['disposition'] == 'removed' for uid in authorized):
        raise ValueError('An authorized queue member is missing or removed')
    remaining = [uid for uid in authorized if by_uid[uid]['disposition'] == 'pending']
    pending = [item['uid'] for item in state['items'] if item['disposition'] == 'pending']
    if pending[:len(remaining)] != remaining:
        raise ValueError('Queue order differs from the authorized prefix')
    return remaining


def inspect_record(context, item):
    if not item:
        return {'recordState': 'none', 'currentArchive': None, 'recordIssues': []}
    try:
        active = change_path(context, item['changeId'])
        if active.exists():
            identity = record_identity(active / 'change.yaml')
            if identity['uid'] != item['uid'] or identity['id'] != item['changeId']:
                raise ValueError('Active Change identity differs from its queued identity')
            close = inspect_closure(context, item, active)
            if close is not None:
                return {**close, 'currentArchive': None}
            return {'recordState': 'active', 'currentArchive': None, 'recordIssues': []}
        domain = item['changeId'].split('/')[0]
        archives = local_path(context['OpenSpecRoot'], 'openspec/archive/changes/' + domain)
        matches = []
        for manifest in archives.glob('*/change.yaml'):
            identity = record_identity(manifest)
            if identity['uid'] == item['uid'] and identity['id'] == item['changeId']:
                matches.append((manifest, identity))
        if len(matches) != 1:
            raise ValueError('Active Change is missing; exactly one matching completed archive is required')
        archive = str(matches[0][0].parent.relative_to(context['OpenSpecRoot'])).replace('\\', '/')
        close = inspect_closure(context, item, matches[0][0].parent, matches[0][1]['closureKind'])
        if close is not None:
            return {**close, 'currentArchive': archive}
        if not matches[0][1]['completed']:
            raise ValueError('Historical advancement requires a completed archive; an incomplete outcome requires its actual close operation')
        return {'recordState': 'archive-pending', 'currentArchive': archive, 'closureKind': 'completed', 'recordIssues': []}
    except (ValueError, OSError, KeyError, TypeError, AttributeError) as error:
        return {'recordState': 'record-blocked', 'currentArchive': None, 'recordIssues': [str(error)]}


def result(state, context):
    item = current(state)
    recovery_pending = False
    transaction_root = local_path(context['PrimaryRoot'], 'Saved/Harness/ChangeQueueTransactions')
    for path in transaction_root.glob('*.json'):
        try:
            transaction = json.loads(path.read_text('utf8'))
        except FileNotFoundError:  # A concurrent writer has already finished recovery.
            continue
        if Path(transaction['workspaceRoot']) == Path(context['WorkspaceRoot']):
            recovery_pending = True
            break
    return {**state, **inspect_record(context, item), 'recoveryPending': recovery_pending,
            'currentChange': item['changeId'] if item else None,
            'counts': {key: sum(x['disposition'] == value for x in state['items'])
                       for key, value in [('remaining', 'pending'), ('archived', 'archived'), ('removed', 'removed')]}}


def apply_transaction(context, path, transaction):
    center = Path(context['PrimaryRoot']).absolute()
    workspace = Path(transaction['workspaceRoot']).absolute()
    if workspace != center and not workspace.is_relative_to(center / '.workspaces'):
        raise ValueError('Queue transaction has an invalid workspace root')
    for write in transaction['writes']:
        if not write['relative'].startswith('openspec/changes/'):
            raise ValueError('Queue transaction has an invalid record target')
        target = local_path(context['OpenSpecRoot'], write['relative'])
        if write['kind'] == 'json':
            target.parent.mkdir(parents=True, exist_ok=True)
            save_state(target, write['content'])
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            temporary = target.with_name(target.name + '.' + uuid.uuid4().hex + '.tmp')
            temporary.write_text(write['content'], 'utf8')
            temporary.replace(target)
    queue_path = local_path(workspace, 'Saved/Harness/ChangeQueue/queue.json')
    queue_path.parent.mkdir(parents=True, exist_ok=True)
    save_state(queue_path, transaction['state'])
    path.unlink(missing_ok=True)


def operate(context, action, parameters):
    if context.get('Topology') not in ('Primary', 'Replica'):
        raise ValueError('Legacy worktrees are parked; no queue is attached automatically')
    root = Path(context['WorkspaceRoot']).absolute()
    path = local_path(root, 'Saved/Harness/ChangeQueue/queue.json')
    transaction_root = local_path(context['PrimaryRoot'], 'Saved/Harness/ChangeQueueTransactions')

    def load():
        state = json.loads(path.read_text('utf8')) if path.exists() else {
            'schemaVersion': 1, 'workspaceId': context['WorkspaceId'], 'workspaceRoot': str(root),
            'configured': False, 'revision': 0, 'items': [], 'controller': None, 'state': 'idle', 'pauseReason': None}
        if state['workspaceId'] != context['WorkspaceId'] or Path(state['workspaceRoot']) != root:
            raise ValueError('Queue workspace identity mismatch')
        return state

    if action == 'status':
        return result(load(), context)
    with locked(transaction_root / 'write.lock'):
        for pending in sorted(transaction_root.glob('*.json')):
            apply_transaction(context, pending, json.loads(pending.read_text('utf8')))
        state = load()
        writes = []

        def controller():
            owner = state['controller']
            if not owner or owner['token'] != parameters.get('Token'):
                raise ValueError('Current controller token is required')

        def revision():
            if parameters.get('ExpectedRevision') != state['revision']:
                raise ValueError('Queue revision changed; read status and retry')

        def mark(item, unbind=False, repositories=None):
            change = change_path(context, item['changeId'])
            identity = record_identity(change / 'change.yaml')
            if identity['uid'] != item['uid']:
                raise ValueError('Change UID changed')
            marker = change / 'attachments/data/harness-execution.json'
            existing = json.loads(marker.read_text('utf8')) if marker.exists() else {}
            if existing.get('workspaceId') not in (None, context['WorkspaceId']):
                raise ValueError('Change is assigned to another workspace: ' + item['changeId'])
            data = {**existing, 'schemaVersion': 1, 'changeId': item['changeId'], 'changeUid': item['uid'],
                    'workspaceId': None if unbind else context['WorkspaceId'],
                    'workspaceName': root.name, 'repositories': existing.get('repositories', [])}
            if repositories is not None:
                data['repositories'] = repositories
            if 'Source' in parameters:
                data['sourceBaseline'] = existing.get('sourceBaseline', parameters['Source'])
                data['source'] = parameters['Source']
                if not repositories:
                    baseline = {entry['path']: entry for entry in data['sourceBaseline']['repositories']}
                    data['repositories'] = [dict(entry, baseCommit=baseline.get(entry['path'], entry).get('head', entry['baseCommit']),
                                                 resultCommit=entry.get('head')) for entry in data['source']['repositories']]
            writes.append({'relative': str(marker.relative_to(context['OpenSpecRoot'])).replace('\\', '/'), 'kind': 'json', 'content': data})
            index = change / 'attachments/INDEX.md'
            body = index.read_text('utf8') if index.exists() else '# Attachments\n'
            link = '(data/harness-execution.json)'
            if body.count(link) > 1:
                raise ValueError('Execution attachment is indexed more than once')
            if link not in body:
                body = body.rstrip() + '\n\n- [Harness execution](data/harness-execution.json) — Workspace assignment and repository evidence.\n'
                writes.append({'relative': str(index.relative_to(context['OpenSpecRoot'])).replace('\\', '/'), 'kind': 'text', 'content': body})

        if action in ('set', 'remove', 'reorder'):
            revision()
            head = current(state)
            ids = parameters.get('Changes', [])
            if action == 'remove':
                ids = [x['changeId'] for x in state['items'] if x['disposition'] == 'pending' and x['changeId'] != parameters.get('Change')]
            ids = list(dict.fromkeys(ids))
            pending_ids = [x['changeId'] for x in state['items'] if x['disposition'] == 'pending']
            if action == 'reorder' and set(ids) != set(pending_ids):
                raise ValueError('Reorder must contain exactly the pending Changes')
            if state['controller'] and head and (not ids or ids[0] != head['changeId']):
                raise ValueError('Pause and release the controller before changing the active head')
            if state['controller']:
                remaining = authorized_pending(state)
                authorized_ids = {item['uid']: item['changeId'] for item in state['items']}
                if ids[:len(remaining)] != [authorized_ids[uid] for uid in remaining]:
                    raise ValueError('Pause and release before changing the authorized queue prefix')
            existing = {x['changeId']: x for x in state['items']}
            new = []
            for change_id in ids:
                identity = record_identity(change_path(context, change_id) / 'change.yaml')
                if identity['id'] != change_id:
                    raise ValueError('Change manifest identity mismatch')
                old = existing.get(change_id)
                item = dict(old) if old and old['disposition'] in ('pending', 'removed') else {
                    'changeId': change_id, 'uid': identity['uid'], 'disposition': 'pending', 'started': False, 'archive': None}
                item['disposition'] = 'pending'
                mark(item)
                new.append(item)
            history = []
            for item in state['items']:
                if item['changeId'] in ids:
                    continue
                if item['disposition'] == 'pending':
                    item['disposition'] = 'removed'
                    if not item['started']:
                        mark(item, unbind=True)
                history.append(item)
            state['items'] = new + history
            state['configured'] = True
            if not state['controller']:
                state['state'] = 'paused' if state['pauseReason'] else ('idle' if current(state) else 'exhausted')
        elif action in ('claim', 'takeover'):
            if not state['configured']:
                raise ValueError('No queue configured; select an explicit ordered Change list')
            session = parameters.get('SessionId')
            if not session:
                raise ValueError('SessionId is required')
            if state['controller'] and action == 'claim':
                if state['controller']['sessionId'] != session:
                    raise ValueError('Queue is occupied; explicit takeover is required')
                authorized_pending(state)
                if 'AuthorizedUids' in parameters and parameters['AuthorizedUids'] != state['controller']['authorizedUids']:
                    raise ValueError('Controller authorization differs from this claim')
                if parameters.get('SourceRef') and parameters['SourceRef'] != state['controller'].get('sourceRef'):
                    raise ValueError('Controller authorization source differs from this claim')
                return result(state, context)
            else:
                if state['controller'] and not parameters.get('PreviousControllerStopped'):
                    raise ValueError('Confirm the previous controller has stopped before takeover')
                pending_uids = [item['uid'] for item in state['items'] if item['disposition'] == 'pending']
                authorized = parameters.get('AuthorizedUids', pending_uids)
                if (not isinstance(authorized, list) or (pending_uids and not authorized) or
                        len(authorized) != len(set(authorized)) or pending_uids[:len(authorized)] != authorized):
                    raise ValueError('Controller authorization must be an exact ordered pending prefix')
                if state['controller'] and action == 'takeover':
                    old_scope = authorized_pending(state)
                    if 'AuthorizedUids' not in parameters:
                        authorized = old_scope
                    elif authorized != old_scope:
                        raise ValueError('Takeover cannot widen or replace the existing authorization')
                state['controller'] = {'sessionId': session, 'token': uuid.uuid4().hex,
                                       'authorizedUids': authorized, 'sourceRef': parameters.get('SourceRef', '')}
            state['state'] = 'pause-requested' if state['pauseReason'] else 'claimed'
            item = current(state)
            if item:
                if change_path(context, item['changeId']).exists():
                    mark(item)
                item['started'] = True
            else:
                state['controller'], state['state'] = None, 'exhausted'
        elif action == 'pause':
            state['state'] = 'pause-requested' if state['controller'] else 'paused'
            state['pauseReason'] = parameters.get('Reason') or 'Pause requested'
        elif action == 'resume':
            # Internal execution adapter operation; acquiring ownership never resumes.
            controller()
            authorized_pending(state)
            source = parameters.get('SourceRef')
            if not source or source in state.get('resumeSources', []):
                raise ValueError('Resuming a pause requires its new resolving source')
            state.setdefault('resumeSources', []).append(source)
            state['state'], state['pauseReason'] = 'claimed', None
        elif action == 'release':
            controller()
            state['controller'] = None
            state['state'] = 'paused' if state['pauseReason'] else 'idle'
        elif action == 'checkpoint':
            controller()
            authorized_pending(state)
            item = current(state)
            if not item:
                raise ValueError('No current Change')
            mark(item, repositories=parameters.get('Repositories'))
        elif action == 'advance':
            controller()
            remaining = authorized_pending(state)
            item = current(state)
            if not item:
                return result(state, context)
            if not remaining or remaining[0] != item['uid']:
                raise ValueError('Current Change is outside controller authorization')
            if change_path(context, item['changeId']).exists():
                raise ValueError('Current Change is still active; completed archive required')
            record = inspect_record(context, item)
            if record['recordState'] != 'archive-pending':
                raise ValueError('; '.join(record['recordIssues']))
            item['disposition'] = 'archived'
            item['archive'] = record['currentArchive']
            item['closureKind'] = record['closureKind']
            head = current(state)
            if head:
                if state['pauseReason'] or not authorized_pending(state):
                    state['controller'], state['state'] = None, 'paused' if state['pauseReason'] else 'idle'
                else:
                    mark(head)
                    head['started'] = True
            else:
                state['controller'], state['state'] = None, 'exhausted'
        else:
            raise ValueError('Unknown queue action: ' + action)
        state['revision'] += 1
        transaction = {'workspaceRoot': str(root), 'state': state, 'writes': writes}
        pending = transaction_root / (uuid.uuid4().hex + '.json')
        save_state(pending, transaction)
        apply_transaction(context, pending, transaction)
        return result(state, context)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('action')
    args = parser.parse_args()
    try:
        payload = json.load(sys.stdin)
        if args.action == 'checkpoint':
            from source_identity import capture
            source = capture(payload['context'])
            supplied = payload.setdefault('parameters', {}).get('Repositories', [])
            actual = {entry['path']: entry for entry in source['repositories']}
            for entry in supplied:
                if entry['path'] not in actual or (entry.get('resultCommit') and entry['resultCommit'] != actual[entry['path']].get('head')):
                    raise ValueError('Repository evidence does not match the selected workspace')
            payload['parameters']['Source'] = source
        print(json.dumps(operate(payload['context'], args.action, payload.get('parameters', {})), ensure_ascii=False))
    except (ValueError, OSError, KeyError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
