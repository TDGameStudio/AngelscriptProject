"""Explicit session execution bindings and derived continuation decisions."""
import json
from copy import deepcopy
from pathlib import Path
import re

from draft_record import digest, local_path, locked, save_state
from discussions import active_change, now
from replans import replan_status, native
from change_queue import operate, authorized_pending, inspect_record


def handoff_status(context, change):
    from handoff import get_handoff_status
    return get_handoff_status(context, change)


def handoff_authority(state, uid):
    return state.get('handoffAuthorizations', {}).get(uid, {})


def consume_handoff(context, state, change, source, fresh=False):
    handoff = handoff_status(context, change)
    if handoff['issues']:
        raise ValueError('Handoff repair required: ' + '; '.join(handoff['issues']))
    identity = handoff.get('handoff_id')
    uid = execution_change(context, change)[1]['uid']
    if not identity or handoff_authority(state, uid).get('handoffId') == identity:
        return
    if not source:
        return
    decision_source = handoff.get('execution_source')
    old_sources = {state.get('sourceRef'), state.get('authorizationSource')}
    old_sources.update(item.get('source') for item in state.get('handoffAuthorizations', {}).values())
    if not fresh and source in old_sources and not (handoff.get('execution_decision') == 'now' and source == decision_source):
        raise ValueError('A new handoff requires a new actual execution arrangement or resume source')
    if handoff['pending'] and (handoff.get('execution_decision') != 'now' or source != decision_source):
        raise ValueError('Post-handoff arrangements require actual answers before execution authorization')
    if handoff.get('execution_decision') in ('queue', 'later') and source == decision_source:
        raise ValueError('The queue/later decision is not execution authority; a later explicit resume source is required')
    state.update(authorizedHandoffId=identity, authorizationSource=source)
    state.setdefault('handoffAuthorizations', {})[uid] = dict(handoffId=identity, source=source)


def scope_remaining(queue, authorized):
    items = {item['uid']: item for item in queue['items']}
    if any(uid not in items or items[uid]['disposition'] == 'removed' for uid in authorized):
        raise ValueError('An authorized execution member is missing or removed')
    return [uid for uid in authorized if items[uid]['disposition'] == 'pending']


def require_resume_source(state, source):
    used = {state.get('sourceRef'), state.get('authorizationSource'), state.get('pauseSource')}
    used.update(state.get('resumeSources', []))
    if not source or source in used:
        raise ValueError('Resuming a pause or blocker requires its new resolving source')


def claim_execution(context, state, source, resume=False):
    queue = operate(context, 'status', {})
    if queue['recoveryPending']:
        raise ValueError('Queue recovery required before execution can claim or resume')
    remaining = scope_remaining(queue, state['authorizedUids'])
    owner = queue.get('controller')
    if not remaining:
        return queue
    if owner and owner['sessionId'] != state['sessionId']:
        raise ValueError('Queue is occupied; explicit takeover is required')
    if owner:
        if authorized_pending(queue) != remaining:
            raise ValueError('Existing controller authorization differs from the requested execution scope')
    else:
        queue = operate(context, 'claim', dict(SessionId=state['sessionId'], AuthorizedUids=remaining, SourceRef=source))
    if resume and queue['state'] in ('paused', 'pause-requested'):
        queue = operate(context, 'resume', dict(Token=queue['controller']['token'], SourceRef=source))
    return queue


def state_path(context, session):
    if not re.fullmatch(r'[A-Za-z0-9_-]+', session or ''):
        raise ValueError('Exact execution session ID required')
    return local_path(context['WorkspaceRoot'], 'Saved/Harness/Execution/' + session + '.json')


def load(context, session):
    path = state_path(context, session)
    if not path.exists():
        return None
    state = json.loads(path.read_text('utf8'))
    if state['workspaceId'] != context['WorkspaceId'] or state['sessionId'] != session or Path(state['workspaceRoot']) != Path(context['WorkspaceRoot']):
        raise ValueError('Execution workspace or session identity differs')
    return state


def transfer_journals(context):
    return local_path(context['WorkspaceRoot'], 'Saved/Harness/Execution/transfers').glob('*.json')


