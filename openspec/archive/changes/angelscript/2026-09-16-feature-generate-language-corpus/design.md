# Complete Language source generation

## Accepted objective and provenance

Source identity: angelscript/test-code-language-corpus, selected design testcode-combinatorial-recipes. This is an English consolidation of the selected design and the user's explicit 2026-09-15 scope correction and creation instruction. The user selected all 122 products in one Change, with ForLoop as the existing baseline, and authorized selected talks and knowledge to be summarized into this Change. Earlier first-batch-only handoff text is superseded.

Deliver all 122 directly constructible C++ generator products and all 36,686 currently declared filtered cells. A batch is task scheduling, never permission to omit products. The product catalog in attachments/drafts/findings/ is the complete scope inventory. A discrepancy requires explicit evidence and a plan correction; it never silently reduces the accepted inventory.

## Ownership and architecture

Generators belong to Plugins/Angelscript/Source/AngelscriptTest/Framework/Generate. Tests and bounded reviewed gold samples belong to FrameworkTests. Keep FCodeGenerator empty and construct each specialized subclass directly in AngelscriptTest::Generate. Each product owns its typed parameters, axes, enumerator, constraints, source assembly and expected-result calculation. Do not add a registry, Get<T>() manager, general constraint compiler, templating language, random sampling infrastructure or JSON recipe interpreter.

```text
Caller constructs a product                    // No registry or ambient engine is needed.
  -> ListCases()                              // Returns IDs, exact entry declarations and typed expectations.
  -> BuildCaseSource(CaseId)                   // Generates a canonical case for isolated replay.
  -> typed single-case builder                 // Produces owned source for one requested shape.
  -> BuildAllSource(OutCaseCount)               // Produces the product's deterministic non-reject module.
  -> BuildRejectSource / ListRejectCaseIds      // Keeps each compile-reject module separate.
  -> GetExpected(CaseId)                        // Returns the documented int32 observation where defined.
```

The existing Python code-database projection and hand-authored Language containers remain separate. This Change does not enable Legacy tests or the legacy runtime, instantiate Builder/VM, compile generated AS, or execute generated AS. It does compile and run the C++ generator tests through Harness UE routes during implementation.

## Enumeration and source contract

- Freeze product IDs, short class names, axis tokens and axis nesting order from the catalog and its cited legacy source. Multiword tokens retain internal underscores; hyphens separate axes. Entry names are Entry followed by the PascalCase conversion of the complete CaseId. Single-case FunctionName defaults to Entry. Parameters are product-specific; a copied Limit sentence does not add a numeric parameter to unrelated products.
- BuildAllSource counts emitted non-reject entries, including runtime-fault fixtures. Reject IDs are enumerated in fixed axis order and rendered individually; a reject-only product returns an empty aggregate string and count zero while still generating every reject case.
- Every returned FString owns its source. Repeated calls produce identical bytes and counts and do not share mutable state. Use LF, tabs, Allman braces, one statement per line and blank lines between functions.
- Shared helpers appear once per compatible definition. Case-dependent types, declarations and mutable state use deterministic product/case-qualified identifiers. Resets and initialization belong to the case so another entry cannot alter its expected source assumptions. No expected numeric answer is substituted for the operation under test.
- Modules from different generator products are independent; arbitrary concatenation of product modules is not promised. Host-dependent source remains host-dependent. For conflicting native declarations within ConvAbi, give each cell's external symbol a deterministic CaseId-qualified name and retain its exact declared ABI requirement in the product documentation. Do not claim the combined text is standalone without registration.
- Keep lifecycle variants described by their cards as source variants. PropRebuild emits the documented second-version source and retains all observation/path IDs. It does not claim to execute rebuild, serialization or old-handle cleanup. Preserve those distinctions in the catalog so future execution consumers can supply the lifecycle.

## Observations and failure boundaries

Keep int32 GetExpected as accepted in Q102. Integer observations and type markers retain each card's meaning; 64-bit or floating results represented only by a marker are explicitly limited observations, not exact arithmetic or bitwise proof. ConvAbi's 101/202/1 observation does not replace its independent host ExpectedBits requirement. Future widening is outside this source-generation delivery.

