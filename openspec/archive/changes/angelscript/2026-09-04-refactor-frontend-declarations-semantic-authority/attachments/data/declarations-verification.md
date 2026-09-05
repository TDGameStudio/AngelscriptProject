# Declaration semantic authority verification

## Focused TDD sequence

- Collection RED build 121ae5f9c0014d3ebac67a6ba05f649e established the missing compilation-session boundary.
- Collection GREEN build ad98acdc1f5b426e9369b8db576bae3e and focused run db747b1231844d54883bf26fcf400ac4 passed the first 6/6 declaration scenarios.
- Resolution RED build 3d253d448cfc4922949e81891650f268 failed only on the six deliberately missing session-resolution APIs.
- Intermediate build 8cbf1429be924611af7ac4ba0ca0ae49 exposed one missing typed-AST cast include and was repaired locally without changing the plan.
- Final build db53e5d3e1cf45ea9ab51c65abbd2afd succeeded.
- Final exact Fast run 8b39ac6637304c9da3991bcd196e8285 passed 12/12 with zero failures, skips, warnings, errors, or incomplete tests. Report: Saved/Harness/Unreal/Runs/8b39ac6637304c9da3991bcd196e8285/AutomationReport/index.json.

## Verified surfaces

- Parser drives typed Sema actions and constructs concrete declaration subclasses without a live Engine or Builder.
- Every logical source contributes declarations before the one-way resolution barrier closes.
- Later-file types, bases, variables, parameters, and function return types resolve through frontend-owned identities.
- Stable source/range ordering selects duplicate primaries and stable semantic signatures order overload sets.
- Recovery nodes retain typed ranges while later valid declarations remain queryable and the overall result becomes non-publishable.
- Reversed source submission and one-versus-four worker requests produce equal stable declaration and diagnostic projections.
- Function bodies remain deferred source ranges; no body semantics, reflection output, runtime objects, bytecode, or VM state are produced.

## Representative final content hashes

| File | SHA-256 |
|---|---|
| as_compilation_session.h | e78b359df43a497304d3c59c9444143c5b22608e83bef570ff45bafa376f40fc |
| as_compilation_session.cpp | 692b2aa0affc9c0f1d4ab6688c95ab5d8633e5cb5b096fcc9acbfc2839d7af18 |
| as_frontend_parser.cpp | 1c2df973e2af6ffab1333134f72efe45f4743c46eed88e449b08047910da6e5c |
| as_frontend_sema.cpp | 22e86d6e42782f3055aae823fc2c62e83cc0dff6e3bc9c7ca288af4cc5ff3dda |
| DeclarationSemanticTests.cpp | 930ca820ebcf5dc9a5910978af476bd0122eae63b2c5805850a871a12d053113 |
| current declarations spec.md | fd43126756132c2d8fdd0dee0746be70b7a5b5755dd21733a7aa85a611551cab |

## Lifecycle and scope

- Strict Change validation 3c2ee2e3a71843c6bb7a249393cb9d03 passed 1/1.
- Strict current-spec validation 292e595624634ea4b8fa6e2a42de4fb7 passed 12/12.
- Doctor f5e34cdfc05c418da1b996f8abb2249c returned zero diagnostics.
- TaskPlan 91071b0fbdc0410c8d3e49314923e262 reported 5/5 complete.
- The complete delta and accepted declaration-barrier knowledge are synchronized into angelscript/language/frontend/declarations.

Aggregate Harness profiles, full UE suites, Standalone, retained production Parser/Builder, reflection generation, bytecode, and VM tests were intentionally omitted. The Change adds an isolated declaration frontend with no production consumer; the Editor build and complete 12-test Declarations prefix are the smallest complete proof.
