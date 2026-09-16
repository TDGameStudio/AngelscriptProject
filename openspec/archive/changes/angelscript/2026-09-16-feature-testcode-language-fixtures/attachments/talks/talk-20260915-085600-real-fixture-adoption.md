# Use a real struct fixture without losing framework proof

## Context

The accepted draft selected a complete hand-authored source corpus and Counter retirement. The current source check identified the exact provider and test boundaries.

## Evidence

Q10/Q106/Q108/Q110 and current GeneratedSourcesTests.cpp, AdoptionTests.cpp and test_source_parser.py.

## Options

Copying the old host tree or delivering only a demonstration file conflicts with the accepted scope. Replacing every Counter string would damage isolated tool/framework controls.

## Settled Decision

StructFields replaces production Counter in global integration tests. Preserve exact annotation/origin/metadata checks and move parser-test input to a private annotated fixture before deleting public Counter.

## Consequences

Maintain exact author/projected pairs and preserve source-only admission semantics. Implementation tasks and focused proofs remain separate from language execution.

## Flip Condition

Evidence that the accepted pure-language shape requires an excluded host contract triggers a focused replan without silently reducing the 47-file scope.

## Sources

[Design](../drafts/design.md), [handoff](../drafts/handoff.md), [migration check](../drafts/findings/migration-check.md).
