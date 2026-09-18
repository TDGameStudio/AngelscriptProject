## Optional transcript recording

- Transcript recording is opt-in and separate from new draft CONTEXT. No transcript coverage, binding or sync is required for a question, handoff or final answer.
- Preserve existing recorded originals. Do not turn the presence of a historical log into a requirement to resume full recording.

- Codex: bind the exact workspace/session/source/draft and first task message line. Do not bind injected setup instructions or a child agent's private conversation. The recorder recognizes Codex 0.154.x JSONL and reports unsupported formats explicitly.

```powershell
Import-Module ./.agents/skills/harness/scripts/Harness.psd1
$context = New-HarnessContext -WorkspaceRoot $PWD
Invoke-Harness harness.draft.record -Context $context -Parameters @{
    Action = 'bind'; DraftId = '<domain>/<topic>'; SessionId = '<exact-session-id>'
    Source = '<absolute-transcript.jsonl>'; StartLine = <first-task-message-line>
}
Invoke-Harness harness.draft.record -Context $context -Parameters @{ Action = 'status'; SessionId = '<exact-session-id>' }
```

- `sync` reconciles the bound source; `status` reads the last coverage and binding without writing. `unbind` flushes and closes it. Switching drafts uses `bind` with the same source and a later, nonoverlapping start line; it closes the previous range first.
- State is local to `Saved/Harness/draft-record/` in the selected workspace. An unbound session does nothing; it never selects the newest draft. Replaying a source event is idempotent; identical words at different source positions remain separate occurrences.
- The repository does not register Codex project hooks. Tool calls and interruptions do not sync; the next public `sync` reconciles their delivered originals.
- When optional recording is explicitly selected, inspect the recorded range and any gaps. A partial line, changed/missing source, unsupported format or interrupted write requires retry/reconciliation; a successful sync only covers the source bytes actually available then.
- Existing logs are append-only. The recorder appends canonical source occurrences even when similar legacy text exists; `legacy_overlap` identifies unresolved historical matching, not a reason to discard a message.
- When the user requests complete transcript recording, sync at the agreed recording boundaries. The current unsent final stays pending until a later source sync; never prewrite it as delivered. For other hosts or unavailable originals, record the exact available boundary and missing range manually, without inventing quotations.

