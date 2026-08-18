# Task 4.3 scalar emitter audit

## Audit finding: non-integer literal source spellings were admitted then rejected

The task 4.3 completion audit found that the HIR analyzer accepted every
reviewed primitive scalar literal, while the emitter accepted only source
spellings containing decimal digits. Real compiler literals such as `true`,
`1.5f`, and `2.25` therefore passed eligibility but failed during emission.

The maintained compiler already stores the exact evaluated constant in
`asCExprValue::GetConstantData()`, and HIR expressions already own a pointer-free
`literalBits` field used by folded hard-value globals. The focused RED test
drives source compilation, verified HIR retrieval, and pure TypedASTJIT emission
in one capability-owned translation unit. It requires the source spelling to
remain diagnostic text while exact compiler bits own emitted semantics.

Test owner:

`Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/TypedASTJIT/
LiteralEncoding/AngelscriptTypedASTJITLiteralEncodingTests.cpp`

The first build failed only because the new StaticJIT-owned file used the
AngelScriptSDK catalogue-only `AS_NATIVE_PRODUCT` macro without importing that
separate catalogue layer. The behavior fixture does not need product-catalogue
registration, so the marker was removed before obtaining the valid RED:

```text
Saved/Build/semantic-aot-task43-literal-bits-red-build/
20260817_044231_863_554796d4/
Result: fixture-only compile RED
```

The corrected fixture compiled, then produced the intended production RED:

```text
Build:
Saved/Build/semantic-aot-task43-literal-bits-valid-red-build/
20260817_044256_307_b23965d8/
Result: PASS

Automation:
Saved/Tests/semantic-aot-task43-literal-bits-red/
20260817_044313_394_b397359c/
Result: expected RED, 0/1 PASS
Observed: bool/double literalBits were zero and non-decimal literal emission failed
```

One float lookup assertion also showed that exact public declaration spelling
was a noisy way to locate this fixture. The test now looks up the three unique
functions by name; their captured return types remain authoritative for emitter
shape construction.

## Implementation decision

`asCExprValue::GetConstantData()` is the maintained compiler's already-evaluated
bit payload for primitive constants. The builder now copies it only for
pointer-free by-value scalar literals; object/string constants retain zero and
cannot leak a process address into HIR. Source spelling stays in `literal` for
diagnostics. Bool, float, double and enum emission consumes `literalBits` via
the existing force-inlineable `FromCanonicalBits<T>` helper, while readable
decimal primitive integers preserve their direct `T(value)` C++ spelling.

## Audit finding: integer signedness changes and narrowing need an explicit bit-domain primitive

The task 4.3 audit also compared the maintained compiler's conversion lowering
with the independent native numeric-conversion product tests. AngelScript first
interprets the source using its declared signedness, then retains the low target
width bits; a signed target interprets that final bit pattern as two's
complement. This covers narrowing as well as same-width and widening signedness
changes. Raw C++ casts are not a sufficient portable spelling for every one of
those cases, most notably unsigned-to-signed values that are not representable
by the target type.

The focused source-compiled RED fixture owns this capability separately from the
larger generated-output file, as requested by the test-layout rule:

`Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/TypedASTJIT/
ScalarConversions/AngelscriptTypedASTJITScalarConversionTests.cpp`

The first automation run exposed a fixture-only omission: the manually built
emission shape did not copy the script function's parameter types. After making
the fixture match the production eligibility path, the official build passed
and all six valid conversion shapes reached the intended analyzer rejection:

```text
Fixture build:
Saved/Build/semantic-aot-task43-integral-conversion-fixture-build/
20260817_051302_920_fb7e4b83/
Result: PASS

Valid production RED:
Saved/Tests/semantic-aot-task43-integral-conversion-valid-red-2/
20260817_051320_935_231ad279/
Result: expected RED, 0/1 PASS
Observed: analyzer rejected signed/unsigned narrowing and signedness changes
with "Only reviewed integer widening..."
```

The implementation seam is a context-free, force-inlineable
`ConvertInteger<Target>(Source)` primitive. It converts through the unsigned
target bit domain and reconstructs signed targets with the existing
`FromUnsignedBits` helper. True width narrowing keeps the existing readable
`WrapNarrow<Target>` spelling; same-width or widening signedness changes use
`ConvertInteger<Target>`. Same-signed widening remains a direct `static_cast`.
No generic JIT execution context is introduced.

## GREEN evidence and task boundary

The production implementation adds only the reviewed scalar primitive and its
selection rules. `ConvertInteger` sign- or zero-extends through the source
value's normal C++ conversion to `uint64`, truncates to the unsigned target
carrier, and uses `FromUnsignedBits` when the target is signed. The analyzer
admits primitive integer-to-integer conversions; the emitter uses
`WrapNarrow` for every true width reduction, `ConvertInteger` for remaining
signedness changes, and a direct `static_cast` for same-signed widening.

Fresh official evidence:

```text
API RED build (helper absent):
Saved/Build/semantic-aot-task43-convert-integer-helper-red-build/
20260817_051506_706_140c088f/
Result: expected compile RED, ConvertInteger was not declared

GREEN build:
Saved/Build/semantic-aot-task43-integral-conversion-green-build/
20260817_051651_019_632a4d0b/
Result: PASS, including rebuilt generated TypedASTJIT/BytecodeJIT sources

Scalar conversion GREEN:
Saved/Tests/semantic-aot-task43-integral-conversion-green/
20260817_051717_338_e193206b/
Result: 2/2 PASS

Final focused build:
Saved/Build/semantic-aot-task43-regression-build/
20260817_051819_192_7dc1f814/
Result: PASS

Literal regression:
Saved/Tests/semantic-aot-task43-literal-regression/
20260817_051837_809_315c1737/
Result: 1/1 PASS

Scalar helper regression:
Saved/Tests/semantic-aot-task43-scalar-ops-regression/
20260817_051914_771_3223e0ce/
Result: 4/4 PASS

Generated-output regression:
Saved/Tests/semantic-aot-task43-generated-output-regression/
20260817_051949_600_8a1e2b91/
Result: 25/25 PASS

Executed interpreter/BytecodeJIT/TypedASTJIT numeric boundary differential:
Saved/Tests/semantic-aot-task43-numeric-boundary-regression/
20260817_052120_833_68200339/
Result: 1/1 PASS
```

`literalBits` is present in the normalized HIR representation for both literal
and folded-global expressions, so exact compiler bits participate in the
pointer-free semantic representation as well as emitted C++. `git diff
--check` reports no whitespace error; repository-wide LF/CRLF notices are
pre-existing line-ending warnings. Task 4.3 is complete. The larger
NaN/out-of-range float conversion matrix and its explicit fallback decisions
remain intentionally owned by task 4.6.