def publish_transfer(context, journal, records):
    # Publish the new obligation holder before retiring the previous one. The
    # journal makes either interrupted write replayable under execution.lock.
    for record in records:
        if record['workspaceId'] != context['WorkspaceId'] or Path(record['workspaceRoot']) != Path(context['WorkspaceRoot']):
            raise ValueError('Execution transfer workspace identity differs')
        save_state(state_path(context, record['sessionId']), record)
    journal.unlink()


def execution_change(context, change):
    root, identity = active_change(context, change)
    marker = local_path(root, 'attachments/data/harness-execution.json')
    if marker.exists() and json.loads(marker.read_text('utf8')).get('workspaceId') not in (None, context['WorkspaceId']):
        raise ValueError('Change is assigned to another workspace')
    return root, identity


def derive(context, state):
    result = {**state, 'implementationAllowed': False, 'nextAction': '', 'issues': []}
    if state.get('released'):
        return {**result, 'state': 'released'}
    if any(transfer_journals(context)):
        return {**result, 'state': 'blocked', 'reason': 'Execution transfer recovery required',
                'nextAction': 'Retry the execution mutation to recover the recorded transfer.'}
    progress = []
    try:
        if state['scope'] != 'Queue' or 'authorizedUids' not in state:
            if state.get('scope') == 'Change' and inspect_record(context, {'changeId': state['change'], 'uid': state['changeUid']})['recordState'] == 'archive-pending':
                return {**result, 'state': 'complete', 'nextAction': 'The historical direct execution completed before queue unification.'}
            raise ValueError('Legacy execution binding requires an explicit start through the queue adapter')
        queue = operate(context, 'status', {})
        progress.append(queue)
        remaining = scope_remaining(queue, state['authorizedUids'])
        result['change'] = queue['currentChange'] if remaining else state.get('change')
        result['changeUid'] = next((item['uid'] for item in queue['items'] if item['disposition'] == 'pending'), None) if remaining else state.get('changeUid')
        if queue['recoveryPending']:
            result.update(state='blocked', reason='Queue recovery required')
        elif not remaining:
            result.update(state='complete', nextAction='The authorized queue scope is complete; remaining members need their own execution authorization.')
        elif queue['state'] in ('paused', 'pause-requested'):
            result.update(state='paused', reason=queue['pauseReason'])
        elif not queue['controller']:
            result.update(state='paused', reason='Queue controller released; explicitly resume the same authorized scope.')
        elif queue['controller']['sessionId'] != state['sessionId']:
            result.update(state='blocked', reason='Queue belongs to another session')
        elif authorized_pending(queue) != remaining:
            result.update(state='blocked', reason='Controller authorization differs from the execution scope')
        elif queue['recordState'] == 'archive-pending':
            result.update(phase='advancing', nextAction='Advance the completed archive within the authorized queue scope.')
        elif queue['recordState'] == 'record-blocked':
            result.update(state='blocked', reason='; '.join(queue['recordIssues']))
        if remaining and state['state'] in ('paused', 'blocked'):
            result.update(state=state['state'], reason=state.get('reason', ''))
        if result['state'] == 'running' and result.get('change') and result['phase'] != 'advancing':
            execution_change(context, result['change'])
            replans = replan_status(context, result['change'])
            progress.append(replans)
            handoff = handoff_status(context, result['change'])
            progress.append(handoff)
            result['handoff'] = handoff
            if replans['recoveryNeeded'] or replans['discussions']['issues']:
                result.update(state='blocked', reason='Replan recovery or discussion repair required')
            elif handoff['issues']:
                result.update(state='blocked', reason='Handoff repair required', issues=handoff['issues'])
            elif handoff['pending'] or (handoff.get('handoff_id') and handoff_authority(state, result['changeUid']).get('handoffId') != handoff['handoff_id']):
                result.update(state='waiting-input', phase='handoff-followup', questions=handoff.get('questions', []),
                              nextAction='Complete the post-handoff decisions and explicitly consume the execution arrangement before continuing.')
            else:
                pending = [r for r in replans['discussions']['records'] if r['talk_id'] in replans['discussions']['blockers']]
                unanswered = [q for r in pending for q in r['questions'] if not q.get('answer')]
                if unanswered:
                    result.update(state='waiting-input', phase='grilling', questions=unanswered, nextAction='Continue the pending grill when actual answers arrive.')
                elif pending:
                    result.update(phase='replanning' if all(r['status'] == 'settled' for r in pending) else 'grilling',
                                  nextAction='Resolve the decision frontier and apply the settled Replan; then resume execution.')
                else:
                    root, _ = active_change(context, result['change'])
                    tasks = root / 'tasks.md'
                    progress.append(digest(tasks.read_bytes()) if tasks.exists() else 'plan-needed')
                    if tasks.exists():
                        plan = native(context, ['instructions', 'apply', '--change', result['change'], '--json'])
                        result['progress'] = plan.get('progress')
                        result['ready'] = [t['id'] for t in plan.get('tasks', []) if t.get('ready')]
                        result['implementationAllowed'] = bool(result['ready'])
                        result['nextAction'] = 'Continue Ready work, or complete verification, synchronization and archive when tasks are done.'
                    else:
                        result.update(phase='planning', nextAction='Ensure the accepted Change plan, then continue execution.')
        if state['pendingInputs']:
            result.update(state=result['state'] if result['state'] in ('paused', 'blocked', 'waiting-input') else 'running', phase='feedback-pending',
                          implementationAllowed=False, nextAction='Triage the pending user input without replacing the authorized scope; acknowledge its ID.')
        if result['state'] != 'running':
            result['implementationAllowed'] = False
        result['fingerprint'] = digest(json.dumps([progress, state['phase'], state.get('resumeTask'), state.get('progressRef'), state['pendingInputs']], sort_keys=True).encode())
    except (ValueError, OSError, KeyError, TypeError) as error:
        result.update(state='blocked', reason=str(error), implementationAllowed=False, issues=[str(error)])
    return result