The result categories are normal return, compile rejection, and runtime fault. Runtime fault expectations retain the documented engine strings: Divide by zero; Overflow in integer division; Overflow in exponent operation; Null pointer access; Stack overflow. An explicitly approximated host callback failure is documented separately; replacing its trigger does not establish native-host equivalence. GetExpected is used only for normal observations. Rejected or faulting cases must never be counted as normal-return evidence.

For new products, invalid typed values, invalid explicit function identifiers, unknown CaseIds, or using a reject case in a positive-only single builder return empty source; no partial text is emitted. GetExpected returns zero for IDs outside its normal observation domain, matching the existing ForLoop fallback, and callers must not use that fallback to establish validity. A valid zero observation is not evidence of a valid ID. Consumers establish membership from ListCases and canonical source generation; only tests keep an independent expected ID table as their oracle. ForLoop's established behavior remains the baseline; any shared-contract adjustment is owned by its task and retains all existing fixtures.

## Migration evidence and known card defects

Legacy C++ is dormant source evidence, never a runnable dependency. Preserve generated language structure after the explicitly accepted removed-syntax filtering. Use JSON-only rows as explicit coverage targets where the card establishes them, not as proof they already ran. PropRebuild has 15 declared scenarios and 90 target cells, whereas the inspected C++ ScenarioCases has five stored rows; implement the additional documented variants rather than silently reducing to 30.

Normalize template defects inside the owning product task: remove spurious Limit fields; do not call GetExpected on reject examples; retain product-specific host dependencies; mark approximate observations honestly. If implementation evidence contradicts a requirement or needs a new user-owned behavior choice, use the Change replan route, not a silent omission or a return to brainstorming.

## Verification and completion

Each product task proves its complete declared cell set, category partition, entry naming/order, independent expected observations, representative reviewed gold text, relevant helper/type isolation, and malformed-input behavior. Enumerate every cell for structural checks; gold files are bounded representatives rather than a repository dump of all 36,686 generated sources. Expected tables and gold must be derived independently from the generator under test and linked legacy construction/oracle evidence.

Tests run under Angelscript.UnitTest.Framework.Generate.<ProductClassWithoutF>, except the existing ForLoop test identity remains Angelscript.UnitTest.Framework.ForLoopGenerator. Product tasks are independently bounded. Compatible tests may share an actual Harness run while retaining exact task-to-case and source/binary evidence. The final corpus test constructs all 122 classes, checks the complete product and category totals, and catches missing classes, duplicate IDs, and count inflation by repeated source entries. A passing generator run makes no claim about AS runtime correctness.

Current scope is creation and planning only. All implementation tasks stay unchecked until their real proving runs pass. No commit, push, hand-written corpus migration, broad UE suite or automatic formal Review is part of creation.


## Consumer case enumeration (current contract)

The initial design returned a source string and count but did not expose the normal/fault case set. The user explicitly requested repairing this consumer gap. Every product now exposes `ListCases()` and `BuildCaseSource(CaseId)` in addition to its existing interfaces. The former independent-ID-table advice applies to test oracles only; execution consumers must not reconstruct axes or parse emitted source to discover cases.

### Shared value types and product APIs

Task 1.1 adds the following owned metadata types to `Framework/Generate/AngelscriptTestGeneratedCase.h`, following the existing AngelscriptTest-prefixed header and F/E naming conventions. The common header contains data only. FCodeGenerator remains empty; no registry, manager, virtual enumeration or engine object is introduced.

```cpp
namespace AngelscriptTest::Generate
{
enum class EGeneratedCaseOutcome : uint8
{
    ReturnValue,
    CompileReject,
    RuntimeException,
};

enum class EGeneratedCaseExecution : uint8
{
    Standalone,
    RequiresHostSetup,
    SourceOnly,
};

struct FGeneratedCaseInfo
{
    FString CaseId;
    FString EntryDeclaration;
    EGeneratedCaseOutcome Outcome = EGeneratedCaseOutcome::ReturnValue;
    EGeneratedCaseExecution Execution = EGeneratedCaseExecution::SourceOnly;
    TOptional<int32> ExpectedReturn;
    FString ExpectedException;
    bool bLimitedObservation = false;
    FString ExecutionNotes;
};
}

// Added separately to each concrete product, including the existing ForLoop:
TArray<FGeneratedCaseInfo> ListCases() const;
FString BuildCaseSource(FStringView CaseId) const;
```

