"""Exact formal-record Git intent and recoverable state; PowerShell owns commits."""
import json
from pathlib import Path
import subprocess

from draft_record import digest, local_path, save_state


def git(context, *arguments):
    return subprocess.run(['git', '-C', context['OpenSpecRoot'], *arguments], capture_output=True,
                          encoding='utf8', check=True).stdout.strip()


def operation_path(context, identity, replan_id):
    return local_path(context['OpenSpecRoot'], 'Saved/Harness/PlanningCommits/' + digest(identity['uid'].encode()) + '-' + replan_id + '.json')


def prepare(context, parameters, root, identity):
    change = parameters['Change']
    plan = parameters['GitPlan']
    if set(plan) - {'RepositoryScopes', 'CommitMessage', 'PreserveOutsideStaged'} or plan.get('RepositoryScopes') != {'.': ['openspec/changes/' + change]} or not str(plan.get('CommitMessage', '')).strip():
        raise ValueError('Replan GitPlan must bound the exact Change and an explicit commit message')
    inputs = ['attachments/INDEX.md', 'attachments/talks/' + parameters['TalkId'] + '.md']
    known = {name: digest(local_path(root, name).read_bytes()) for name in inputs}
    selected = sorted(set(parameters['Candidates']) | set(inputs) | {'attachments/replans/' + parameters['ReplanId'] + '.md'})
    return dict(CommitMessage=plan['CommitMessage'], BaselineHead=git(context, 'rev-parse', 'HEAD'),
                Branch=git(context, 'symbolic-ref', '--short', 'HEAD'), RecordRoot=context['OpenSpecRoot'],
                WorkspaceRoot=context['WorkspaceRoot'], ChangeUid=identity['uid'], PreserveOutsideStaged=True,
                SelectedPaths=selected, GeneratedFollowup='one purpose-specific talk derived from this exact receipt',
                ExistingInputs=known)


def save_operation(context, root, identity, applied, writes):
    path = operation_path(context, identity, applied['replan_id'])
    if path.exists():
        old = json.loads(path.read_text('utf8'))
        if old['requestHash'] != applied['request_sha256'] or old['stage'] != 'prepared':
            raise ValueError('Planning Git recovery already owns a different or applied operation')
    outputs = {name: digest(body.encode('utf8')) for name, body in writes.items()}
    plan = applied['git_plan']
    state = dict(schema=1, kind='replan', stage='prepared', change=identity['id'], uid=identity['uid'],
                 replanId=applied['replan_id'], requestHash=applied['request_sha256'],
                 recordRoot=context['OpenSpecRoot'], workspaceRoot=context['WorkspaceRoot'],
                 baseline=plan['BaselineHead'], branch=plan['Branch'], message=plan['CommitMessage'], outputs=outputs)
    path.parent.mkdir(parents=True, exist_ok=True)
    save_state(path, state)


def status(context, identity, applied):
    path = operation_path(context, identity, applied['replan_id'])
    if path.exists():
        state = json.loads(path.read_text('utf8'))
        if state.get('requestHash') != applied['request_sha256'] or state.get('uid') != identity['uid']:
            raise ValueError('Replan Git recovery identity differs')
        return dict(replan=applied['replan_id'], pending=state.get('stage') != 'complete', stage=state['stage'], path=str(path), commit=state.get('commit'))
    relative = 'openspec/changes/' + identity['id'] + '/attachments/replans/' + applied['replan_id'] + '.md'
    result = subprocess.run(['git', '-C', context['OpenSpecRoot'], 'show', 'HEAD:' + relative], capture_output=True)
    persisted = result.returncode == 0 and result.stdout == local_path(context['OpenSpecRoot'], relative).read_bytes()
    return dict(replan=applied['replan_id'], pending=not persisted, stage='complete' if persisted else 'recovery-required', path=str(path))
