---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260905-024820-missing-frontend-domain
status: resolved
source: verification
source_ref: run-20582204a57e431ebcc20841b019f5c0
affected_tasks: ["3.1"]
created_at: 2026-09-05T02:48:20+08:00
resolved_at: 2026-09-05T02:50:14+08:00
resolution_ref: run-680fd814c44c442f9bb36b5269da9d90
---

# Source-diagnostics capability creation requires a registered frontend domain

## Symptom

The exact Task `3.1` `openspec.spec create` command failed with exit code 1 because `angelscript/language/frontend` was not a registered domain.

## Investigation Log

1. The final compiled SourceDiagnostics content built and passed 11/11 focused tests.
2. `openspec/specs/angelscript/language/frontend/source-diagnostics` did not yet exist, so the Task correctly used the portable CLI create route.
3. Harness run `20582204a57e431ebcc20841b019f5c0` invoked the specified command exactly.
4. The portable CLI reported that the parent domain must first be created with `openspec domain create angelscript/language/frontend`.
5. Existing domain manifests stop at `angelscript/language`; no conflicting frontend domain exists.

## Root Cause

The Task planned creation of the first capability beneath a new nested domain but omitted registration of that parent domain and its CLI-owned manifest.

## Disposition

An applied Replan adds the parent domain manifest to Task `3.1` and requires `openspec.domain create` before retrying `openspec.spec create`. Both CLI-owned identities now exist, the complete delta is synchronized, and exact strict spec validation `680fd814c44c442f9bb36b5269da9d90` resolves the issue.

## Evidence

### Failure Evidence (RED)

- Harness run: `20582204a57e431ebcc20841b019f5c0`.
- Command: `openspec spec create angelscript/language/frontend/source-diagnostics --title "Frontend Source Diagnostics" --json`.
- CLI diagnostic: the spec requires registered domain `angelscript/language/frontend`.

### Resolution Evidence (GREEN)

- `openspec.domain create` created registered domain `angelscript/language/frontend` with CLI-owned UID `domain_e5260ac7-27b3-41dd-b656-f67d4b1143d0`.
- `openspec.spec create` created capability `angelscript/language/frontend/source-diagnostics` with CLI-owned UID `spec_caadfb30-fa16-4223-9c7b-3c2aa7579cab`.
- Exact strict spec validation run `680fd814c44c442f9bb36b5269da9d90` succeeded.

### What This Proves

- A capability cannot be created beneath an unregistered domain.
- The first reconstructed frontend capability must establish the shared parent identity for later frontend Changes.

### What This Does Not Prove

- It does not require a portable CLI or Harness change.
- It does not authorize hand-written `domain.yaml` or `spec.yaml` identities.

## Links

- `attachments/replans/replan-20260905-024820-create-frontend-domain.md`.
- `tasks.md`, Task `3.1`.
