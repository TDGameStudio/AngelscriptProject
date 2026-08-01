## 1. Candidate intake

- [ ] 1.1 Record one bounded algorithm, its UE authority, its Standalone consumer, and the exact observable result that may need compatibility.
- [ ] 1.2 Reject the candidate if it requires UE descriptors, reflection materialization, asynchronous UE IO, callbacks, UObject/ClassGenerator ownership, or broader Compat emulation.

## 2. Characterization

- [ ] 2.1 Add focused UE tests that freeze the current production behavior before changing ownership or dependencies.
- [ ] 2.2 Add or identify Standalone tests proving that the same semantics are required by a real supported workflow.
- [ ] 2.3 Record intentional host differences and keep separate implementations whenever normalized behavior is not identical.

## 3. Candidate implementation

- [ ] 3.1 Choose duplication, a host-local adapter, or one value-only helper using the smallest-dependency option supported by evidence.
- [ ] 3.2 If a helper is extracted, keep it algorithm-specific and prohibit session, descriptor, reflection, source-loading, callback, or host-lifecycle ownership.
- [ ] 3.3 Switch production use only after the focused UE and Standalone tests pass with unchanged observable results.

## 4. Verification

- [ ] 4.1 Run the affected Standalone CTest and narrow UE Automation prefix plus a UE Development build when includes or compilation structure change.
- [ ] 4.2 Validate this OpenSpec strictly and document whether the candidate was shared, adapted, or deliberately left duplicated.
