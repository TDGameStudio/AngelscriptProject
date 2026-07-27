# Class Fields and Script Properties

## Elements and dimensions

| Axis | Values |
| --- | --- |
| Property form | active stored/initialized/inherited field; active removed-decorator and automatic-access rejection; direct native `GetX`/`SetX` method where applicable; compiled Disabled positive registered getter/setter and indexed accessor compatibility sources |
| Value type | primitive families, enum/alias, value object, automatic reference/null, funcdef where legal |
| Receiver | mutable instance, const instance, base view, derived view, null reference |
| Access site | owner method, constructor, destructor, derived type, unrelated type, global function, accessor body |
| Visibility | default/public, private, protected; fork-specific semantics recorded exactly |
| Operation | default read, write, compound write, copy, reference mutation, getter call, setter call, indexed read/write |
| Initialization | default, declaration initializer, constructor assignment, base/member order, copy construction, assignment, rebuild/load |
| Accessor signature | exact, const getter, value/ref return, index type overload, value parameter direction, missing half, invalid registration, recursive/throwing callback |

## Required products

- `Fifteen core value types × stored operation(default read/write/compound/copy/reference mutation) × mutable/const/base/derived receiver` covers value, identity, copy independence, metadata, and current-fork const legality. Const writes and unsupported compound operations are isolated located rejections followed by clean recovery rather than unobserved cells.
- `Stored read/write × visibility × ten concrete owner/inheritance access paths` avoids meaningless independent site/relation pairs while covering owner methods, constructors, destructors, explicit accessor bodies, direct/deep derived types, unrelated types, globals, and base/derived views.
- Eighteen concrete raw-SDK registered accessor scenarios × single-line/multiline/parenthesized/helper-call source shape are retained as positive selected-2.38 compatibility sources. Current-fork execution instead proves decorator parsing/registration rejection, automatic-access lookup rejection, direct method behavior where representable, source-first reporting, cleanup, and recovery.
- `Thirteen scalar index types × same-type/adjacent-numeric/cross-family/two ordered-competing/unrelated candidate set × read/write/compound × mutable/const receiver` is retained as selected-2.38 positive compatibility coverage. Current-fork products isolate decorator registration and automatic bracket-access rejection; a direct method route is used only when it observes a distinct current-fork method contract rather than pretending bracket access survived.
- `Fifteen field value types × default/declaration/owner-literal/owner-source/derived-reassignment source × base-first/base-middle/base-last/derived-first/derived-last position × base-entry/base-exit/derived-entry/derived-exit checkpoint` proves availability, value transitions, declaration marker order, property index, and lifecycle at 1,500 concrete construction observations. Assignment from a source object remains assignment evidence; it is not mislabeled as primitive copy construction.
- `Seventeen value/reference field types × copy/assignment/self-assignment × source/target/nested mutation × exact/base/derived view` proves value independence, intentional reference identity, and lifecycle balance.
- Fourteen removal/registration/access/runtime failure kinds × fresh/same-state recovery × direct/alternate probe isolate removed script accessor syntax, missing or invalid registered accessors, recursion, exceptions, null access, visibility, and value-receiver compound restrictions. Alternate probes use helper/parameter access for source/runtime failures or reverse declaration/registration order for declaration/registration failures; they are not formatting-only duplicates.
- Four script decorators, four native property registrations, four automatic member/bracket forms, and one ordinary direct-method control are thirteen distinct current-fork scenarios. Each proves its own parser, registration, lookup, or executable contract; the direct method never substitutes for property-language support.
- Fifteen form-specific change scenarios retain the existing stored/registered/registered-indexed source depth, but must be split before they count as current-fork evidence: stored-property rebuild/save-load remains active; positive registered/indexed accessor paths are Disabled selected-2.38 compatibility coverage; enabled rejections prove the current parser/registration/compiler boundary with their source and cleanup paths.

## Product ownership and scale