### Enumeration and consistency

- ListCases returns every declared cell, including compile rejects and runtime faults, in canonical axis order. All strings and optional values are owned; caller changes to a returned list cannot mutate the generator. It does not carry per-case source strings or compile anything.
- Source assembly, descriptors, legacy GetExpected and legacy reject lists derive from one product-owned canonical cell enumeration. Test expectations remain independently authored. This removes consumer-maintained tables without allowing implementation and oracle to validate themselves.
- For every non-reject row, EntryDeclaration is exactly `int Entry<PascalCaseId>()`. The same declaration occurs once in BuildAllSource and once in BuildCaseSource for that ID. Filtering ListCases by Outcome != CompileReject gives exactly OutCaseCount and aggregate entry order.
- CompileReject rows have an empty EntryDeclaration because no callable function is promised. BuildCaseSource produces one isolated invalid module for each such row. Existing BuildRejectSource delegates to the same reject builder, and ListRejectCaseIds equals the ordered reject projection of ListCases. A reject-only product still returns its full descriptor list even though its aggregate is empty.
- BuildCaseSource accepts only canonical IDs listed by the product; matching is case-sensitive. Unknown, empty or foreign-product IDs return empty source. Every valid ID returns nonempty owned source. This applies to the new ForLoop API too, without changing its old typed-builder defaults or old GetExpected fallback.
- Typed Build*Source(Params) continues to accept custom FunctionName and defaults to Entry. Its noncanonical parameter values and custom names are not added to ListCases, which describes the fixed catalog only. Canonical BuildCaseSource uses the descriptor's exact name, not the typed builder's Entry default.

### Expected observations and execution support

- ReturnValue rows eligible for execution have ExpectedReturn set, including a real zero; ExpectedException is empty. RuntimeException rows have ExpectedReturn unset and an exact ExpectedException string for the emitted trigger. CompileReject rows have both fields empty; later consumers require compilation failure and a diagnostic, as already selected in this Change.
- Standalone means the emitted fixture needs no host registration or lifecycle protocol beyond module compilation and one entry invocation. It is an authored source contract, not evidence that this Change executed AS.
- RequiresHostSetup marks entries such as ConvAbi; ExecutionNotes names their registration and additional native observation requirements. A generic runner must not count these as passed from the int32 marker alone. Host setup implementation remains outside this Change.
- SourceOnly marks lifecycle-only variants or cases whose documented scalar/fault oracle is insufficient to define execution acceptance. ExecutionNotes explains the missing lifecycle or observation contract. ExpectedReturn/ExpectedException may be absent where no exact observation is established; never invent a zero or exception string to make the row appear runnable. This preserves every source cell without making false execution promises.
- bLimitedObservation is true where an int32 represents only a type/direction/trace marker or an adapted fault does not establish the original host behavior. Notes describe that limit. ExecutionNotes is required for non-Standalone rows and limited observations. For PropRebuild, metadata and old_handle_cleanup observations are SourceOnly; any standalone second-version runtime observation must explicitly retain its limited lifecycle meaning.
- The default Execution=SourceOnly is conservative; each runnable product row must deliberately declare its support and complete observation. SourceOnly is not permission to skip an implementable source or downgrade a documented runnable case: the product's accepted constructor/oracle establishes classification, and independent tests lock it.
- GetExpected remains the existing int32 compatibility API. Where ExpectedReturn is set, it must agree with GetExpected. Consumers use the optional value and outcome from ListCases, never infer validity from GetExpected returning zero.

### Consumer usage and proving boundary

```text
Product.ListCases()                       // Supplies complete identities and typed observations.
  -> runnable non-reject rows             // Locate their exact declarations in the product module.
  -> compile-reject rows                  // Compile their independent BuildCaseSource text.
  -> host-dependent / source-only rows    // Require explicit support; never mark silent skips as passes.
```

The current Change proves this metadata/source contract with C++ tests and a fake dispatch observation, not a real AS runner. Tests must show a zero-return descriptor remains distinguishable from an invalid ID, every listed case can produce source, aggregate names match descriptors, reject APIs are consistent projections, and fault/host/source-only cases cannot be misclassified as ordinary integers. The final corpus test obtains actual cases solely from ListCases while retaining an independent literal inventory as its oracle.


## Entry spelling, physical ownership and test exports