def execute(context, action, parameters):
    session = parameters.get('SessionId', '')
    path = state_path(context, session)
    if action == 'status':
        state = load(context, session)
        return derive(context, state) if state else {'state': 'unbound', 'revision': 0, 'implementationAllowed': False}
    with locked(path.parent / 'execution.lock'):
        for journal in sorted(transfer_journals(context)):
            publish_transfer(context, journal, json.loads(journal.read_text('utf8'))['records'])
        state = load(context, session)
        if action == 'start':
            scope = parameters.get('Scope')
            source = parameters.get('SourceRef')
            if scope not in ('Change', 'Queue') or not source:
                raise ValueError('Explicit Change/Queue execution scope and authorization source required')
            change = parameters.get('Change', '')
            if scope == 'Change' and not change:
                raise ValueError('The single Change adapter requires one exact Change')
            queue = operate(context, 'status', {})
            if queue['recoveryPending']:
                raise ValueError('Queue recovery required; explicitly claim the existing queue before execution')
            active = state and derive(context, state)['state'] not in ('complete', 'released')
            legacy = active and (state['scope'] != 'Queue' or 'authorizedUids' not in state)
            if active:
                transfer = state.get('transfer', {})
                if (parameters.get('PreviousSessionStopped') and parameters.get('PreviousSessionId') == transfer.get('fromSession') and
                        source == transfer.get('source') and change == transfer.get('requestedChange')):
                    return derive(context, state)
                old_request = state.get('requestChange', state.get('change', '') if state['scope'] == 'Change' else '')
                if old_request != change:
                    raise ValueError('Session already has another unfinished execution request or authorization scope')
                if not legacy:
                    current_change = queue['currentChange']
                    if not current_change:
                        return derive(context, state)
                    before = json.dumps(state, sort_keys=True)
                    needs_resume = state['state'] in ('paused', 'blocked') or queue['state'] in ('paused', 'pause-requested') or not queue['controller']
                    if needs_resume:
                        require_resume_source(state, source)
                    consume_handoff(context, state, current_change, source)
                    if needs_resume:
                        claim_execution(context, state, source, resume=True)
                        state.setdefault('resumeSources', []).append(source)
                        state.update(state='running', reason='', authorizationSource=source)
                    else:
                        claim_execution(context, state, source)
                    if json.dumps(state, sort_keys=True) == before:
                        return derive(context, state)
                    state.update(revision=state['revision'] + 1, updatedAt=now())
                    save_state(path, state)
                    return derive(context, state)
            transfers = []
            for other in path.parent.glob('*.json'):
                previous = json.loads(other.read_text('utf8'))
                if previous['sessionId'] != session:
                    if derive(context, previous)['state'] not in ('complete', 'released'):
                        if not parameters.get('PreviousSessionStopped') or parameters.get('PreviousSessionId') != previous['sessionId']:
                            raise ValueError('Another session owns execution; explicitly stop and transfer its binding before starting')
                        transfers.append((other, previous))
            if transfers:
                if len(transfers) != 1:
                    raise ValueError('Execution transfer requires exactly one unfinished request')
                other, previous = transfers[0]
                if previous['scope'] != 'Queue' or 'authorizedUids' not in previous:
                    raise ValueError('Migrate the legacy execution request before transferring it')
                if change and change != previous.get('requestChange', ''):
                    raise ValueError('Takeover cannot replace the unfinished execution request')
                next_state = deepcopy(previous)
                next_state.update(sessionId=session, revision=1, updatedAt=now(),
                                  transfer=dict(fromSession=previous['sessionId'], source=source, requestedChange=change))
                next_state['history'] = [*next_state.get('history', []), {key: value for key, value in previous.items() if key != 'history'}]
                if state:
                    next_state['history'].extend([*state.get('history', []), {key: value for key, value in state.items() if key != 'history'}])
                for item in queue['items']:
                    if item['uid'] in next_state['authorizedUids'] and item['disposition'] == 'pending' and inspect_record(context, item)['recordState'] == 'active':
                        execution_change(context, item['changeId'])
                # Ownership authority carries the original scope and handoff
                # receipts; it never consumes a newer arrangement or pause.
                claim_execution(context, next_state, source)
                previous.update(released=True, releasedTo=session, revision=previous['revision'] + 1, updatedAt=now())
                journal = path.parent / 'transfers' / (session + '.json')
                journal.parent.mkdir(parents=True, exist_ok=True)
                records = [next_state, previous]
                save_state(journal, {'records': records})
                publish_transfer(context, journal, records)
                return derive(context, next_state)
            if change:
                if queue['currentChange'] and queue['currentChange'] != change:
                    raise ValueError('QueueOrderConflict: the requested Change is not the current queue head; arrange the queue explicitly')
                if not (queue['currentChange'] == change and queue['recordState'] == 'archive-pending'):
                    execution_change(context, change)
            elif not queue['configured']:
                raise ValueError('No queue configured; select an explicit ordered Change list')
            current_change = change or queue['currentChange']
            next_state = dict(schema=2, workspaceId=context['WorkspaceId'], workspaceRoot=context['WorkspaceRoot'], sessionId=session,
                              scope='Queue', requestChange=change, change=current_change, sourceRef=source,
                              state='running', phase='planning', revision=1, pendingInputs=[], handledInputs=[], inputDigests={},
                              resumeTask='', reason='', authorizedHandoffId=None, authorizationSource=source, updatedAt=now())
            if state:
                next_state['history'] = [*state.get('history', []), {key: value for key, value in state.items() if key != 'history'}]
            if current_change and queue['recordState'] != 'archive-pending':
                execution_change(context, current_change)
                consume_handoff(context, next_state, current_change, source, fresh=True)
            if change and not queue['currentChange']:
                queue = operate(context, 'set', dict(Changes=[change], ExpectedRevision=queue['revision']))
            pending = [item for item in queue['items'] if item['disposition'] == 'pending']
            next_state['authorizedUids'] = [item['uid'] for item in (pending[:1] if change else pending)]
            if not change and queue.get('controller') and queue['controller']['sessionId'] == session:
                authorized_pending(queue)
                next_state['authorizedUids'] = list(queue['controller']['authorizedUids'])
            next_state['changeUid'] = pending[0]['uid'] if pending else None
            for item in pending:
                if item['uid'] not in next_state['authorizedUids'] or item['changeId'] == current_change:
                    continue
                handoff = handoff_status(context, item['changeId'])
                if handoff.get('handoff_id') and not handoff['pending'] and not handoff['issues']:
                    next_state.setdefault('handoffAuthorizations', {})[item['uid']] = dict(handoffId=handoff['handoff_id'], source=source)
            if legacy:
                next_state.update(revision=state['revision'] + 1, pendingInputs=state['pendingInputs'], handledInputs=state['handledInputs'],
                                  inputDigests=state.get('inputDigests', {}), resumeTask=state.get('resumeTask', ''))
            claim_execution(context, next_state, source)
            state = next_state
        elif action == 'checkpoint':
            if not state:
                raise ValueError('No execution is bound to this session')
            if parameters.get('ExpectedRevision') != state['revision']:
                raise ValueError('Execution revision changed; inspect before checkpoint')
            requested = parameters.get('State', state['state'])
            if requested not in ('running', 'paused', 'blocked', 'released'):
                raise ValueError('Completion and waiting-input are derived states')
            if requested == 'released' and (not parameters.get('SourceRef') or not parameters.get('Reason')):
                raise ValueError('Releasing execution needs its actual source and concrete reason')
            if requested in ('paused', 'blocked') and not parameters.get('Reason', state.get('reason')):
                raise ValueError('A pause or blocker needs a concrete reason')
            if state['state'] in ('paused', 'blocked') and requested == 'running' and not parameters.get('SourceRef'):
                raise ValueError('Resuming a user pause or blocker requires its resolving source')
            pending = {x['id'] for x in state['pendingInputs']}
            acknowledge = parameters.get('AcknowledgeInputs', [])
            if not set(acknowledge) <= pending:
                raise ValueError('Cannot acknowledge unknown input IDs')
            source = parameters.get('SourceRef')
            if requested == 'running' and source:
                queue = operate(context, 'status', {})
                needs_resume = state['state'] in ('paused', 'blocked') or queue['state'] in ('paused', 'pause-requested') or not queue['controller']
                if needs_resume:
                    require_resume_source(state, source)
                if queue['currentChange']:
                    consume_handoff(context, state, queue['currentChange'], source)
                claim_execution(context, state, source, resume=needs_resume)
                if needs_resume:
                    state.setdefault('resumeSources', []).append(source)
                    state['authorizationSource'] = source
            elif requested in ('paused', 'blocked') and source:
                state['pauseSource'] = source
            elif requested == 'released':
                queue = operate(context, 'status', {})
                if queue['controller'] and queue['controller']['sessionId'] == session:
                    if queue['recoveryPending']:
                        raise ValueError('Recover the queue before releasing its controller')
                    operate(context, 'release', {'Token': queue['controller']['token']})
                state.update(released=True, releasedSource=source)
            state['pendingInputs'] = [x for x in state['pendingInputs'] if x['id'] not in acknowledge]
            state['handledInputs'] += acknowledge
            state.update(state=requested, reason=parameters.get('Reason', state.get('reason', '') if requested != 'running' else ''), phase=parameters.get('Phase', state['phase']),
                         resumeTask=parameters.get('ResumeTask', state['resumeTask']), progressRef=parameters.get('ProgressRef', state.get('progressRef', '')),
                         revision=state['revision'] + 1, updatedAt=now())
        elif action == 'input':
            if not state:
                raise ValueError('No execution is bound to this session')
            if derive(context, state)['state'] in ('complete', 'released'):
                raise ValueError('A completed or released execution cannot receive new pending input; route the new intent separately')
            values = {name: parameters.get(name) for name in ('InputId', 'SourceRef', 'Summary', 'Kind')}
            if (values['Kind'] not in ('feedback', 'pause') or
                    any(not isinstance(values[name], str) or not values[name].strip() for name in ('InputId', 'SourceRef', 'Summary')) or
                    len(values['InputId']) > 200 or len(values['SourceRef']) > 2000 or len(values['Summary']) > 4000):
                raise ValueError('Input needs a bounded ID, actual source, summary and feedback/pause kind')
            identity = values['InputId']
            fingerprint = digest(json.dumps(values, sort_keys=True, ensure_ascii=False).encode('utf8'))
            known = state.setdefault('inputDigests', {})
            if identity in known:
                if known[identity] != fingerprint:
                    raise ValueError('Input ID already names different content')
                return derive(context, state)
            if identity in state['handledInputs'] or any(item['id'] == identity for item in state['pendingInputs']):
                return derive(context, state)  # Preserve deduplication for pre-digest input records.
            known[identity] = fingerprint
            state['pendingInputs'].append(dict(id=identity, source=values['SourceRef'], summary=values['Summary'], kind=values['Kind'], receivedAt=now()))
            if values['Kind'] == 'pause':
                state.update(state='paused', reason=values['Summary'], pauseSource=values['SourceRef'])
            state.update(revision=state['revision'] + 1, updatedAt=now())
        else:
            raise ValueError('Unknown execution action')
        path.parent.mkdir(parents=True, exist_ok=True)
        save_state(path, state)
    return derive(context, state)


