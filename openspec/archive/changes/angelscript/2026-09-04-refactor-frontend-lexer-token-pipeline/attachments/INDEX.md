# INDEX

## Current position

All five tasks and completion verification are complete. The final incremental build, exact 12-test Lexer Fast prefix, current capability synchronization, strict validation, and terminal issue disposition are ready for completed closure.

## Hard conclusions

- The new `asCTokenizer` owns a pull cursor and consumes frozen options; it never reads a live Engine.
- Tokens borrow immutable source ranges, identifiers are session-interned, and complete token buffering is opt-in.
- Clang-inspired optimization means measured direct scanning and compact data, not importing the C preprocessor or grammar.

## Forbidden

- Do not make all scanner helpers public, add a `V2` production route, introduce macro expansion, or use runtime IDs as lexical identity.
- Do not claim a fixed cross-machine performance threshold from one UE run.

## Attachment index

- `talks/talk-20260905-010200-streaming-tokenization-boundary.md` — decision between pull tokenization and mandatory whole-stream buffering — read before changing tokenizer ownership or parser lookahead.
- `knowledges/clang-lexer-hot-path.md` — candidate guidance distilled from Clang Lexer and current AngelScript coupling — read when implementing or measuring lexical hot paths.
- `replans/replan-20260905-025410-unique-tokenizer-implementation.md` — applied cross-Change correction using a unique `.cpp` basename while preserving the final `frontend::asCTokenizer` identity — begin Task `1.1`.
- `implementation/issue-20260905-031019-ue-test-missing-envelope.md` — rejected, non-reproduced observation where one synchronous caller returned no envelope before its managed UE test worker finished; exact run artifacts remained complete — relevant when diagnosing result-wait behavior, not lexer behavior.
- `data/lexer-baseline.md` — checked-in corpus definition, cold/warm allocation evidence, process-memory context, timing, environment provenance, and the explicit non-threshold boundary — read before comparing lexer hot-path measurements.
- `data/lexer-verification.md` — TDD sequence, final managed run IDs, 12-test report, final content hashes, durable synchronization, and explicit impact exclusions.
- `data/completed-closure.yaml` — explicit completed disposition consumed by the deterministic OpenSpec archive operation.
- `data/workflow-evaluation.md` — canonical completed-closure evaluation written last against the final active Change digest.
