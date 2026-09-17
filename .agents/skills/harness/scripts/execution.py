"""Explicit session execution bindings and derived continuation decisions."""
import json
from pathlib import Path
import re

from draft_record import digest, local_path, locked, save_state
from discussions import active_change, now
from replans import replan_status, native
from change_queue import operate, inspect_record


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
    progress = []
    try:
        if state['scope'] == 'Queue':
            queue = operate(context, 'status', {})
            progress.append(queue)
            result['change'] = queue['currentChange']
            result['changeUid'] = next((item['uid'] for item in queue['items'] if item['disposition'] == 'pending'), None)
            if queue['recoveryPending']:
                result.update(state='blocked', reason='Queue recovery required')
            elif queue['state'] in ('paused', 'pause-requested'):
                result.update(state='paused', reason=queue['pauseReason'])
            elif queue['controller'] and queue['controller']['sessionId'] != state['sessionId']:
                result.update(state='blocked', reason='Queue belongs to another session')
            elif queue['configured'] and not queue['currentChange']:
                result['state'] = 'complete'
            elif queue['recordState'] == 'archive-pending':
                result.update(phase='advancing', nextAction='Advance the completed archive, then continue the queue.')
            elif queue['recordState'] == 'record-blocked':
                result.update(state='blocked', reason='; '.join(queue['recordIssues']))
        else:
            record = inspect_record(context, {'changeId': state['change'], 'uid': state['changeUid']})
            if record['recordState'] == 'archive-pending':
                result['state'] = 'complete'
            elif record['recordState'] != 'active':
                result.update(state='blocked', reason='; '.join(record['recordIssues']))
        if state['state'] in ('paused', 'blocked'):
            result.update(state=state['state'], reason=state.get('reason', ''))
        if result['state'] == 'running' and result.get('change') and result['phase'] != 'advancing':
            execution_change(context, result['change'])
            replans = replan_status(context, result['change'])
            progress.append(replans)
            if replans['recoveryNeeded'] or replans['discussions']['issues']:
                result.update(state='blocked', reason='Replan recovery or discussion repair required')
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
            result.update(state=result['state'] if result['state'] in ('paused', 'blocked') else 'running', phase='feedback-pending',
                          implementationAllowed=False, nextAction='Triage the pending user input without replacing the authorized scope; acknowledge its ID.')
        if result['state'] != 'running':
            result['implementationAllowed'] = False
        result['fingerprint'] = digest(json.dumps([progress, state['phase'], state.get('resumeTask'), state.get('progressRef'), state['pendingInputs']], sort_keys=True).encode())
    except (ValueError, OSError) as error:
        result.update(state='blocked', reason=str(error), implementationAllowed=False, issues=[str(error)])
    return result

def execute(context, action, parameters):
    session = parameters.get('SessionId', '')
    path = state_path(context, session)
    if action == 'status':
        state = load(context, session)
        return derive(context, state) if state else {'state': 'unbound', 'revision': 0, 'implementationAllowed': False}
    with locked(path.parent / 'execution.lock'):
        state = load(context, session)
        if action == 'start':
            scope = parameters.get('Scope')
            if scope not in ('Change', 'Queue') or not parameters.get('SourceRef'):
                raise ValueError('Explicit Change/Queue execution scope and authorization source required')
            if state and derive(context, state)['state'] not in ('complete', 'released'):
                if state['scope'] != scope or (scope == 'Change' and state['change'] != parameters.get('Change')):
                    raise ValueError('Session already has another unfinished execution request')
                return derive(context, state)
            change = parameters.get('Change', '')
            transfers = []
            for other in path.parent.glob('*.json'):
                previous = json.loads(other.read_text('utf8'))
                if previous['sessionId'] != session and (scope == 'Queue' or previous['scope'] == 'Queue' or previous.get('change') == change):
                    if derive(context, previous)['state'] not in ('complete', 'released'):
                        if not parameters.get('PreviousSessionStopped') or parameters.get('PreviousSessionId') != previous['sessionId']:
                            raise ValueError('Another session owns execution; explicitly stop and transfer its binding before starting')
                        previous.update(released=True, releasedTo=session, revision=previous['revision'] + 1)
                        transfers.append((other, previous))
            if scope == 'Queue':
                queue = operate(context, 'claim', {'SessionId': session})
                change = queue['currentChange']
                uid = next((item['uid'] for item in queue['items'] if item['disposition'] == 'pending'), None)
            else:
                uid = execution_change(context, change)[1]['uid']
            state = dict(schema=1, workspaceId=context['WorkspaceId'], workspaceRoot=context['WorkspaceRoot'], sessionId=session,
                         scope=scope, change=change, changeUid=uid, sourceRef=parameters['SourceRef'], state='running', phase='planning',
                         revision=1, pendingInputs=[], handledInputs=[], resumeTask='', reason='', updatedAt=now())
        elif action == 'checkpoint':
            if not state:
                raise ValueError('No execution is bound to this session')
            if parameters.get('ExpectedRevision') != state['revision']:
                raise ValueError('Execution revision changed; inspect before checkpoint')
            requested = parameters.get('State', state['state'])
            if requested not in ('running', 'paused', 'blocked'):
                raise ValueError('Completion and waiting-input are derived states')
            if requested in ('paused', 'blocked') and not parameters.get('Reason', state.get('reason')):
                raise ValueError('A pause or blocker needs a concrete reason')
            if state['state'] in ('paused', 'blocked') and requested == 'running' and not parameters.get('SourceRef'):
                raise ValueError('Resuming a user pause or blocker requires its resolving source')
            pending = {x['id'] for x in state['pendingInputs']}
            acknowledge = parameters.get('AcknowledgeInputs', [])
            if not set(acknowledge) <= pending:
                raise ValueError('Cannot acknowledge unknown input IDs')
            state['pendingInputs'] = [x for x in state['pendingInputs'] if x['id'] not in acknowledge]
            state['handledInputs'] += acknowledge
            state.update(state=requested, reason=parameters.get('Reason', ''), phase=parameters.get('Phase', state['phase']),
                         resumeTask=parameters.get('ResumeTask', state['resumeTask']), progressRef=parameters.get('ProgressRef', state.get('progressRef', '')),
                         revision=state['revision'] + 1, updatedAt=now())
        else:
            raise ValueError('Unknown execution action')
        path.parent.mkdir(parents=True, exist_ok=True)
        save_state(path, state)
        if action == 'start':
            for other, previous in transfers:
                save_state(other, previous)
    return derive(context, state)

def hook(context, payload):
    session = payload.get('session_id', '')
    if not session:
        return {}
    path = state_path(context, session)
    state = load(context, session)
    if not state:
        return {}
    event = payload.get('hook_event_name')
    if event in ('UserPromptSubmit', 'Interrupt'):
        with locked(path.parent / 'execution.lock'):
            state = load(context, session)
            if event == 'Interrupt':
                state.update(state='paused', reason='User interruption')
            else:
                if payload.get('prompt') and payload['prompt'] == state.get('continuationPrompt'):
                    return {}  # A Stop continuation is not a new user-owned decision.
                input_id = payload.get('turn_id') or digest(payload.get('prompt', '').encode())
                if input_id not in state['handledInputs'] and input_id not in [x['id'] for x in state['pendingInputs']]:
                    state['pendingInputs'].append(dict(id=input_id, source='UserPromptSubmit', receivedAt=now()))
            state.update(revision=state['revision'] + 1, updatedAt=now())
            save_state(path, state)
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
