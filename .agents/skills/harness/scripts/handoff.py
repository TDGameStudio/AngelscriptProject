"""Small handoff receipts: explicit sources, exact content, and existing talks."""
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import sys
import uuid

from draft_record import digest, local_path


def fingerprint(value):
    return digest(json.dumps(value, sort_keys=True, ensure_ascii=False, separators=(',', ':')).encode('utf8'))


def receipt_instant(receipt):
    value = receipt.get('created_at')
    if not isinstance(value, str) or not value:
        raise ValueError('Handoff receipt needs a timezone-aware created_at timestamp')
    try:
        instant = datetime.fromisoformat(value.replace('Z', '+00:00'))
    except ValueError:
        raise ValueError('Handoff receipt has an invalid created_at timestamp') from None
    if instant.tzinfo is None or instant.utcoffset() is None:
        raise ValueError('Handoff receipt created_at must include its timezone')
    return instant.astimezone(timezone.utc)


def metadata(text, key):
    match = re.search(r'^' + re.escape(key) + r':\s*([^\r\n]+)', text, re.M)
    return match[1].strip().strip('\"\'') if match else ''


def draft_inputs(context, draft_id, scope, target):
    if not re.fullmatch(r'[a-z0-9]+(?:-[a-z0-9]+)*/[a-z0-9]+(?:-[a-z0-9]+)*', draft_id or '') or not re.fullmatch(r'[a-z0-9]+(?:-[a-z0-9]+)*', scope or ''):
        raise ValueError('Exact safe DraftId and Scope required')
    root = local_path(context['OpenSpecRoot'], 'openspec/drafts/' + draft_id)
    selected = local_path(root, 'designs/' + scope)
    readme = (root / 'README.md').read_text('utf-8-sig')
    if metadata(readme, 'draft') != draft_id:
        raise ValueError('Draft identity differs from its selected path')
    modern = metadata(readme, 'schema') == 'harness-draft-v2'
    if modern and not local_path(root, 'CONTEXT.md').is_file():
        raise ValueError('Modern draft is missing CONTEXT.md')
    design = local_path(selected, 'design.md')
    handoff = local_path(selected, 'handoff.md')
    owner = design if modern else local_path(selected, 'README.md')
    owner_text = owner.read_text('utf-8-sig')
    frontmatter = re.match(r'\A---\r?\n(.*?)\r?\n---(?:\r?\n|$)', owner_text, re.S)
    if not frontmatter or metadata(frontmatter[1], 'design') != scope or metadata(frontmatter[1], 'status') != 'designed':
        raise ValueError('Selected design must identify its scope and be designed')
    text = handoff.read_text('utf-8-sig')
    for key, expected in [('Scope', scope), ('Target Change', target)]:
        matches = re.findall(r'^- ' + re.escape(key) + r':\s*`?([^`\r\n]+)`?\s*$', text, re.M)
        if len(matches) != 1 or matches[0].strip() != expected:
            raise ValueError('Handoff needs exact ' + key)
    if '## Exploration Carryover' not in text:
        raise ValueError('Handoff needs Exploration Carryover')
    exports, inputs = [], {}
    for line in text.split('## Exploration Carryover', 1)[1].split('\n## ', 1)[0].splitlines():
        columns = [x.strip().strip('`') for x in line.strip().strip('|').split('|')]
        if not line.startswith('|') or len(columns) != 3 or columns[0] == 'Source' or re.fullmatch(r'[:\-]+', columns[0]):
            continue
        source, destination, reason = columns
        if not re.fullmatch(r'attachments/(?:drafts|talks|knowledges|data)/[a-zA-Z0-9_./-]+', destination) or '..' in destination.split('/') or not reason:
            raise ValueError('Unsafe or incomplete carryover target')
        if destination in [x['Target'] for x in exports]:
            raise ValueError('Duplicate carryover target')
        if source == 'not-applicable':
            if destination != 'attachments/drafts/glossary.md':
                raise ValueError('Only legacy glossary may be inapplicable')
        else:
            path = (selected / source.split('#', 1)[0]).resolve()
            relative = path.relative_to(root.resolve()).as_posix()
            path = local_path(root, relative)
            if not path.is_file():
                raise ValueError('Carryover source is missing: ' + source)
            inputs[relative] = digest(path.read_bytes())
        exported = dict(Source=source, Target=destination, Reason=reason, Preservation='translated-text')
        if source != 'not-applicable' and path.suffix.lower() != '.md':
            exported.update(Preservation='bytes', Sha256=inputs[relative])
        exports.append(exported)
    required = ['attachments/drafts/design.md', 'attachments/drafts/handoff.md']
    if not modern:
        required.append('attachments/drafts/glossary.md')
    if any(name not in [x['Target'] for x in exports] for name in required):
        raise ValueError('Carryover omits a required selected design export')
    # Follow local dependencies so an evidence edit invalidates an unconsumed answer.
    pending = [design, handoff] + [root / path for path in inputs]
    seen = set()
    while pending:
        path = pending.pop()
        relative = path.resolve().relative_to(root.resolve()).as_posix()
        path = local_path(root, relative)
        if relative in seen:
            continue
        seen.add(relative)
        inputs[relative] = digest(path.read_bytes())
        if path.suffix.lower() != '.md':
            continue
        for link in re.findall(r'\]\(([^)]+)\)', path.read_text('utf-8-sig')):
            if re.match(r'^(?:https?:|mailto:|#)', link):
                continue
            dependency = (path.parent / link.split('#', 1)[0]).resolve()
            try:
                dependency_relative = dependency.relative_to(root.resolve()).as_posix()
            except ValueError:
                continue  # Repository evidence outside the draft is not exported implicitly.
            dependency = local_path(root, dependency_relative)
            if not dependency.is_file():
                raise ValueError('Selected design dependency is missing: ' + link)
            pending.append(dependency)
    return dict(DraftId=draft_id, Scope=scope, ChangeId=target, Path=str(selected), Schema=2 if modern else 1,
                ApprovalRound=metadata(frontmatter[1], 'approval_round'), ExpectedExports=exports, Inputs=inputs)


