"""Change-owned discussions. All state is in the indexed Markdown record."""
from datetime import datetime, timezone
from copy import deepcopy
import json
import os
from pathlib import Path
import re
import uuid

from draft_record import digest, local_path, locked
from change_queue import change_path, record_identity

CONVERSATION = '\n## Conversation\n'


def now():
    return datetime.now(timezone.utc).isoformat()


def active_change(context, change):
    root = change_path(context, change)
    identity = record_identity(root / 'change.yaml')
    if identity['id'] != change:
        raise ValueError('Change identity differs from its path')
    return root, identity


def record_path(context, change, talk_id):
    if not re.fullmatch(r'(grill|talk)-[a-z0-9-]+', talk_id):
        raise ValueError('Exact grill- or talk- record ID required')
    root, _ = active_change(context, change)
    return local_path(root, 'attachments/talks/' + talk_id + '.md')


def record_lock(records_root, path):
    return local_path(records_root, 'Saved/Harness/TalkLocks/' + digest(str(path.absolute()).casefold().encode()) + '.lock')


def read_record(path):
    text = path.read_text('utf-8-sig')
    match = re.match(r'\A---\r?\n(.*?)\r?\n---(?:\r?\n|$)', text, re.S)
    if not match:
        if path.name.startswith('grill-'):
            raise ValueError('Grill record lacks structured state')
        return None, text
    if not re.search(r'^talk_schema:', match[1], re.M) and not path.name.startswith('grill-'):
        return None, text
    data = {}
    for line in match[1].splitlines():
        key, sep, value = line.partition(':')
        if not sep or key in data:
            raise ValueError('Invalid or duplicate discussion field')
        try:
            data[key] = json.loads(value.strip())
        except ValueError:
            data[key] = value.strip()
    if data.get('talk_schema') != 'harness-talk-v1':
        if path.name.startswith('grill-') or 'talk_schema' in data:
            raise ValueError('Unsupported discussion schema')
        return None, text
    validate(data)
    if path.stem != data['talk_id'] or CONVERSATION not in text:
        raise ValueError('Discussion identity or conversation boundary is invalid')
    return data, text


def validate(data):
    if data.get('purpose', 'planning') not in ('planning', 'handoff-followup'):
        raise ValueError('Invalid discussion purpose')
    for key in ('talk_id', 'change', 'workspace_id', 'session_id', 'summary', 'source_ref'):
        if not isinstance(data.get(key), str) or not data[key].strip():
            raise ValueError('Discussion needs ' + key)
    if data.get('status') not in ('open', 'settled', 'closed', 'superseded'):
        raise ValueError('Invalid discussion status')
    if data.get('scope') not in ('current-change', 'followup') or not isinstance(data.get('revision'), int):
        raise ValueError('Invalid discussion scope or revision')
    questions = data.get('questions', [])
    if not isinstance(questions, list) or len({q.get('id') for q in questions}) != len(questions):
        raise ValueError('Questions require unique IDs')
    for question in questions:
        if not question.get('id') or not question.get('question'):
            raise ValueError('Question identity and text required')
        if question.get('answer') and not question.get('source'):
            raise ValueError('An answer requires its actual source')
    if data['status'] == 'settled' and any(not q.get('answer') or not q.get('source') for q in questions):
        raise ValueError('Every necessary question needs an actual answer and source')
    if data['status'] in ('closed', 'superseded') and not data.get('disposition'):
        raise ValueError('Terminal discussion needs a disposition')
    if data['status'] == 'superseded' and not data.get('replacement_talk_id'):
        raise ValueError('Superseded discussion needs its exact replacement talk')
    if data['status'] == 'closed':
        if data['disposition'] not in ('applied', 'no-change', 'deferred', 'rejected'):
            raise ValueError('Invalid closed discussion disposition')
        if data['disposition'] == 'deferred' and data['scope'] != 'followup':
            raise ValueError('Current Change decisions cannot be deferred to bypass execution')
        if (data.get('purpose', 'planning') == 'planning' and data['scope'] == 'current-change'
                and data['disposition'] in ('no-change', 'rejected')
                and any(not q.get('answer') or not q.get('source') for q in questions)
                and not str(data.get('resolution_source', '')).strip()):
            raise ValueError('Unanswered decisions need an actual resolution source for rejection or no-change')
    from handoff import validate_followup
    validate_followup(data)


def render(data, old=''):
    original = old.split(CONVERSATION, 1)[1] if CONVERSATION in old else ''
    header = '\n'.join(key + ': ' + json.dumps(value, ensure_ascii=False) for key, value in data.items())
    view = '\n'.join('- ' + str(q['id']) + ': ' + q['question'] + (' — ' + str(q['answer']) if q.get('answer') else ' (awaiting answer)') for q in data['questions'])
    return ('---\n' + header + '\n---\n\n# Discussion\n\n- Summary: ' + data['summary'] +
            '\n- State: ' + data['status'] + '\n- Resume task: ' + data.get('resume_task', '') +
            '\n\n## Decisions\n\n' + view + '\n' + CONVERSATION + original)


