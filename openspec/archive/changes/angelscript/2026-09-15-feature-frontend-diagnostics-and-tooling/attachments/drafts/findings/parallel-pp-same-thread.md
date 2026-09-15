# Same-thread preprocessing after each file's lexer

English translation of angelscript/diagnostic-engine/findings/parallel-pp-same-thread.md, 2026-09-14. Q17 accepts the per-file gate.

Process consumes one completed RawTokens array, immutable source data, frozen flags and a diagnostic engine. It is const, creates its own IdentifierOwner and does not mutate the Builder session identifier table. This frontend has no macros or include stack creating inter-file PP prerequisites.

Previously Builder completed all Lex work, tested global HasErrors, then ran PP sequentially. One lexical error prevented PP for every file. Immediate same-worker PP changes that policy: clean files retain useful PP products even when compilation fails elsewhere.

```text
Worker acquires file                    // All input configuration already frozen
└─ Lex and Flush                        // This file's Intern operations are complete
   └─ No local lexical error/failure    // Never use global HasErrors here
      └─ Process its RawTokens          // Own PP table; no lexical table lock
         └─ Store local result          // Join merges and aligns by source key
```

PP does not wait for other tokens, a fully populated session intern table, declarations or types. A hypothetical dedicated asynchronous Intern thread would add a per-file completion wait and is not selected. Same-thread execution keeps token data local and avoids a second pool.

Builder must reconcile early PP computation with its Lexed/Preprocessed stage machine. Do not concurrently Add to State.Preprocessed or execute PP a second time at the public Preprocessed transition. Failed PP clears that file's ActiveTokens. Declaration collection retains the complete-source barrier and may not interpret partial PP availability as publication success.

The rejected global-gate alternatives were to wait for all Lex before parallel PP, or discard speculative PP results on any lexical failure. Q17 explicitly keeps clean results instead.
