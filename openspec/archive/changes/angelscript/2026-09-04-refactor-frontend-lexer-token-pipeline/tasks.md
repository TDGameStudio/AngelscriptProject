---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
    "3.1": ["2.1"]
    "4.1": ["3.1"]
---

## 1. Engine-independent token contract

- [x] 1.1 Add frozen lex options, character stream, and failing no-Engine lexer tests — verify: `Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'frontend-lexer-contract-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_options.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_character_stream.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_token_kinds.def`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_token.h`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/LexerTests.cpp`

  > Context: Do not begin until the NativeEngine test foundation and source-diagnostics Change are implemented and verified.

  1. Add compile-time and CQTest cases that require immutable options, snapshot ranges, compact token fields, and construction without Engine/Builder pointers.
  2. Observe the initial compile RED, then add only the option, stream, token-kind, and token representation needed by those cases.
  3. Rebuild the exact editor target without enabling the legacy tokenizer path.

- [x] 1.2 Implement identifier interning and the pull tokenizer hot path — verify: `& { $b = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'frontend-lexer-core-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }; if ($b.status -ne 'Succeeded') { throw 'frontend lexer core build failed' }; $t = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Lexer'; Label = 'frontend-lexer-core-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }; if ($t.status -ne 'Succeeded') { throw 'frontend lexer core test failed' }; $t }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_identifier_table.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_identifier_table.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_tokenizer.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_tokenizer.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/LexerTests.cpp`

  > Replan context: The completed source-diagnostics Change proved that UBT requires unique C++ input basenames across one module. Because the preserved production source already owns `as_tokenizer.cpp`, the isolated frontend implementation uses `as_frontend_tokenizer.cpp`; the final internal type and header remain `frontend::asCTokenizer` and `as_tokenizer.h`.

  > Constraints: The new class uses its final `asCTokenizer` leaf name inside the internal lowercase `frontend` namespace. Do not suffix `V2`, query `asCScriptEngine::ep`, or expose private scanning helpers.

  1. Add failing corpus cases for identifiers, repeated interning, keywords, U* spellings, punctuation, literals, token flags, and source slices; build and observe RED.
  2. Implement direct-pointer ASCII scanning, identifier lookup, and `Lex(Token&)` with no common-token allocation.
  3. Rebuild, run the complete Lexer prefix, and require deterministic token projections.

## 2. Recovery, modes, and concurrency

- [x] 2.1 Complete Unicode, trivia/raw modes, progress guarantees, and concurrent determinism — verify: `& { $b = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'frontend-lexer-edge-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }; if ($b.status -ne 'Succeeded') { throw 'frontend lexer edge build failed' }; $t = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Lexer'; Label = 'frontend-lexer-edge-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }; if ($t.status -ne 'Succeeded') { throw 'frontend lexer edge test failed' }; $t }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_tokenizer.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_tokenizer.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_identifier_table.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/LexerTests.cpp`

  1. Add RED cases for Unicode policy, invalid UTF-8, embedded NUL, unknown bytes, unterminated literals/comments, trivia modes, EOF, and repeated malformed-input pulls.
  2. Implement separate slow paths and structured diagnostics while proving every non-EOF call consumes a non-empty range.
  3. Compare independent sessions on multiple threads and rerun the same full Lexer prefix after the final build.

## 3. Measured hot-path evidence

- [x] 3.1 Record allocation and throughput evidence without creating a portable timing gate — verify: `& { $b = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'frontend-lexer-measurement-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }; if ($b.status -ne 'Succeeded') { throw 'frontend lexer measurement build failed' }; $t = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Lexer'; Label = 'frontend-lexer-measurement'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }; if ($t.status -ne 'Succeeded') { throw 'frontend lexer measurement test failed' }; $t }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/LexerTests.cpp`, `openspec/changes/angelscript/refactor-frontend-lexer-token-pipeline/attachments/data/lexer-baseline.md`, `openspec/changes/angelscript/refactor-frontend-lexer-token-pipeline/attachments/INDEX.md`

  1. Measure a checked-in representative corpus and report bytes, tokens, allocations, peak memory, warm/cold context, and elapsed time.
  2. Fail correctness coverage if common tokens allocate per token; retain timing only as environment-specific evidence.
  3. Index the trimmed text result and rerun the complete area prefix.

## 4. Contract synchronization

- [x] 4.1 Synchronize the verified lexing capability and strictly validate both records — verify: `& { $c = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/refactor-frontend-lexer-token-pipeline','--type','change','--strict','--json'); if ($c.status -ne 'Succeeded') { throw 'frontend lexer Change validation failed' }; $s = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('--specs','--strict','--json'); if ($s.status -ne 'Succeeded') { throw 'current specification validation failed' }; $s }`
  > Files: `openspec/changes/angelscript/refactor-frontend-lexer-token-pipeline/proposal.md`, `openspec/changes/angelscript/refactor-frontend-lexer-token-pipeline/design.md`, `openspec/changes/angelscript/refactor-frontend-lexer-token-pipeline/specs/angelscript/language/frontend/lexing/spec.md`, `openspec/changes/angelscript/refactor-frontend-lexer-token-pipeline/tasks.md`, `openspec/changes/angelscript/refactor-frontend-lexer-token-pipeline/attachments/INDEX.md`, `openspec/specs/angelscript/language/frontend/lexing/spec.yaml`, `openspec/specs/angelscript/language/frontend/lexing/spec.md`

  1. Run one final incremental editor build and exact Lexer Fast prefix against the final content.
  2. Record managed run IDs, report paths, corpus provenance, and any evidence-driven scope expansion.
  3. Create the missing current capability with `Invoke-Harness -Command openspec.spec -Context $context -ArgumentList @('create','angelscript/language/frontend/lexing','--title','Frontend Lexing','--json')` rather than fabricating `spec.yaml`, merge the delta without operation headings, then run exact strict Change validation and strict current-spec validation before completing this terminal synchronization task.

  Intentionally omit Harness aggregate profiles, full UE suites, Standalone, and production Parser/Builder tests because no production route consumes this lexer yet.