def write_text(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_name(path.name + '.' + uuid.uuid4().hex + '.tmp')
    try:
        with temp.open('w', encoding='utf8', newline='\n') as stream:
            stream.write(text)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temp, path)
    finally:
        temp.unlink(missing_ok=True)


def indexed(index, data):
    relative = 'talks/' + data['talk_id'] + '.md'
    lines = [line for line in index.splitlines() if relative not in line]
    lines.append('- ' + relative + ' — ' + data['status'] + ' — ' + data['summary'].replace('\n', ' '))
    if len(lines) > 120:
        raise ValueError('INDEX exceeds 120 lines; consolidate navigation first')
    return '\n'.join(lines) + '\n'


def pending_questions(data):
    return [q for q in data['questions'] if not q.get('answer') or not q.get('source')]


def is_resolved(data):
    return (data['status'] == 'closed' and data.get('disposition') in ('no-change', 'rejected')
            and bool(str(data.get('resolution_source', '')).strip()))


def require_decisions(questions, replacement):
    if is_resolved(replacement):
        return
    current = {q['id']: q for q in replacement['questions']}
    for question in questions:
        if question['id'] not in current or current[question['id']]['question'] != question['question']:
            raise ValueError('Replacement must retain each pending decision or its actual resolution')


def replacement_record(context, data, index_text):
    path = record_path(context, data['change'], data['replacement_talk_id'])
    replacement, text = read_record(path)
    if (not replacement or any(replacement.get(key) != data.get(key) for key in ('change', 'scope', 'workspace_id'))
            or replacement.get('purpose', 'planning') != 'planning'):
        raise ValueError('Replacement discussion must have the same Change, scope and workspace owner')
    if index_text.count('talks/' + path.name) != 1:
        raise ValueError('Replacement discussion requires exact INDEX membership')
    return path, replacement, text


def validate_supersession(context, data, index_text):
    seen = {data['talk_id']}
    while data['status'] == 'superseded':
        _, replacement, _ = replacement_record(context, data, index_text)
        if replacement['talk_id'] in seen:
            raise ValueError('Discussion supersession cycle')
        seen.add(replacement['talk_id'])
        if not any(source.get('talk_id') == data['talk_id'] and source.get('source_ref') == data['source_ref']
                   for source in replacement.get('supersession_sources', [])):
            raise ValueError('Replacement discussion is missing transferred decision provenance')
        require_decisions(pending_questions(data), replacement)
        data = replacement
    return data