def validate_handoff_arrangement(context, change, decision, source, arrangement):
    """Validate completed arrangement receipts without deriving or mutating workflow state."""
    _, identity = execution_change(context, change)
    queue = operate(context, 'status', {})
    if queue['recoveryPending']:
        raise ValueError('Queue recovery prevents finalizing the execution arrangement')
    uid = identity['uid']
    members = [item for item in queue['items'] if item['uid'] == uid and item['disposition'] == 'pending']
    owner = queue.get('controller')
    controlled = bool(owner and uid in authorized_pending(queue))
    records = []
    for path in local_path(context['WorkspaceRoot'], 'Saved/Harness/Execution').glob('*.json'):
        record = json.loads(path.read_text('utf8'))
        if record.get('workspaceId') != context['WorkspaceId']:
            raise ValueError('Execution arrangement has mismatched workspace identity')
        if not record.get('released') and uid in record.get('authorizedUids', []):
            records.append(record)
    active = [record for record in records if record.get('state') == 'running']
    if decision == 'now':
        if not members or not controlled or not any(
                record['sessionId'] == owner['sessionId'] and record.get('authorizedHandoffId') == arrangement.get('handoff_id') and
                record.get('authorizationSource') == source for record in active):
            raise ValueError('Execute-now arrangement requires the matching staged queue execution authorization')
    elif decision in ('queue', 'later'):
        if decision == 'queue' and not members:
            raise ValueError('Queue arrangement requires the exact pending Change membership')
        if controlled or active:
            raise ValueError('Queue/later arrangement requires pausing execution and releasing its controller')
    else:
        raise ValueError('Unknown handoff execution arrangement')