| Product ID | Cases | Purpose |
| --- | ---: | --- |
| `LANG-PROP-VALUE-OP` | 300 | Stored-field operations across all core value types |
| `LANG-PROP-VISIBILITY` | 60 | Stored-field reads and writes through concrete visibility paths |
| `LANG-PROP-ACCESSOR` | 72 | Existing positive registered-accessor source depth; pending split into selected-2.38 Disabled compatibility and current-fork rejection/direct-method evidence |
| `LANG-PROP-INDEXED` | 468 | Existing positive indexed-accessor source depth; pending split into selected-2.38 Disabled compatibility and current-fork rejection/direct-method evidence |
| `LANG-PROP-INIT-ORDER` | 1,500 | Field initialization, declaration position, and value transitions across four construction checkpoints |
| `LANG-PROP-COPY-INDEPENDENCE` | 459 | Value independence and reference identity after transfer |
| `LANG-PROP-FAILURE` | 56 | Isolated declaration/access/runtime failures through direct and alternate paths, followed by recovery |
| `LANG-PROP-FORK-SEMANTICS` | 13 | Exact current-fork decorator, registration, automatic-access, and ordinary-method boundary |
| `LANG-PROP-REBUILD` | 90 | 30 active stored rebuild/save-load observations plus 60 retained registered/indexed source paths pending a dedicated discoverable Disabled selected-2.38 owner |

The files presently contain 3,018 designed source cases. That is not an active-current-fork total: the 72 registered and 468 indexed positive source cases are discoverable Disabled but still require future reference-declaration normalization; the registered/indexed portion of the 90 rebuild cases is retained source only pending a dedicated discoverable Disabled owner. The additional thirteen are active current-fork boundary scenarios, not positive accessor compatibility cells. Each resulting active or Disabled case still owns the evidence declared by its product; the count does not permit compile-only substitutes for runtime, metadata, lifecycle, debug, bytecode, cleanup, or isolation behavior.

## Interaction and failure coverage

Property + constructor + inheritance, property + operator compound assignment, property + overload conversion, property + exception during registered getter/setter callbacks, null receiver, inaccessible field, read-only write, write-only read, removed script syntax, invalid registration, recursive callback, and rebuild/save-load behavior are required.

## Current fork accessor boundary and reclassification

Commit `3056cf2` deliberately rejects both script and application `property` decorators in `as_parser.cpp`. The bare raw SDK defaults `asEP_PROPERTY_ACCESSOR_MODE` to `3`, but this does not restore an application path: mode `3` requires `IsProperty()`, and the removed decorator was the declaration route that supplied that trait. The UE wrapper's mode `0` is unrelated. The resulting enabled fork coverage is stored fields, exact decorator/registration/automatic-access rejection, and direct method behavior where it has an independent contract. Positive registered and indexed accessor sources are compiled Disabled selected-2.38 compatibility coverage with the `#as-v238-backport` tag.

`LANG-PROP-FORK-SEMANTICS` is owned by
`AngelscriptNativePropertyForkSemanticsTests.cpp`, the enabled raw-SDK owner
for the complete current-fork accessor boundary. It prints and rejects
four script decorator forms (getter, setter, indexed getter, indexed setter),
asserts the exact removed-decorator diagnostic, and confirms that the rejected
module is discarded. It then uses one fresh engine per native decorator
registration, asserts `asINVALID_DECLARATION (-10)` and its retained SDK
diagnostic, and discards that poisoned configuration. A separate fresh engine
registers ordinary `GetValue`, `SetValue`, `GetIndexedValue`, and
`SetIndexedValue` methods; it prints and rejects four automatic member forms
(read, write, indexed read, indexed write), proving zero callback execution
and the precise missing-member diagnostic. Finally it prints, compiles, and
executes an ordinary method control, asserting result `88`, exactly two getter
callbacks, exactly two setter callbacks, balanced carrier lifetime, and module
cleanup. Calling the direct methods is recorded solely as normal-method
coverage; it is never evidence that `Receiver.Value` or `Receiver.Value[...]`
works in the current fork.

The thirteen recorded scenarios are a named set rather than unrelated
combinations: four script decorators, four native registration declarations,
four automatic member/bracket source forms, and one direct ordinary-method
control. Each differs in parser, registration, lookup, or executable behavior
and retains its own stable evidence.

An expected invalid `RegisterObjectMethod()` call invokes SDK configuration
error handling and makes its engine unsuitable for a later module build. The
owner therefore deliberately isolates each rejection engine from the
automatic-access engine. This is a test lifecycle requirement, documented as
`LANG-003`, rather than a suppressed compiler failure.