The user explicitly requested PascalCase entry names without underscores, one unit test per generator, and all cases in one .as source file per generator beside the test log. This section supersedes earlier entry spelling, five-method ForLoop grouping and representative-only artifact language; bounded checked-in gold remains separate from full runtime exports.

### Exact implementation directories

- All 122 generator header/source pairs stay under `Plugins/Angelscript/Source/AngelscriptTest/Framework/Generate/`, matching the existing ForLoop owner. Example: `AngelscriptTestLoopDepthGenerator.h` and `.cpp`.
- Generator tests stay under `Plugins/Angelscript/Source/AngelscriptTest/FrameworkTests/Generate/`. Example: `LoopDepthGeneratorTests.cpp`. The ForLoop baseline test file is `ForLoopGeneratorTests.cpp`; do not keep the generic `GenerateTests.cpp` name.
- Shared case value types belong to `Framework/Generate/AngelscriptTestGeneratedCase.h`. Test-only path/write helpers belong to `FrameworkTests/Generate/GeneratedCaseExport.h/.cpp`; production generators have no file or logging side effects. Checked-in gold stays under `FrameworkTests/Gold/`.
- Author-facing rules stay under `AngelscriptTestCode/Generators/<theme>/<ProductId>.md`. Runtime exports never enter this directory or the checked-in gold tree.

### PascalCase rule

CaseId spelling stays unchanged. For canonical function and export leaf names, split the entire CaseId on '-' and '_', capitalize each token's first ASCII letter and lowercase the remaining ASCII letters, retain digits, concatenate the tokens and prefix `Entry`. Example: `LANG-CF-LOOP-DEPTH-WHILE-ZERO-BREAK` becomes `EntryLangCfLoopDepthWhileZeroBreak`; `DO_WHILE` becomes `DoWhile`, `INT64` becomes `Int64` and `FLOAT32` becomes `Float32`. Do not preserve all-uppercase acronyms or introduce separators.

All 122 enumerators validate generated-name uniqueness within their complete product set, including reject section labels. Distinct IDs collapsing to one PascalCase name are a failing contract check, never silently assigned suffixes or overwritten files. ListCases is the consumer authority for exact callable declarations. Typed FunctionName still defaults to Entry and accepts an explicit valid caller name without rewriting it. Existing ForLoop canonical aggregate names and gold adopt PascalCase under this explicit migration.

### One test per product

Each product has one CQTest class and exactly one `TEST_METHOD(GeneratesAndExportsAllCases)`. Keep its assertion flow visible in that method. Named Cases in tasks.md are assertion scenarios within that one method, not separately registered Automation methods. No Automation entry is registered per generated AS cell.

ForLoop retains its class/prefix `Angelscript.UnitTest.Framework.ForLoopGenerator`, consolidates the old five methods' checks and adds descriptor/export checks under the single method. Other products use `Angelscript.UnitTest.Framework.Generate.<ClassWithoutF>.GeneratesAndExportsAllCases`. The one corpus-level `LanguageGeneratorCorpus.VerifiesCompleteCorpus` remains an additional cross-product acceptance test; it does not repeat file export.

### Single-file run-local dump contract (current)

The user's latest correction replaces all per-cell .as files, product subdirectories and index.json with exactly one readable .as dump per generator. The public product method `FString BuildDumpSource() const` owns the complete formatting and composition. Tests write its returned text unchanged. BuildAllSource, ListCases and BuildCaseSource keep their execution-consumer meanings; they do not write files.

The current Harness run owns `Saved/Harness/Unreal/Runs/<RunId>/Unreal.log` (Private/Run.ps1 Get-UnrealRunPaths, Private/Operations.ps1 -ABSLOG). Resolve its actual filename with the inspected UE 5.8 `FGenericPlatformOutputDevices::GetAbsoluteLogFilename()` API, then write `GeneratedCases/<ClassWithoutF>.as` beside it. Examples: GeneratedCases/LoopDepthGenerator.as and GeneratedCases/TransferValidityGenerator.as. All 122 product tests produce 122 .as files when run together. There is no per-case file and no JSON sidecar. Separate Harness runs remain isolated by RunId.

### Complete contents without misleading compilation semantics