def preview(context, operation, parameters, historical=False):
    target = parameters.get('ChangeId', parameters.get('Change', ''))
    draft = None
    if parameters.get('DraftId'):
        draft = draft_inputs(context, parameters['DraftId'], parameters.get('Scope', ''), target)
        if historical:
            draft['ExpectedExports'] = [{key: entry[key] for key in ('Source', 'Target', 'Reason')}
                                        for entry in draft['ExpectedExports']]
    body = parameters.get('HandoffText', '')
    if not draft and not str(body).strip():
        raise ValueError('Direct handoff requires the concrete displayed HandoffText')
    basis = dict(operation=operation, target=target, draft=draft,
                 handoff_text=body, title='' if historical and draft else parameters.get('Title', ''),
                 goal='' if historical and draft else parameters.get('Goal', ''),
                 reason='' if draft else parameters.get('Reason', ''), candidates=parameters.get('Candidates', {}),
                 baselines=parameters.get('ExpectedHashes', {}))
    return dict(HandoffRevision=fingerprint(basis), DraftRevision=fingerprint(draft) if draft else None,
                Operation=operation, ChangeId=target, Draft=draft, Ready=True)


def consume_gate(context, operation, parameters, prepared=None):
    prepared = prepared or preview(context, operation, parameters)
    gate = parameters.get('Gate')
    if not isinstance(gate, dict):
        raise ValueError('An explicit user handoff Gate is required')
    for key in ('ConvergenceSource', 'DecisionSource', 'Decision', 'TargetChange', 'HandoffRevision'):
        if not isinstance(gate.get(key), str) or not gate[key].strip():
            raise ValueError('Gate requires actual ' + key)
    if gate['Decision'] != operation or gate['TargetChange'] != prepared['ChangeId']:
        raise ValueError('Gate decision or exact target differs')
    if gate['HandoffRevision'] != prepared['HandoffRevision']:
        raise ValueError('Gate design revision is stale; show the changed design and ask again')
    stamp = datetime.now(timezone.utc)
    identity = 'handoff-' + uuid.uuid4().hex[:16]
    return dict(schema='harness-handoff-v1', handoff_id=identity, operation=operation,
                revision_schema=2, export_digest_schema=1,
                expected_exports=prepared['Draft']['ExpectedExports'] if prepared.get('Draft') else [],
                target_change=prepared['ChangeId'], revision=prepared['HandoffRevision'],
                convergence_source=gate['ConvergenceSource'], decision_source=gate['DecisionSource'],
                decision=gate['Decision'], created_at=stamp.isoformat(),
                draft_id=parameters.get('DraftId') or None, scope=parameters.get('Scope') or None,
                session_id=parameters.get('SessionId'), workspace_id=context.get('WorkspaceId', context['WorkspaceRoot']),
                post_talk_id='grill-' + stamp.strftime('%Y%m%d-%H%M%S') + '-' + identity)


