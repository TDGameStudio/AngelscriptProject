## Why

The replacement frontend currently coexists with two older ASTs. Its preprocessor orchestrates semantic compilation, delayed bodies do not consistently reuse the original preprocessing configuration, and runtime type/function metadata assumes an existing engine. These boundaries prevent independent stage testing and keep language changes coupled to dormant execution backends.

## What Changes

- Make the reconstructed typed AST the only active AST and remove both legacy AST implementations, without a conversion fallback.
- Make Builder stages independently executable and inspectable without an AngelScript engine; preserve source provenance and structured diagnostics.
- Restrict preprocessing to directives and token selection. Parse reflection markers and delegate/event declarations as language syntax, reject the removed asset declaration and import syntax, and expose declaration/resolution outputs to an optional host consumer.
- Create real type/function objects in explicit definition images, with atomic external lifetime and transactional, same-pointer, single-engine registration.
- Expose one BLAKE3-256 stable identity value; keep canonical identity, definition and layout validation internal rather than copying nested public witnesses.
- Consolidate reconstructed C++ declarations directly into the existing BEGIN_AS_NAMESPACE scope after old same-name implementations exit. Remove nested frontend qualification and compatibility aliases; retain the outer AS namespace macros and permit the source/frontend directory.
- Close the review-required holes in frozen field/owner admission, conversion projection/codec authentication, and Sema const/handle/foreach agreement before that namespace cutover. These are omitted checks on existing contracts, not new language features.
- Expand meaningful replacement NativeEngine CQTests, including negative, concurrency, lifetime, rollback and phase-composition coverage.

## Capabilities

### New Capabilities

- `angelscript/language/types/definitions`: detached type/function definition construction, image ownership, freezing and engine binding.
- `angelscript/language/frontend/builder`: engine-independent stage orchestration and observable outputs.

### Modified Capabilities

- `angelscript/language/ast/core`: one typed AST, canonical AS C++ names and no legacy fallback.
- `angelscript/language/frontend/lexing`: reflection and callable-declaration keywords.
- `angelscript/language/frontend/preprocessing`: directive-only work with retained body tokens.
- `angelscript/language/frontend/declarations`: native delegate/event declarations and removed-syntax diagnostics.
- `angelscript/language/frontend/bodies`: complete staged analysis without premature sealing.
- `angelscript/language/frontend/reflection-dependencies`: declaration versus resolved host outputs, without UObject creation.
- `angelscript/language/types/stable-identity`: a fixed public hash and internally owned canonical witnesses.

## Impact

Implementation and tests belong to the `Plugins/Angelscript` Git submodule, primarily Runtime ThirdParty and replacement NativeEngine tests. The parent repository owns this Change and durable specifications. Existing uncommitted work is the input baseline and must be preserved.

UE basic types are allowed. The host remains UE 5.8, but ordinary frontend tests create neither `asCScriptEngine` nor `FAngelscriptEngine`. Only explicit registration tests create a local AS engine. Legacy runtime startup, legacy tests, bytecode/VM execution, cache, JIT, hot reload and Standalone remain dormant or excluded. Metadata registration does not promise executable script code. No worktree creation, push, integration or workspace removal is authorized.