The indexed-accessor lookup code remains relevant only to the Disabled positive compatibility sources until the prerequisite is backported. Its 2.38 setter-ambiguity assertion stays compiled Disabled under `V238-DESIRED-BEHAVIOR`; neither candidate insertion order may be reported as active fork execution meanwhile.

## Cross-theme impact and ordered repair plan

The following source audit is mandatory before any owner is re-enabled or a full-prefix count is recalculated. It is intentionally broader than `Language/Properties`: generated sources in other themes also register a property trait or consume automatic property syntax.

| Affected owner / file | Current incompatible route | Required classified replacement | Focused verification after the coherent source batch |
| --- | --- | --- | --- |
| `LANG-PROP-ACCESSOR`; `AngelscriptNativeRegisteredPropertyTests.cpp` | `get_Value` / `set_Value` declarations with `property`, then `Receiver.Value` | Class is now discoverable Disabled; normalize its reference spelling before calling it selected-2.38 compatible. The active fork owner supplies parser/registration/automatic-access rejection and direct-method cells | Fork-semantics owner, Disabled discovery, and no generated source may print after a failure-capable registration gate |
| `LANG-PROP-INDEXED`; `AngelscriptNativeIndexedPropertyTests.cpp` | Indexed `get_Value` / `set_Value` property declarations and bracket syntax | Class is now discoverable Disabled; normalize its reference spelling before calling it selected-2.38 compatible. The active fork owner supplies decorator/bracket rejection and direct-method-only coverage | Fork-semantics owner, Disabled discovery, and selected-2.38 owner remains non-executing |
| `LANG-PROP-REBUILD`; `AngelscriptNativePropertyRebuildTests.cpp` | Registered/indexed rebuild and save/load forms | Retain the five stored forms active; retained positive accessor paths require a dedicated discoverable Disabled owner before they can count. Keep exact rejection products alongside stream determinism controls | PropertyRebuild owner then Properties parent |
| `LANG-PROP-FAILURE`; `AngelscriptNativePropertyFailureTests.cpp` | Assumes a positive registration stage before failure cases | Rewrite expected stage to committed parser/registration rejection while retaining source, location, recovery, and cleanup | Property Failure owner |
| Expression primary, chain, resolution, and value-category files | Native property registration or `Receiver.Member`/indexed automatic access | Split property-bearing IDs from field/call IDs; use fields or direct methods only when they test a different active contract, otherwise mark desired positive sources Disabled | Each individual expression owner, then Expression parent |
| Increment and assignment operator files | Registered property targets used as active writable lvalues | Keep local/field/reference targets active; replace property-target rows with exact current-fork rejection and Disabled positive compatibility rows | Increment and Assignment owners |
| Conversion ABI/resolution and any embedding/compiler declaration owners | Registered property trait declarations appear in a broader registration/metadata fixture | Audit each occurrence; retain independent registration behavior, but make decorator acceptance/rejection exactly current-fork rather than incidental | Affected owner prefix and registration/compiler parent |

Every replacement preserves the existing stable identifier mapping or records an explicit predecessor-to-successor mapping. Each source must print before its first registration, compile, or execution operation so a rejected declaration is reviewable in its automation artifact.

## Planned ownership

- `Language/Properties/AngelscriptNativeStoredPropertyTests.cpp`
- `Language/Properties/AngelscriptNativePropertyInitializationTests.cpp`
- `Language/Properties/AngelscriptNativePropertyCopyTests.cpp`
- `Language/Properties/AngelscriptNativePropertyAccessTests.cpp`
- `Language/Properties/AngelscriptNativePropertyVisibilityTests.cpp`
- `Language/Properties/AngelscriptNativeRegisteredPropertyTests.cpp`
- `Language/Properties/AngelscriptNativeIndexedPropertyTests.cpp`
- `Language/Properties/AngelscriptNativePropertyInheritanceTests.cpp`
- `Language/Properties/AngelscriptNativePropertyFailureTests.cpp`
- `Language/Properties/AngelscriptNativePropertyForkSemanticsTests.cpp`
- `Language/Properties/AngelscriptNativePropertyRebuildTests.cpp`