def hook(context, payload):
    session = payload.get('session_id', '')
    if not session:
        return {}
    path = state_path(context, session)
    state = load(context, session)
    if not state:
        return {}
    if derive(context, state)['state'] in ('complete', 'released'):
        return {}
    event = payload.get('hook_event_name')
    if event in ('UserPromptSubmit', 'Interrupt'):
        if payload.get('prompt') and payload['prompt'] == state.get('continuationPrompt'):
            return {}  # Generated continuations are not user input.
        summary = payload.get('prompt') or ('User interruption' if event == 'Interrupt' else 'User feedback')
        input_id = payload.get('turn_id') or digest((event + ':' + summary).encode())
        execute(context, 'input', dict(SessionId=session, InputId=input_id, SourceRef=event + ':' + input_id,
                                       Summary=summary[:4000], Kind='pause' if event == 'Interrupt' else 'feedback'))
        return {}
    if event != 'Stop' or payload.get('permission_mode') == 'plan':
        return {}
    current = derive(context, state)
    if current['state'] != 'running':
        return {}
    fingerprint = current['fingerprint']
    with locked(path.parent / 'execution.lock'):
        latest = load(context, session)
        if latest['revision'] != state['revision']:
            return {'systemMessage': 'Execution changed while checking Stop; inspect current Harness state.'}
        if payload.get('stop_hook_active') and latest.get('stopFingerprint') == fingerprint:
            latest.update(state='blocked', reason='Stop continuation made no observable progress; inspect the execution checkpoint.', revision=latest['revision'] + 1)
            save_state(path, latest)
            return {'systemMessage': latest['reason']}
        reason = 'Continue the already authorized Harness execution in workspace ' + context['WorkspaceId'] + '. ' + current['nextAction'] + ' Query harness.execution.status for session ' + session + '; do not start a new scope.'
        latest['stopFingerprint'] = fingerprint
        latest['continuationPrompt'] = reason
        save_state(path, latest)
    return {'decision': 'block', 'reason': reason}
