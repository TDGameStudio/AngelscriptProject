"""Validated optimistic application of an exact Change's planning artifacts."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import uuid

from discussions import active_change, record_path, record_lock, read_record, render, indexed, now, write_text, talk
from draft_record import digest, local_path, locked, save_state


def native(context, arguments, cwd=None):
    executable = local_path(context['HarnessRoot'], '.agents/skills/openspec/bin/openspec.exe')
    result = subprocess.run([str(executable), *arguments], cwd=cwd or context['OpenSpecRoot'], capture_output=True, text=True, encoding='utf8', timeout=60)
    if result.returncode:
        raise ValueError('OpenSpec validation/query failed: ' + (result.stdout + result.stderr)[-3000:])
    return json.loads(result.stdout)


def current_hash(path):
    return digest(path.read_bytes()) if path.exists() else None


def task_cards(text):
    matches = list(re.finditer(r'^## \[[ xX]\] ([0-9]+\.[0-9]+)\b', text, re.M))
    return {match[1]: text[match.start():matches[i + 1].start() if i + 1 < len(matches) else len(text)].strip()
            for i, match in enumerate(matches)}


def plan_edges(plan):
    return {dependency + ' -> ' + task['id'] for task in plan.get('tasks', []) for dependency in task.get('after', [])}


def journal_path(context, identity):
    return local_path(context['OpenSpecRoot'], 'Saved/Harness/Replans/' + digest(identity['uid'].encode()) + '.json')


def write_bytes(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    temp = path.with_name(path.name + '.' + uuid.uuid4().hex + '.tmp')
    try:
        temp.write_bytes(data)
        os.replace(temp, path)
    finally:
        temp.unlink(missing_ok=True)


def recover(root, journal):
    if not journal.exists():
        return
    transaction = json.loads(journal.read_text('utf8'))
    for item in transaction['writes']:
        path = local_path(root, item['path'])
        actual = path.read_bytes().hex() if path.exists() else None
        if actual not in (item['before'], item['after']):
            raise ValueError('Replan recovery conflicts with an external edit: ' + item['path'])
    for item in reversed(transaction['writes']):
        path = local_path(root, item['path'])
        if item['before'] is None:
            path.unlink(missing_ok=True)
        else:
            write_bytes(path, bytes.fromhex(item['before']))
    journal.unlink()


def decode_applied(path):
    header = path.read_text('utf8').split('---\n', 2)[1]
    return {key: json.loads(value.strip()) for key, value in (line.split(':', 1) for line in header.splitlines())}


def replan_status(context, change):
    root, identity = active_change(context, change)
    discussions = talk(context, 'status', {'Change': change})
    pending = journal_path(context, identity).exists()
    recording, inputs = [], []
    roots = {context['WorkspaceRoot'], *[r['workspace_root'] for r in discussions['records'] if r.get('workspace_root')]}
    primary = Path(context.get('PrimaryRoot', context['OpenSpecRoot'])).absolute()
    for owner in roots:
        owner = Path(owner).absolute()
        if owner != Path(context['WorkspaceRoot']).absolute() and owner != primary and not owner.is_relative_to(primary / '.workspaces'):
            raise ValueError('Discussion points outside registered workspace storage')
        for path in local_path(owner, 'Saved/Harness/draft-record').glob('*.json'):
            binding = json.loads(path.read_text('utf8')).get('active')
            if binding and binding.get('change') == change:
                recording.append(path.stem)
        for path in local_path(owner, 'Saved/Harness/Execution').glob('*.json'):
            state = json.loads(path.read_text('utf8'))
            if not state.get('released') and (state.get('change') == change or state.get('scope') == 'Queue') and state.get('pendingInputs'):
                inputs.append(state['sessionId'])
    from handoff import get_handoff_status, planning_commit_status
    handoff = get_handoff_status(context, change)
    planning = planning_commit_status(context, change)
    pending |= planning['pending']
    from planning_git import status as git_status
    replanned = [git_status(context, identity, decode_applied(p)) for p in sorted((root / 'attachments/replans').glob('*.md')) if 'planning_schema:' in p.read_text('utf-8-sig')]
    pending |= any(item['pending'] for item in replanned)
    return dict(recoveryNeeded=pending, planning=planning, replanCommits=replanned, applied=[p.stem for p in sorted((root / 'attachments/replans').glob('*.md'))], handoff=handoff,
                discussions=discussions, recordingSessions=recording, pendingInputSessions=inputs,
                executionAllowed=not pending and not inputs and discussions['executionAllowed'] and not handoff['pending'] and not handoff['issues'])

def validate_candidate(context, parameters, root, candidates, validator=None):
    change = parameters['Change']
    before_tasks = (root / 'tasks.md').read_text('utf-8-sig')
    after_tasks = candidates.get('tasks.md', before_tasks)
    for pattern in (r'^## \[[ xX]\] ([0-9]+\.[0-9]+)\b', r'^## \[[xX]\] ([0-9]+\.[0-9]+)\b'):
        if not set(re.findall(pattern, before_tasks, re.M)) <= set(re.findall(pattern, after_tasks, re.M)):
            raise ValueError('Task IDs and completed tasks must be preserved')
    scratch = local_path(context['WorkspaceRoot'], 'Saved/AgentTemp/replan')
    scratch.mkdir(parents=True, exist_ok=True)
    before_plan = after_plan = None
    with tempfile.TemporaryDirectory(prefix='candidate-', dir=scratch) as staging:
        stage = Path(staging)
        openspec = Path(context['OpenSpecRoot']) / 'openspec'
        for name in ('project.yaml', 'config.yaml', 'domains', 'workflows', 'specs'):
            source = local_path(openspec, name)
            destination = stage / 'openspec' / name
            if source.is_dir():
                for child in source.rglob('*'):
                    local_path(openspec, str(child.relative_to(openspec)))
                shutil.copytree(source, destination)
            elif source.is_file():
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, destination)
        stage_change = stage / 'openspec/changes' / change
        for child in root.rglob('*'):
            local_path(root, str(child.relative_to(root)))
        shutil.copytree(root, stage_change)
        if not validator:
            try:
                before_plan = native(context, ['instructions', 'apply', '--change', change, '--json'], stage)
            except ValueError:
                pass  # An invalid old graph may itself be the reason for Replan.
        for name, body in candidates.items():
            write_text(local_path(stage_change, name), body)
        if validator:
            validator(stage)
        else:
            native(context, ['validate', change, '--type', 'change', '--strict', '--json'], stage)
            plan = native(context, ['instructions', 'apply', '--change', change, '--json'], stage)
            after_plan = plan
            if parameters.get('ResumeTask') and not any(t['id'] == parameters['ResumeTask'] for t in plan.get('tasks', [])):
                raise ValueError('Resume task does not exist in candidate TaskPlan')
    return before_plan, after_plan


def apply_replan(context, parameters, validator=None):
    change = parameters['Change']
    root, identity = active_change(context, change)
    replan_id = parameters.get('ReplanId', '')
    if not re.fullmatch(r'replan-\d{8}-\d{6}-[a-z0-9-]+', replan_id):
        raise ValueError('Exact replan-YYYYMMDD-HHmmss-theme ID required')
    target = local_path(root, 'attachments/replans/' + replan_id + '.md')
    if parameters.get('RequireGitPlan') and not parameters.get('GitPlan') and (not target.exists() or decode_applied(target).get('planning_schema')):
        raise ValueError('A new Replan requires its exact formal-record GitPlan before the Gate')
    candidates, hashes = parameters.get('Candidates', {}), parameters.get('ExpectedHashes', {})
    if not candidates or 'tasks.md' not in hashes:
        raise ValueError('Candidates and baseline tasks.md hash required')
    for name, body in candidates.items():
        if not (name in ('proposal.md', 'design.md', 'tasks.md') or re.fullmatch(r'specs/[a-z0-9/-]+\.md', name)):
            raise ValueError('Only planning artifact paths are accepted')
        local_path(root, name)
        if name not in hashes or not isinstance(body, str) or len(body.encode()) > 1_000_000:
            raise ValueError('Each candidate needs its baseline hash and bounded text')
    from handoff import preview, consume_gate, followup_record
    if parameters.get('PlanOnly'):
        if parameters.get('GitPlan'):
            from planning_git import prepare
            prepared_parameters = {**parameters, 'GitPlan': prepare(context, parameters, root, identity)}
            for name, expected in hashes.items():
                if current_hash(local_path(root, name)) != expected:
                    raise ValueError('Planning baseline changed: ' + name)
            validate_candidate(context, parameters, root, candidates, validator)
            result = preview(context, 'replan', prepared_parameters)
            result['GitPlan'] = prepared_parameters['GitPlan']
            return result
        return preview(context, 'replan', parameters)
    request = {'talk': parameters['TalkId'], 'candidates': candidates, 'hashes': hashes}
    if parameters.get('GitPlan'):
        request['git_plan'] = parameters['GitPlan']
    requested_hash = digest(json.dumps(request, sort_keys=True).encode())
    target = local_path(root, 'attachments/replans/' + replan_id + '.md')
    talk_path = record_path(context, change, parameters['TalkId'])
    journal = journal_path(context, identity)
    change_lock = local_path(context['OpenSpecRoot'], 'Saved/Harness/TalkLocks/' + digest(identity['uid'].encode()) + '.lock')
    with locked(change_lock), locked(record_lock(context['OpenSpecRoot'], talk_path)):
        owner, _ = read_record(talk_path)
        if not owner or owner['workspace_id'] != context['WorkspaceId']:
            raise ValueError('Discussion workspace identity differs; recovery cannot transfer ownership')
        recover(root, journal)
        if target.exists():
            applied = decode_applied(target)
            if applied.get('request_sha256') != requested_hash:
                raise ValueError('Immutable Replan ID already represents another request')
            gate = parameters.get('Gate')
            if gate and applied.get('handoff'):
                for requested, recorded in [('DecisionSource', 'decision_source'), ('ConvergenceSource', 'convergence_source'), ('HandoffRevision', 'revision'), ('Decision', 'decision'), ('TargetChange', 'target_change')]:
                    if gate.get(requested) != applied['handoff'].get(recorded):
                        raise ValueError('Retry cannot replace the already consumed Replan Gate')
            return applied
        discussion, original = read_record(talk_path)
        if not discussion or discussion['workspace_id'] != context['WorkspaceId']:
            raise ValueError('Discussion workspace identity differs')
        if discussion['status'] != 'settled' or discussion['revision'] != parameters.get('ExpectedRevision'):
            raise ValueError('Replan requires the current settled discussion revision')
        if discussion.get('purpose') == 'handoff-followup':
            raise ValueError('Replan cannot consume a handoff follow-up discussion')
        if parameters.get('GitPlan'):
            from planning_git import prepare
            parameters = {**parameters, 'GitPlan': prepare(context, parameters, root, identity)}
        prepared = preview(context, 'replan', parameters)
        receipt = consume_gate(context, 'replan', parameters, prepared)
        followup = followup_record(context, change, parameters.get('SessionId'), receipt)
        if replan_status(context, change)['pendingInputSessions']:
            raise ValueError('Triage pending input before applying the plan')
        handoff_state = replan_status(context, change)['handoff']
        if handoff_state['pending'] or handoff_state['issues']:
            raise ValueError('Complete the previous handoff arrangements before a new Replan')
        for name, expected in hashes.items():
            if current_hash(local_path(root, name)) != expected:
                raise ValueError('Planning baseline changed: ' + name)
        before_tasks = (root / 'tasks.md').read_text('utf-8-sig')
        base_commit = subprocess.run(['git', '-C', context['OpenSpecRoot'], 'rev-parse', 'HEAD'], capture_output=True, text=True, check=True).stdout.strip()
        after_tasks = candidates.get('tasks.md', before_tasks)
        old_ids = set(re.findall(r'^## \[[ xX]\] ([0-9]+\.[0-9]+)\b', before_tasks, re.M))
        new_ids = set(re.findall(r'^## \[[ xX]\] ([0-9]+\.[0-9]+)\b', after_tasks, re.M))
        done = set(re.findall(r'^## \[[xX]\] ([0-9]+\.[0-9]+)\b', before_tasks, re.M))
        after_done = set(re.findall(r'^## \[[xX]\] ([0-9]+\.[0-9]+)\b', after_tasks, re.M))
        if not old_ids <= new_ids or not done <= after_done:
            raise ValueError('Task IDs and completed tasks must be preserved')
        before_plan, after_plan = validate_candidate(context, parameters, root, candidates, validator)
        # Check again after the potentially long validation call.
        if preview(context, 'replan', parameters)['HandoffRevision'] != prepared['HandoffRevision']:
            raise ValueError('Gate design revision changed during validation')
        if replan_status(context, change)['pendingInputSessions']:
            raise ValueError('New input arrived during validation; triage before applying')
        for name, expected in hashes.items():
            if current_hash(local_path(root, name)) != expected:
                raise ValueError('Planning baseline changed during validation: ' + name)
        commit = subprocess.run(['git', '-C', context['OpenSpecRoot'], 'rev-parse', 'HEAD'], capture_output=True, text=True, check=True).stdout.strip()
        if commit != base_commit:
            raise ValueError('Planning baseline commit changed during validation')
        for name, expected in parameters.get('GitPlan', {}).get('ExistingInputs', {}).items():
            if current_hash(local_path(root, name)) != expected:
                raise ValueError('Planning provenance changed during validation: ' + name)
        changed_paths = [str(local_path(root, name)) for name in candidates]
        status_snapshot = subprocess.run(['git', '-C', context['OpenSpecRoot'], 'status', '--short', '--', *changed_paths], capture_output=True, text=True, check=True).stdout.strip()
        diff_snapshot = subprocess.run(['git', '-C', context['OpenSpecRoot'], 'diff', '--stat', '--', *changed_paths], capture_output=True, text=True, check=True).stdout.strip()
        old_cards, new_cards = task_cards(before_tasks), task_cards(after_tasks)
        task_changes = dict(added=sorted(new_ids - old_ids), removed=sorted(old_ids - new_ids),
                            modified=sorted(task_id for task_id in old_ids & new_ids if old_cards[task_id] != new_cards[task_id]))
        edge_changes = (dict(added=sorted(plan_edges(after_plan) - plan_edges(before_plan)),
                             removed=sorted(plan_edges(before_plan) - plan_edges(after_plan)))
                        if before_plan is not None and after_plan is not None else None)
        applied = dict(replan_id=replan_id, status='applied', source='user' if discussion['talk_id'].startswith('grill-') else 'agent',
                       source_ref='talks/' + talk_path.name, scope=discussion['summary'], base_commit=commit,
                       base_tasks_sha256=hashes['tasks.md'], result_tasks_sha256=digest(after_tasks.encode('utf8')) if 'tasks.md' in candidates else hashes['tasks.md'],
                       created_at=now(), resume_task=parameters.get('ResumeTask', discussion['resume_task']), request_sha256=requested_hash,
                       task_changes=task_changes, edge_changes=edge_changes, handoff_schema=1, handoff=receipt)
        if parameters.get('GitPlan'):
            applied.update(planning_schema=1, git_plan=parameters['GitPlan'])
        text = '---\n' + '\n'.join(k + ': ' + json.dumps(v) for k, v in applied.items()) + '\n---\n\n'
        text += '## Trigger and Evidence\n\n- Source: ../talks/' + talk_path.name + '\n\n## Decision\n\n- ' + discussion['summary'] + '\n\n'
        text += '## Impact\n\n' + '\n'.join('- Artifact ~: ' + name for name in candidates) + '\n'
        text += '\n## Diff Snapshot\n\n'
        for symbol, key in (('+', 'added'), ('-', 'removed'), ('~', 'modified')):
            text += '- Task ' + symbol + ': ' + (', '.join(task_changes[key]) or 'none') + '\n'
        if edge_changes is not None:
            for symbol, key in (('+', 'added'), ('-', 'removed')):
                text += '- Edge ' + symbol + ': ' + (', '.join(edge_changes[key]) or 'none') + '\n'
        else:
            text += '- Edge comparison unavailable: baseline graph was not projected; inspect the captured task baseline.\n'
        text += '\n```text\n' + (status_snapshot or 'No affected tracked-path changes at capture.') + '\n' + (diff_snapshot or 'No tracked diff stat at capture.') + '\n```\n'
        checkpoint = root / 'attachments/data/harness-execution.json'
        if checkpoint.exists():
            text += '\n- Execution checkpoint: ../data/harness-execution.json; SHA-256 ' + current_hash(checkpoint) + '\n'
        text += '\n## Old Task Disposition\n\n- Existing IDs and completed tasks retained.\n'
        text += '\n## Preserved Work\n\n- Valid prior work and evidence remain; changed behavior requires fresh proving evidence.\n'
        text += '\n## References and Result\n\n- Resume: ' + applied['resume_task'] + '\n'
        discussion.update(status='closed', disposition='applied', replan_ref='replans/' + target.name,
                          revision=discussion['revision'] + 1, updated_at=now())
        index_path = root / 'attachments/INDEX.md'
        index_text = indexed(index_path.read_text('utf-8-sig'), discussion)
        index_text = indexed(index_text, followup)
        index_text += '- replans/' + target.name + ' — applied — ' + discussion['summary'].replace('\n', ' ') + '\n'
        if len(index_text.splitlines()) > 120:
            raise ValueError('INDEX exceeds 120 lines')
        writes = {**candidates, 'attachments/talks/' + talk_path.name: render(discussion, original), 'attachments/INDEX.md': index_text,
                  'attachments/talks/' + followup['talk_id'] + '.md': render(followup),
                  'attachments/replans/' + target.name: text}
        transaction = dict(change=change, replan_id=replan_id, writes=[dict(path=name, before=local_path(root, name).read_bytes().hex() if local_path(root, name).exists() else None,
                            after=body.encode('utf8').hex()) for name, body in writes.items()])
        if parameters.get('GitPlan'):
            from planning_git import save_operation
            save_operation(context, root, identity, applied, writes)
        journal.parent.mkdir(parents=True, exist_ok=True)
        save_state(journal, transaction)
        try:
            for name, body in writes.items():
                write_text(local_path(root, name), body)
            if not validator:
                native(context, ['validate', change, '--type', 'change', '--strict', '--json'])
            journal.unlink()
        except Exception:
            recover(root, journal)
            raise
        return applied
