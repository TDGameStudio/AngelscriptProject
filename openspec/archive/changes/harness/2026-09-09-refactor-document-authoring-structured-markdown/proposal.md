# Structured Markdown task and specification authoring

## Why

Task titles currently contain long commands, file ownership is flattened into comma-separated lines, and detailed cases and evidence drift away from their task. Specification details sometimes appear in an unowned scenario tail. Structural validity does not establish whether a task gives an implementer concrete inputs, interfaces and acceptance conditions.

## What Changes

Adopt short task checkbox titles with four-space-indented rich Markdown. Direct Files and Verification sections supply the existing TaskPlan fields; all other task detail remains readable Markdown. Parse container ownership so nested examples cannot create metadata or specification structure. Require executable planning detail and preserve full clause-owned specification content.

This is a deliberate new-only format cutover. Old business records and immutable archives are not migrated. Their old tasks are not schedulable under the new package. No web application or Unreal product code is changed.

## Impact

Own the portable OpenSpec source/package, project task/spec authoring guidance and templates, focused Harness integration fixtures, and the corresponding harness/core durable contract. Preserve existing TaskPlan JSON field identities and DAG semantics. Publish a locally verified package through the existing release mechanism; no remote publication, integration, or workspace lifecycle action is included.