def followup_record(context, change, session, receipt):
    from discussions import now
    if not session:
        raise ValueError('Handoff requires the exact SessionId for its follow-up')
    has_draft = bool(receipt.get('draft_id'))
    return dict(talk_schema='harness-talk-v1', talk_id=receipt['post_talk_id'], change=change,
                workspace_id=context.get('WorkspaceId', context['WorkspaceRoot']), workspace_root=context['WorkspaceRoot'],
                session_id=session, revision=1, status='open', scope='current-change', purpose='handoff-followup',
                summary='Choose the draft disposition and execution arrangement.', source_ref=receipt['decision_source'],
                handoff_id=receipt['handoff_id'], draft_id=receipt.get('draft_id'),
                questions=[dict(id='draft-disposition', question='Archive the draft or retain it for discussion?',
                                answer=None if has_draft else 'not-applicable', source=None if has_draft else 'not-applicable:no-draft'),
                           dict(id='execution-disposition', question='Execute now, queue for later, or leave execution paused?', answer=None, source=None)],
                arrangements={}, resume_task='', disposition='', created_at=now(), updated_at=now(), history=[])


def validate_followup(data):
    if data.get('purpose', 'planning') != 'handoff-followup':
        return
    if data.get('scope') != 'current-change' or data.get('status') == 'superseded':
        raise ValueError('Handoff follow-up cannot be deferred or superseded to bypass its decisions')
    questions = {q['id']: q for q in data.get('questions', [])}
    if set(questions) != {'draft-disposition', 'execution-disposition'}:
        raise ValueError('Handoff requires both exact disposition questions')
    choices = {'draft-disposition': ('archive', 'retain', 'not-applicable'), 'execution-disposition': ('now', 'queue', 'later')}
    for identity, question in questions.items():
        if question.get('answer') and question['answer'] not in choices[identity]:
            raise ValueError('Invalid handoff disposition answer')
        if identity == 'draft-disposition' and question.get('answer') == 'not-applicable' and data.get('draft_id'):
            raise ValueError('A real draft needs its actual disposition answer')
    if data.get('status') == 'closed':
        if data.get('disposition') != 'no-change' or any(not q.get('answer') or not q.get('source') for q in questions.values()):
            raise ValueError('Handoff closure requires both actual answers')
        arrangements = data.get('arrangements', {})
        for identity in ('draft', 'execution'):
            item = arrangements.get(identity, {})
            question = questions[identity + '-disposition']
            if item.get('status') != 'applied' or item.get('source') != question['source'] or item.get('decision') != question['answer']:
                raise ValueError('Handoff closure requires applied arrangements matching actual answers')


def validate_arrangements(context, change, data):
    validate_followup(data)
    if data.get('purpose') != 'handoff-followup' or data.get('status') != 'closed':
        return
    questions = {q['id']: q for q in data['questions']}
    draft = questions['draft-disposition']['answer']
    if data.get('draft_id'):
        original = local_path(context['OpenSpecRoot'], 'openspec/drafts/' + data['draft_id'])
        if draft == 'retain' and not original.is_dir():
            raise ValueError('Retained draft is missing')
        if draft == 'archive':
            target = Path(data['arrangements']['draft'].get('path', ''))
            archive_root = Path(context['OpenSpecRoot']) / 'openspec/archive/drafts'
            try:
                relative = target.resolve().relative_to(archive_root.resolve())
            except ValueError:
                raise ValueError('Archive arrangement must name the actual draft archive')
            target = local_path(archive_root, relative.as_posix())
            if original.exists() or not (target / 'README.md').is_file() or metadata((target / 'README.md').read_text('utf-8-sig'), 'draft') != data['draft_id']:
                raise ValueError('Draft archive arrangement has not taken effect')
    from execution import validate_handoff_arrangement
    execution = questions['execution-disposition']
    arrangement = {**data['arrangements']['execution'], 'handoff_id': data['handoff_id']}
    validate_handoff_arrangement(context, change, execution['answer'], execution['source'], arrangement)


