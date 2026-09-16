> Latest export correction: BuildDumpSource returns all cases in one formatted inspection file per generator. Earlier per-case-file/product-folder/index.json descriptions are superseded; actual execution still uses ListCases and canonical source APIs.

> Current naming/export amendment: canonical entries now use Entry plus PascalCaseId; each generator has one GeneratesAndExportsAllCases test that exports one complete readable source dump beside its current log. Current design/tasks own the exact amended contract.

> Current contract amendment: the case-enumeration replan adds ListCases and BuildCaseSource to every product. The current Change design and tasks own the amended interface; the original source-generation scope and int32 observation limits remain in force.

# Complete Language source generation

## Accepted objective and provenance

Source identity: angelscript/test-code-language-corpus, selected design testcode-combinatorial-recipes. This is an English consolidation of the selected design and the user's explicit 2026-09-15 scope correction and creation instruction. The user selected all 122 products in one Change, with ForLoop as the existing baseline, and authorized selected talks and knowledge to be summarized into this Change. Earlier first-batch-only handoff text is superseded.

Deliver all 122 directly constructible C++ generator products and all 36,686 currently declared filtered cells. A batch is task scheduling, never permission to omit products. The product catalog in findings/ is the complete scope inventory. A discrepancy requires explicit evidence and a plan correction; it never silently reduces the accepted inventory.

## Ownership and architecture

Generators belong to Plugins/Angelscript/Source/AngelscriptTest/Framework/Generate. Tests and bounded reviewed gold samples belong to FrameworkTests. Keep FCodeGenerator empty and construct each specialized subclass directly in AngelscriptTest::Generate. Each product owns its typed parameters, axes, enumerator, constraints, source assembly and expected-result calculation. Do not add a registry, Get<T>() manager, general constraint compiler, templating language, random sampling infrastructure or JSON recipe interpreter.

```text
Caller constructs a product                    // No registry or ambient engine is needed.
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

For new products, invalid typed values, invalid explicit function identifiers, unknown CaseIds, or using a reject case in a positive-only single builder return empty source; no partial text is emitted. GetExpected returns zero for IDs outside its normal observation domain, matching the existing ForLoop fallback, and callers must not use that fallback to establish validity. A valid zero observation is not evidence of a valid ID. Test membership separately against the independent expected ID table. ForLoop's established behavior remains the baseline; any shared-contract adjustment is owned by its task and retains all existing fixtures.

## Migration evidence and known card defects

Legacy C++ is dormant source evidence, never a runnable dependency. Preserve generated language structure after the explicitly accepted removed-syntax filtering. Use JSON-only rows as explicit coverage targets where the card establishes them, not as proof they already ran. PropRebuild has 15 declared scenarios and 90 target cells, whereas the inspected C++ ScenarioCases has five stored rows; implement the additional documented variants rather than silently reducing to 30.

Normalize template defects inside the owning product task: remove spurious Limit fields; do not call GetExpected on reject examples; retain product-specific host dependencies; mark approximate observations honestly. If implementation evidence contradicts a requirement or needs a new user-owned behavior choice, use the Change replan route, not a silent omission or a return to brainstorming.

## Verification and completion

Each product task proves its complete declared cell set, category partition, entry naming/order, independent expected observations, representative reviewed gold text, relevant helper/type isolation, and malformed-input behavior. Enumerate every cell for structural checks; gold files are bounded representatives rather than a repository dump of all 36,686 generated sources. Expected tables and gold must be derived independently from the generator under test and linked legacy construction/oracle evidence.

Tests run under Angelscript.UnitTest.Framework.Generate.<ProductClassWithoutF>, except the existing ForLoop test identity remains Angelscript.UnitTest.Framework.ForLoopGenerator. Product tasks are independently bounded. Compatible tests may share an actual Harness run while retaining exact task-to-case and source/binary evidence. The final corpus test constructs all 122 classes, checks the complete product and category totals, and catches missing classes, duplicate IDs, and count inflation by repeated source entries. A passing generator run makes no claim about AS runtime correctness.

Current scope is creation and planning only. All implementation tasks stay unchecked until their real proving runs pass. No commit, push, hand-written corpus migration, broad UE suite or automatic formal Review is part of creation.