def talk(context, action, parameters):
    root, identity = active_change(context, parameters['Change'])
    folder = root / 'attachments/talks'
    index = root / 'attachments/INDEX.md'
    if action == 'status':
        records, issues = [], []
        index_text = index.read_text('utf-8-sig') if index.exists() else ''
        paths = [record_path(context, parameters['Change'], parameters['TalkId'])] if parameters.get('TalkId') else sorted(folder.glob('*.md'))
        for path in paths:
            try:
                path = local_path(root, 'attachments/talks/' + path.name)
                data, _ = read_record(path)
                if data:
                    if data['change'] != parameters['Change']:
                        raise ValueError('Discussion belongs to another Change')
                    if index_text.count('talks/' + path.name) != 1:
                        raise ValueError('Discussion requires exact INDEX membership')
                    current = validate_supersession(context, data, index_text)
                    records.append(data)
                    if current['talk_id'] != data['talk_id']:
                        records.append(current)
            except (ValueError, OSError) as error:
                issues.append(path.name + ': ' + str(error))
        records = list({record['talk_id']: record for record in records}.values())
        blockers = [x['talk_id'] for x in records if x['scope'] == 'current-change' and x['status'] in ('open', 'settled')]
        return dict(records=records, blockers=blockers, issues=issues, executionAllowed=not (blockers or issues))
    if action not in ('create', 'update') or not parameters.get('SessionId'):
        raise ValueError('Discussion mutation requires an action and exact session')
    assignment = root / 'attachments/data/harness-execution.json'
    if assignment.exists():
        assigned = json.loads(assignment.read_text('utf8'))
        if assigned.get('workspaceId') != context['WorkspaceId']:
            raise ValueError('Change is assigned to another workspace')
    lock = local_path(context['OpenSpecRoot'], 'Saved/Harness/TalkLocks/' + digest(identity['uid'].encode()) + '.lock')
    with locked(lock):
        if action == 'create':
            kind, theme = parameters.get('Kind', 'talk'), parameters.get('Theme', '')
            if kind not in ('talk', 'grill') or not re.fullmatch('[a-z0-9]+(?:-[a-z0-9]+)*', theme):
                raise ValueError('Discussion kind and kebab-case theme required')
            talk_id = kind + '-' + datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S') + '-' + theme + '-' + uuid.uuid4().hex[:6]
            data = dict(talk_schema='harness-talk-v1', talk_id=talk_id, change=parameters['Change'],
                        workspace_id=context['WorkspaceId'], workspace_root=context['WorkspaceRoot'], session_id=parameters['SessionId'], revision=1,
                        status=parameters.get('Status', 'open'), scope=parameters.get('Scope', 'current-change'),
                        summary=parameters.get('Summary', ''), source_ref=parameters.get('SourceRef', ''),
                        questions=parameters.get('Questions', []), resume_task=parameters.get('ResumeTask', ''),
                        purpose=parameters.get('Purpose', 'planning'), arrangements=parameters.get('Arrangements', {}),
                        replacement_talk_id=parameters.get('ReplacementTalkId', ''), resolution_source=parameters.get('ResolutionSource', ''),
                        disposition=parameters.get('Disposition', ''), created_at=now(), updated_at=now(), history=[])
            path = record_path(context, parameters['Change'], talk_id)
        else:
            path = record_path(context, parameters['Change'], parameters['TalkId'])
        with locked(record_lock(context['OpenSpecRoot'], path)):
            old = ''
            if action == 'update':
                data, old = read_record(path)
                if not data or data['workspace_id'] != context['WorkspaceId']:
                    raise ValueError('Discussion workspace identity differs')
                if parameters.get('ExpectedRevision') != data['revision']:
                    raise ValueError('Discussion revision changed; reload before updating')
                if data['status'] in ('closed', 'superseded'):
                    raise ValueError('Closed discussion is historical; create a linked follow-up')
                previous = deepcopy(data)
                data['history'].append({k: data[k] for k in ('revision', 'status', 'summary', 'questions', 'updated_at')})
                for argument, key in [('Status', 'status'), ('Summary', 'summary'), ('Questions', 'questions'), ('ResumeTask', 'resume_task'), ('Disposition', 'disposition'), ('Arrangements', 'arrangements'), ('ReplacementTalkId', 'replacement_talk_id'), ('ResolutionSource', 'resolution_source')]:
                    if argument in parameters:
                        data[key] = parameters[argument]
                data['revision'] += 1
                data['updated_at'] = now()
                if (data.get('purpose', 'planning') == 'planning'
                        and (previous.get('supersession_sources') or data['status'] in ('closed', 'superseded'))):
                    require_decisions(pending_questions(previous), data)
            if data['disposition'] == 'applied':
                raise ValueError('Only successful Replan application can mark a discussion applied')
            validate(data)
            from handoff import validate_arrangements
            validate_arrangements(context, parameters['Change'], data)
            index_text = index.read_text('utf-8-sig') if index.exists() else '# INDEX\n'
            if data['status'] == 'superseded':
                if data['replacement_talk_id'] == data['talk_id']:
                    raise ValueError('Discussion cannot replace itself')
                replacement_path = record_path(context, data['change'], data['replacement_talk_id'])
                with locked(record_lock(context['OpenSpecRoot'], replacement_path)):
                    _, replacement, replacement_text = replacement_record(context, data, index_text)
                    if replacement['status'] not in ('open', 'settled'):
                        raise ValueError('Replacement must be an active discussion, without a supersession cycle')
                    replacement['history'].append({k: deepcopy(replacement[k]) for k in ('revision', 'status', 'summary', 'questions', 'updated_at')})
                    existing = {q['id']: q for q in replacement['questions']}
                    for question in pending_questions(data):
                        if question['id'] in existing and existing[question['id']]['question'] != question['question']:
                            raise ValueError('Replacement has a conflicting pending question identity')
                        if question['id'] not in existing:
                            replacement['questions'].append(deepcopy(question))
                    replacement.setdefault('supersession_sources', []).append({k: deepcopy(data[k]) for k in ('talk_id', 'revision', 'source_ref', 'questions', 'resume_task')})
                    replacement['revision'] += 1
                    replacement['updated_at'] = now()
                    validate(replacement)
                    index_text = indexed(indexed(index_text, replacement), data)
                    # Write the blocking replacement first. Interrupted publication
                    # can leave both records open, but cannot drop the decision.
                    write_text(replacement_path, render(replacement, replacement_text))
            else:
                index_text = indexed(index_text, data)
            write_text(path, render(data, old))
            write_text(index, index_text)
            return data
