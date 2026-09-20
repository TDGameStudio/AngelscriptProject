# Spec sync results

Change: `angelscript/refactor-sdk-compile-lifecycle`

Merged change-local deltas into current specs. Did not overwrite any current spec with a delta file.

| Capability | Operation | Strict validate |
|---|---|---|
| `angelscript/language/types/definitions` | ADD Script TypeInfo…; MODIFY Transactional single-engine… (three same-name scenarios); ADD MetadataImage is not a TypeInfo owner | passed |
| `angelscript/language/frontend/builder` | MODIFY Independent typed compilation stages; ADD Builder yields two takeable products; ADD Default RunThrough emits stable bytecode; KEEP Maintained language semantics… | failed (baseline) |
| `angelscript/runtime/type-registry` | ADD Script compile transfers TypeInfo through a definition set; unspecified Image-helper bodies unchanged | passed |
| `angelscript/runtime/bytecode` | Purpose replaced; REMOVE three Image/persist/canonical-image requirements; ADD three Function-hung requirements; MODIFY verification, linking, source placement | passed |
| `angelscript/runtime/vm` | ADD Prepare reads Function runtime bytecode; MODIFY interpreter, context/shutdown, admission; unspecified Native/objects/GC/Shared kept | passed |
| `angelscript/refactor-sdk-compile-lifecycle` | change `--type change --strict` | passed |

Builder failure is the unspecified scenario `Analyze supported source through the replacement` (line 39): two-space Verification quote. That card was not in the delta. Exact text and parentage were preserved; this Change does not migrate unspecified builder formatting.

Bytecode `Stable symbol linking` keeps unspecified scenarios `Reject a late binding failure atomically` and `Bind one cache independently in two Engines`. The Registration requirement also has a same-name late-binding card (delta ADDED). Scenario reparenting was not inferred.

Knowledge candidates remain change-local. They are not promoted.

Commands (Harness `openspec.validate`, `--type spec|change`, `--strict`, `--json`):

- `angelscript/language/types/definitions` Succeeded
- `angelscript/language/frontend/builder` Failed exit 1; two four-space indent findings on the unspecified scenario
- `angelscript/runtime/type-registry` Succeeded
- `angelscript/runtime/bytecode` Succeeded
- `angelscript/runtime/vm` Succeeded
- `angelscript/refactor-sdk-compile-lifecycle` Succeeded
