# Task 1.5 verification: recording ownership

## Outcome

Detached records now classify copied Store values separately from borrowed host targets. Pure constants use `CopiedRecord`; valid native function entry points, auxiliary payloads and global storage use `BorrowedHost`; absent pointers use `None`. Root and named namespace scopes remain distinct from each other and from equally named nominal types. A sealed Store rejects every public mutation while retaining records, source provenance, policy and reflection attachment. Separate Engines can retain one Store/snapshot independently, and the final owner releases it.

## RED and setup

The first compilation attempt, Harness build `296488a4aeee41f8b94a38bcbc1c8df0`, was a fixture setup failure because a `TSharedRef` was reset; it is not behavioral RED. The next incremental build exposed an existing missing direct `as_scriptengine.h` include in the state-dump translation unit after unity composition changed, plus the corrected test overload requiring `ToSharedRef`; build `685cfd4fbf72495cb3f386e720468020` failed with exit 6 and is also setup evidence.

After these compilation issues were corrected, build `ba4c0ad91e7f4197806d928a9dec87ff` succeeded. Harness run `a384c262a2bd4202bacf921c272e5ece` then completed all six Ownership cases with four controls successful and two failures:

- `CopiedConstantsAndBorrowedTargetsExposeTruthfulLifetimes` failed because recorded lifetime fields retained `None`.
- `SealRejectsEveryMutationAndPreservesSnapshotAndProvenance` failed only because its control expected one record and omitted the automatically created root namespace; the independently observable invariant was two unchanged records, so the expectation was corrected before GREEN.

The RED process exited 255 with two test errors and no warnings. Scope isolation, policy isolation, two-owner snapshot retention and reflection policy mismatch were successful controls.

## GREEN

- Build: Harness run `9a33a57cc22c469eba7d1ef61ed58201`, `AngelscriptProjectEditor Win64 Development`, succeeded with exit 0.
- Exact selector: Harness run `9574d98b193644f0abf1f3c64b5649fe`, `Angelscript.UnitTest.RuntimeBindings.Recording.Ownership.`, complete and valid; six of six succeeded, zero warnings/errors/skipped/not-run/in-process.
- Adjacent facade selector: Harness run `ba9cbbcb564249a4b7b914ddea7b58c5`, `Angelscript.UnitTest.RuntimeBindings.Recording.Facade.`, complete and valid; eight of eight succeeded with zero warnings or errors.

The six exact cases were:

1. `CopiedConstantsAndBorrowedTargetsExposeTruthfulLifetimes`
2. `DifferentPolicyCapturesDoNotShareMutableRecords`
3. `ReflectionPolicyMismatchPublishesNoAttachmentOrTypes`
4. `RootNamedScopesAndNominalTypesKeepDistinctIdentity`
5. `SealRejectsEveryMutationAndPreservesSnapshotAndProvenance`
6. `TwoOwnersRetainOneSnapshotUntilTheLastOwnerReleases`

## Verified identities

- `Core/AngelscriptTypeBindInfo.h`: `C3E1965DF98291D1FAAF3283584762CCD9ECC86FF1156F710D83735AF6064FD5`
- `Core/AngelscriptBinds.cpp`: `13083D191289BFB716D844699984432F510F4335BCC33508028E4D59313E9B27`
- `RuntimeBindingOwnershipTests.cpp`: `C907867D10350A3064A03405907AF013A5BA6805A25F6073D60246D143098645`
- `UnrealEditor-AngelscriptRuntime.dll`: `7DD6792DBC064F3C762C277C872D92AEEF910CCDBED464A49D75F0D3017C3471`
- `UnrealEditor-AngelscriptTest.dll`: `E2AAAD7890186E60B02C1E06FBD4AB1CD8F0FF5B01FA70E16E80249E1DB3940E`

The heavier RuntimeBindings aggregate and baseline were omitted because the exact ownership selector and the directly affected Facade authoring selector cover this Store/facade change. Engine invocation and baseline behavior were already proven by the consumed task 3.3 and were not modified here.