- Start with a compact comment header containing product ID, total/normal/reject/fault counts and the fact that this is a source-inspection dump.
- Emit the complete non-reject aggregate section first: compatible common helpers once and one canonical entry per normal/fault cell, with all required case-specific declarations. Before each case's declarations/entry, emit line comments containing its CaseId, EntryDeclaration, Outcome, expected return or exact exception where available, execution support and any observation limits. Each ID has exactly one case-section marker.
- Append a separately labeled compile-reject section when applicable. Each reject is a complete independent BuildCaseSource module delimited by line comments naming the CaseId and stating that it must be compiled separately. Do not share definitions across reject modules or count duplicated helper text across those independent modules as an aggregate-helper defect.
- A product with no rejects has a dump containing a complete aggregate plus comments. A dump containing rejects is intentionally not one compilable module; its header explicitly says so. Reject-only products still list every independent invalid module in the same dump. Never hide rejects, comment out the source itself, or change negative semantics just to make the inspection dump compilable.
- Each of the product's declared cells appears in exactly one labeled case section: aggregate entry or isolated reject module. LoopDepth has 48 sections in one file; TransferValidity has 3 aggregate-entry sections plus 5 reject-module sections in one file; RegisteredFuncdef has 6 reject-module sections in one file.
- BuildDumpSource composes the same canonical cells and source emitters used by ListCases, BuildAllSource and BuildCaseSource; it cannot maintain a second template that drifts from executable sources. It returns owned deterministic source text without disk/log/engine side effects. The test verifies section membership against its independent case table and source bodies against the canonical emitters.

### Generator-owned readable formatting

All generated APIs, including the dump, use LF line endings, a trailing newline, tabs for one indentation level, Allman opening/closing braces on their own lines, one statement per line and exactly one blank line between adjacent top-level declarations/functions. No trailing whitespace or giant one-line function bodies. Case headings are line comments on separate lines, for example `// Case: LANG-CF-LOOP-DEPTH-WHILE-ZERO-BREAK`; expected results and support notes follow in short comment lines. Comments must escape/split line breaks so metadata cannot accidentally introduce AS tokens. Runtime dumps contain literal source, not string-escaped C++ or Markdown fences.

Source components own formatting before assembly; the exporter must not repair indentation, rename entries or alter line endings. Helpers in the aggregate remain once per compatible definition. Reject-unit boundaries and top-level separators stay visually distinct. Bounded independently authored gold samples cover normal, nested, helper-bearing, mixed reject and reject-only layouts; never bless a dump from the implementation as its own oracle.

### One product test writes one artifact

Each product still has one GeneratesAndExportsAllCases method. Obtain BuildDumpSource and attempt its one write before assertion paths that abort the method; then verify complete case coverage, descriptor/source correspondence, typed expectations, deterministic layout and readback bytes. Generation failure or an empty dump is a test failure; a write failure reports the product and exact path. Retain any successfully written dump on later assertion failure. A crash cannot promise an artifact.

Write UTF-8 without BOM and log only absolute dump path and expected/generated case counts plus failures. Do not place the full source in Unreal.log. The helper may overwrite only this product's known dump on repeat execution; it never recursively cleans the folder or touches sibling product/run artifacts. Existing per-case export directories from earlier experiments are not deleted automatically and are not part of this acceptance contract. Complete dumps are ignored runtime artifacts; checked-in gold stays bounded. The final corpus test checks the 122-product contract without performing a second export.

### Test-only helper boundary

Task 1.1 supplies `AngelscriptTest::FGeneratedCaseExport` in FrameworkTests/Generate/GeneratedCaseExport.h/.cpp, proved through ForLoop. Its current signatures supersede ResolveProductDirectory/WriteCase/WriteIndex from the preceding replan:

```cpp
static FString ResolveOutputFile(FStringView GeneratorClass);
static bool WriteDump(FStringView OutputFile, FStringView Source,
                      FString& OutError);
```

ResolveOutputFile returns the absolute actual-log-parent/GeneratedCases/<ClassWithoutF>.as path, rejecting invalid class leaf names or an unavailable log parent with empty output. WriteDump validates the target against that resolved GeneratedCases directory, creates it as needed and saves exact text through FFileHelper::SaveStringToFile with ForceUTF8WithoutBOM, returning false with OutError on failure. The product test owns source generation, assertions and logging. No new Harness route, serializer or full runtime executor is introduced.