def get_handoff_status(context, change):
    from discussions import active_change, read_record
    from replans import decode_applied
    root, _ = active_change(context, change)
    result = dict(handoff_id=None, pending=False, issues=[], execution_decision=None, execution_source=None, questions=[])
    receipts = []
    origin = root / 'attachments/data/harness-origin.json'
    try:
        if origin.exists():
            marker = json.loads(origin.read_text('utf-8-sig'))
            if marker.get('schema') == 3:
                if not marker.get('gate'):
                    raise ValueError('New origin is missing its handoff receipt')
                receipts.append(marker['gate'])
        for path in (root / 'attachments/replans').glob('*.md'):
            if not re.search(r'^(?:handoff|handoff_schema):', path.read_text('utf-8-sig'), re.M):
                continue  # Historical applied records retain their earlier format and authority.
            record = decode_applied(path)
            if record.get('handoff_schema') and not record.get('handoff'):
                raise ValueError('Applied Replan is missing its handoff receipt')
            if record.get('handoff'):
                receipts.append(record['handoff'])
        if not receipts:
            return result
        # PowerShell JSON round trips can retain the same instant with a local offset.
        receipts.sort(key=receipt_instant)
        index = (root / 'attachments/INDEX.md').read_text('utf-8-sig')
        for receipt in receipts:
            if receipt.get('schema') != 'harness-handoff-v1' or receipt.get('target_change') != change or not receipt.get('handoff_id'):
                raise ValueError('Invalid formal handoff receipt')
            name = receipt.get('post_talk_id', '')
            if not re.fullmatch(r'grill-[a-z0-9-]+', name):
                raise ValueError('Handoff receipt lacks its exact follow-up identity')
            path = local_path(root, 'attachments/talks/' + name + '.md')
            if not path.is_file() or index.count('talks/' + name + '.md') != 1:
                raise ValueError('Expected handoff follow-up is missing or not indexed')
            record, _ = read_record(path)
            if not record or record.get('purpose') != 'handoff-followup' or record.get('handoff_id') != receipt['handoff_id']:
                raise ValueError('Handoff follow-up identity or purpose differs')
            result['pending'] |= record['status'] != 'closed'
            if receipt is receipts[-1]:
                execution = next(q for q in record['questions'] if q['id'] == 'execution-disposition')
                result.update(handoff_id=receipt['handoff_id'], questions=record['questions'],
                              execution_decision=execution.get('answer'), execution_source=execution.get('source'))
    except (ValueError, OSError, KeyError, TypeError) as error:
        result['issues'].append(str(error))
        result['pending'] = True
    return result


def main():
    payload = json.load(sys.stdin)
    context, parameters = payload['context'], payload.get('parameters', {})
    context.setdefault('OpenSpecRoot', context['WorkspaceRoot'])
    action = sys.argv[1]
    if action == 'draft-check':
        result = draft_inputs(context, parameters['DraftId'], parameters['Scope'], parameters['ChangeId'])
        result['DraftRevision'] = fingerprint(result)
    elif action in ('create-preview', 'create-preview-legacy'):
        result = preview(context, 'create', parameters, historical=action == 'create-preview-legacy')
    elif action == 'create-receipt':
        receipt = consume_gate(context, 'create', parameters)
        result = dict(receipt=receipt, followup=followup_record(context, parameters['ChangeId'], parameters.get('SessionId'), receipt))
    elif action in ('write-followup', 'restore-followup'):
        from discussions import write_text, render, indexed
        root = local_path(context['OpenSpecRoot'], 'openspec/changes/' + parameters['ChangeId'])
        if action == 'restore-followup':
            marker = json.loads((root / 'attachments/data/harness-origin.json').read_text('utf-8-sig'))
            receipt = marker['gate']
            if receipt.get('workspace_id') != context.get('WorkspaceId', context['WorkspaceRoot']):
                raise ValueError('Creation recovery belongs to another workspace')
            record = followup_record(context, parameters['ChangeId'], receipt['session_id'], receipt)
            existing = root / ('attachments/talks/' + record['talk_id'] + '.md')
            if existing.exists():
                from discussions import read_record
                record, _ = read_record(existing)
                if not record or record.get('handoff_id') != receipt['handoff_id']:
                    raise ValueError('Creation follow-up conflicts with its receipt')
        else:
            record = parameters['Followup']
        index = root / 'attachments/INDEX.md'
        text = index.read_text('utf-8-sig') if index.exists() else '# INDEX\n'
        origin = 'data/harness-origin.json'
        if origin not in text:
            text += '- [Origin](' + origin + ')\n'
        path = root / ('attachments/talks/' + record['talk_id'] + '.md')
        if not path.exists():
            write_text(path, render(record))
        write_text(index, indexed(text, record))
        result = record
    elif action == 'status':
        result = get_handoff_status(context, parameters['Change'])
    else:
        raise ValueError('Unknown handoff action')
    print(json.dumps(result, ensure_ascii=False))


if __name__ == '__main__':
    try:
        main()
    except Exception as error:
        print(json.dumps({'error': str(error)}))
        sys.exit(1)
