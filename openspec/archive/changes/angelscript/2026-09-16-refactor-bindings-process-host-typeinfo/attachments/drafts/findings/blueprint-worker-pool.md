# Blueprint registration worker pool

English rendering of Q51-Q58 and the 2026-09-15 worker finding.

A task is one UClass, not one UFunction: its worker exclusively owns the class's mutable member tables. A fixed group of N workers repeatedly obtains one index using atomic Next++. Join each wave before dependent work. Static global functions stay serial.

Existing repository patterns include AnalyzeBodies fixed stride, Lex batched work and cache preparation atomic-index work. Class sizes vary, so Q54 selected a single-class dynamic work item rather than stride or a batch knob.

Q53 selected a CVar only. Q55 limits it to Create/member write waves. Q56 selects default N=1. Q57 names it as.Bind.WriteWorkers; Q58 makes zero equivalent to one. Read once for a coherent collection run. Preparation retains as.Bind.ParallelPrepare rather than sharing the worker-count control. The design requires actual class concurrency and semantic equivalence, not a speedup claim.
