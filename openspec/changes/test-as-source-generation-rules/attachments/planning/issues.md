# Planning Issues and Resolutions

## Existing generator depth is insufficient

The current Python model stores functions as name + return type + statement source and currently constructs one no-argument `int` function. UE definitions are fixed profile fragments. Resolution: the new contract makes definitions, signatures, calls, return/writeback, metadata, lifecycle, and other oracles first-class recipe/result data.

## Determinism does not yet imply cross-language parity

The current tool derives a Python `random.Random` seed through BLAKE2. This is deterministic inside Python but is not the requested portable algorithm contract. Resolution: specify `SplitMix64-v1`, FNV-1a, rejection sampling, Fisher-Yates, and named substreams with shared vectors and independent implementations.

## Existing SDK products are exhaustive but encoded in C++ helpers

The Native SDK already has reviewed product/cardinality records, but source rules live in method-specific builders. Resolution: create one declarative rule per ProductId while leaving the builder unchanged until a later adoption change.

## Coverage and inline classifications cannot be trusted from names alone

The initial scripts use conservative path/name/source-shape heuristics to create a reviewable candidate catalog. Resolution: every owning inline file has a review task; generated candidates have no enabled random domain until axes/oracle/host requirements are manually confirmed.

## Old TestCode experiment used static registration

The experiment had useful CaseKeys and a unified class name, but mutable registration, limited oracle kinds, ForceLink pressure, and source-corpus coupling are unsuitable for the release boundary. Resolution: keep `FAngelscriptTestCode`, replace registration with generated direct static functions and a sorted immutable dispatch table, and return a complete result.

## Planning scale is intentionally large

The 3,276 checkboxes and multi-megabyte catalogs are deliberate: implementation can be reviewed per authored file/product/method without rediscovering scope. Mechanical files are regenerated and strictly validated rather than hand-maintained.
