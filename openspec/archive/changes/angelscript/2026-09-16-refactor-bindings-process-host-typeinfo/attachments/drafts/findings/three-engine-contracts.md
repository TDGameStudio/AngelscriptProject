# Three execution contracts

English rendering of the 2026-09-16 finding. These consequences follow the accepted host-sharing direction.

## Context.Prepare

Current Prepare requires m_engine == func->GetEngine(). A HostProcess function returns null, so A and B would both fail. Source execution ownership from Context and additionally verify the exact host function and its dependencies were injected into that Engine. Script/live functions still require their own Engine. JIT diagnostic paths that compare Function.GetEngine must be checked as well.

## Process type and function IDs

Current BindInfo publications share numeric IDs across distinct objects. The accepted graph shares actual pointers. Its BoundTypeIds and BoundFunctionIds cannot be rewritten by each injection. Assign them before the host bag is published through the existing process registry, then insert the same IDs into A/B. Script/live private identity retains its own registration lifecycle.

## Isolation proof

The current PrepareOnceTwoEngines case expects different pointers and A/B GetEngine values. New host checks require one pointer, one ID and null GetEngine, with a survivor after either Engine is destroyed. Retain rejection of foreign private functions and mutable adapter/auxiliary separation. Do not delete isolation simply because host identity is now shared.
