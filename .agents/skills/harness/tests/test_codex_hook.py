"""Native hook boundaries: optional dependencies, recording and input priority."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / '.agents/skills/harness/scripts'))
import draft_record


class CodexHookTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory(prefix='harness-hook-boundaries-')
        cls.root = Path(cls.temp.name) / 'project'
        cls.root.mkdir()
        cls.pwsh = shutil.which('pwsh')
        if not cls.pwsh:
            raise RuntimeError('Hook tests require PowerShell 7')
        for relative in ('.agents/skills/harness/scripts', '.agents/skills/workspace-lifecycle/scripts'):
            shutil.copytree(ROOT / relative, cls.root / relative, ignore=shutil.ignore_patterns('__pycache__'))
        for args in (['init', '-q'], ['config', 'user.name', 'Fixture'],
                     ['config', 'user.email', 'fixture@example.invalid']):
            subprocess.run(['git', '-C', str(cls.root), *args], check=True, capture_output=True)
        (cls.root / '.gitignore').write_text('Saved/\n', 'utf8')
        subprocess.run(['git', '-C', str(cls.root), 'add', '.gitignore'], check=True, capture_output=True)
        subprocess.run(['git', '-C', str(cls.root), 'commit', '-qm', 'fixture'], check=True, capture_output=True)
        (cls.root / 'Fixture.uproject').write_text('{"FileVersion":3,"Modules":[],"Plugins":[]}', 'utf8')
        cls.scripts = cls.root / '.agents/skills/harness/scripts'
        cls.wrapper = cls.root / 'hook-probe.ps1'
        cls.wrapper.write_text(r'''
$ErrorActionPreference = 'Stop'
function global:python {
    $nativeArguments = @($args)
    $payload = @($input)
    if ($env:HOOK_PROBE_NO_PYTHON -eq '1') { throw 'Python unavailable in this host' }
    if ($env:HOOK_PROBE_ORDER -and @($args | Where-Object { "$_" -like '*draft_record.py' }).Count) {
        $state = Get-Content -LiteralPath $env:HOOK_PROBE_STATE -Raw | ConvertFrom-Json
        $ready = if ($env:HOOK_PROBE_ORDER -eq 'Interrupt') { $state.state -eq 'paused' }
                 else { 'feedback-turn' -in @($state.pendingInputs | ForEach-Object { $_.id }) }
        if (-not $ready) { [Console]::Error.WriteLine('Recorder started before the input state was saved') }
    }
    if ($payload.Count) { $payload | & $env:HOOK_PROBE_PYTHON @nativeArguments }
    else { & $env:HOOK_PROBE_PYTHON @nativeArguments }
    $global:LASTEXITCODE = $LASTEXITCODE
}
& $env:HOOK_PROBE_SCRIPT
''', 'utf8')
        context = subprocess.run([cls.pwsh, '-NoProfile', '-Command',
                                  "Import-Module ./.agents/skills/workspace-lifecycle/scripts/WorkspaceLifecycle.psd1; "
                                  "Get-HarnessWorkspaceContext -WorkspaceRoot (Get-Location).Path | ConvertTo-Json -Depth 5"],
                                 cwd=cls.root, check=True, capture_output=True, text=True, encoding='utf8')
        cls.context = json.loads(context.stdout)

    @classmethod
    def tearDownClass(cls):
        cls.temp.cleanup()

    def call_hook(self, event, session, source=None, no_python=False, inspect_order=False, cwd=None):
        env = dict(os.environ, HOOK_PROBE_PYTHON=sys.executable,
                   HOOK_PROBE_SCRIPT=str(self.scripts / 'Invoke-HarnessCodexHook.ps1'),
                   HOOK_PROBE_NO_PYTHON='1' if no_python else '',
                   HOOK_PROBE_ORDER=event if inspect_order else '',
                   HOOK_PROBE_STATE=str(self.execution_path(session)))
        payload = dict(hook_event_name=event, session_id=session, cwd=str(cwd or self.root),
                       permission_mode='default', turn_id='feedback-turn', prompt='User feedback')
        if source:
            payload['transcript_path'] = str(source)
        return subprocess.run([self.pwsh, '-NoProfile', '-File', str(self.wrapper)],
                              cwd=self.root, env=env, input=json.dumps(payload),
                              capture_output=True, text=True, encoding='utf8', timeout=15,
                              creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0)

    def execution_path(self, session):
        return self.root / f'Saved/Harness/Execution/{session}.json'

    def bind_recording(self, session):
        draft = f'harness/{session}'
        log = self.root / f'openspec/drafts/{draft}/log.md'
        log.parent.mkdir(parents=True)
        log.write_text('# Log\n', 'utf8')
        source = self.root / f'{session}.jsonl'
        source.write_text(json.dumps(dict(type='session_meta', payload=dict(
            id=session, cwd=str(self.root), cli_version='0.154.0'))) + '\n', 'utf8')
        binding = draft_record.record(str(self.root), session, 'bind', draft_id=draft, source=str(source), start_line=2)
        self.assertEqual('covered', binding['status'])
        with source.open('a', encoding='utf8') as stream:
            stream.write(json.dumps(dict(type='response_item', payload=dict(type='message', role='assistant',
                phase='commentary', content=[dict(type='output_text', text='Exact delivered original')])) ) + '\n')
        return source, log

    def bind_execution(self, session):
        path = self.execution_path(session)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(json.dumps(dict(schema=1, workspaceId=self.context['WorkspaceId'], workspaceRoot=str(self.root),
            sessionId=session, scope='Change', change='harness/test-input', changeUid='fixture-uid', sourceRef='user:execute',
            state='running', phase='planning', revision=1, pendingInputs=[], handledInputs=[], resumeTask='', reason='',
            updatedAt='2026-09-17T12:00:00Z')), 'utf8')

    def test_unbound_events_work_without_python(self):
        for event in ('SessionStart', 'Stop', 'Interrupt', 'UserPromptSubmit'):
            with self.subTest(event=event):
                result = self.call_hook(event, 'unbound', no_python=True)
                self.assertEqual(0, result.returncode)
                self.assertEqual('', result.stderr.strip(), 'An unbound hook must not depend on optional Python workers')
                if event == 'SessionStart':
                    text = json.loads(result.stdout)['hookSpecificOutput']['additionalContext']
                    self.assertIn(self.context['WorkspaceId'], text)
                    self.assertIn(str(self.root), text)
                else:
                    self.assertEqual('', result.stdout.strip())
        source, _ = self.bind_recording('released-recording')
        draft_record.record(str(self.root), 'released-recording', 'unbind')
        result = self.call_hook('Stop', 'released-recording', source, no_python=True)
        self.assertEqual('', (result.stdout + result.stderr).strip(), 'An inactive binding is also unbound')

    def test_removed_events_do_no_work_even_with_bound_recording(self):
        session = 'record-only'
        source, log = self.bind_recording(session)
        path = self.execution_path(session)
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text('invalid execution JSON', 'utf8')
        for event in ('PostToolUse', 'SubagentStart'):
            with self.subTest(event=event):
                result = self.call_hook(event, session, source, no_python=True)
                self.assertEqual(0, result.returncode)
                self.assertEqual('', (result.stdout + result.stderr).strip())
                self.assertNotIn('Exact delivered original', log.read_text('utf8'))
        stop = self.call_hook('Stop', session, source)
        self.assertIn('Exact delivered original', log.read_text('utf8'))
        self.assertIn('Harness continuation check unavailable', stop.stderr,
                      'Stop must still validate the execution state that actually controls continuation')

    def test_input_is_durable_before_recorder_starts(self):
        for event in ('UserPromptSubmit', 'Interrupt'):
            with self.subTest(event=event):
                session = 'priority-' + event.lower()
                source, log = self.bind_recording(session)
                self.bind_execution(session)
                result = self.call_hook(event, session, source, inspect_order=True)
                self.assertEqual(0, result.returncode)
                self.assertEqual('', (result.stdout + result.stderr).strip())
                state = json.loads(self.execution_path(session).read_text('utf8'))
                if event == 'Interrupt':
                    self.assertEqual('paused', state['state'])
                    self.assertNotIn('Exact delivered original', log.read_text('utf8'), 'Interrupt only saves pause')
                    resumed = self.call_hook('UserPromptSubmit', session, source)
                    self.assertEqual('', (resumed.stdout + resumed.stderr).strip())
                    self.assertEqual('paused', json.loads(self.execution_path(session).read_text('utf8'))['state'])
                else:
                    self.assertEqual(['feedback-turn'], [x['id'] for x in state['pendingInputs']])
                self.assertIn('Exact delivered original', log.read_text('utf8'))

    def test_foreign_workspace_cannot_record_into_selected_draft(self):
        session = 'foreign-root'
        source, log = self.bind_recording(session)
        outside = Path(self.temp.name) / 'outside'
        outside.mkdir()
        before = log.read_bytes()
        result = self.call_hook('Stop', session, source, cwd=outside)
        self.assertEqual(0, result.returncode)
        self.assertIn('unavailable for this workspace', result.stderr)
        self.assertEqual(before, log.read_bytes())


if __name__ == '__main__':
    unittest.main()
