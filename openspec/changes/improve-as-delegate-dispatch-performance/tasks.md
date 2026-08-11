## 1. Baseline and test design

- [ ] 1.1 <!-- Non-TDD --> Audit existing delegate, Blueprint-event, and StaticJIT automation fixtures; select the smallest existing harnesses for interpreter, AOT/native-form, and hot-reload coverage.
- [ ] 1.2 <!-- TDD --> Add focused correctness fixtures for script-declared single-cast and multicast delegates with primitive, value-struct, and reference/container parameter shapes.
- [ ] 1.3 <!-- Non-TDD --> Add a repeatable benchmark harness that separates bind/setup, warm-up, and dispatch measurements; report single-cast and 1/4/16/64 multicast-listener cases.
- [ ] 1.4 <!-- Non-TDD --> Capture baseline results for interpreter, StaticJIT, C++ dynamic delegate, and—where semantically comparable—C++ native delegate paths under the same test environment.

## 2. StaticJIT coverage

- [ ] 2.1 <!-- TDD --> Add StaticJIT generated-output or native-form diagnostics tests proving single-cast delegate execution uses the delegate native form.
- [ ] 2.2 <!-- TDD --> Add StaticJIT generated-output or native-form diagnostics tests proving multicast event broadcast uses the multicast native form.
- [ ] 2.3 <!-- TDD --> Verify JIT parameter marshalling and reference copy-back match interpreter results for the selected delegate signatures.

## 3. Interpreter dispatch investigation

- [ ] 3.1 <!-- Non-TDD --> Profile the interpreter `FScriptCall` path to attribute cost among argument construction, UFunction lookup, signature validation, listener enumeration, and UE `ProcessEvent` dispatch.
- [ ] 3.2 <!-- Non-TDD --> Design an invalidation-safe compatibility-validation cache only if baseline evidence identifies repeated validation/preflight as material.
- [ ] 3.3 <!-- TDD --> Before implementing any cache, add regression tests for signature-changing full reload, Blueprint reinstance, listener mutation, and destroyed listeners.
- [ ] 3.4 <!-- TDD --> Implement and verify the smallest measured optimization; preserve the conservative validation fallback when cache identity or generation is stale.

## 4. Guidance and decision closure

- [ ] 4.1 <!-- Non-TDD --> Publish measured results and the chosen optimization/no-change decision in a benchmark note under this change directory.
- [ ] 4.2 <!-- Non-TDD --> Update delegate guidance to distinguish UE-reflected `delegate` / `event` from a future pure-script `funcdef` callback path.
- [ ] 4.3 <!-- Non-TDD --> Decide whether generated delegate source sections/provenance metadata need a separate follow-up based on benchmark and StaticJIT diagnostic needs.
- [ ] 4.4 <!-- Non-TDD --> Run focused build and test commands through `Tools\RunBuild.ps1` and `Tools\RunTests.ps1`; record exact commands and outcomes before closing the change.
