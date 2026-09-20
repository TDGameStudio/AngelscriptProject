# Spec sync

Date: 2026-09-18. Change: angelscript/feature-module-register-identity.

- `angelscript/runtime/type-registry`: ADDED `Register attaches per-file asCModule identity` and `Engine module lookup is name-only`, including both Scenario Cards and clause-owned detail. Strict spec validation passed.
- `angelscript/language/frontend/builder`: MODIFIED same-name cards `CompileOutput carries ClassGen descriptors without ScriptType` and `CompileOutput keeps Projected descriptors after definitions exist` so `ScriptModule` stays null until Register. Preserved unspecified scenarios. Strict spec validation passed.
- Change strict validation passed. Knowledge `getmodule-lookup-is-not-compile` stays change-local.
