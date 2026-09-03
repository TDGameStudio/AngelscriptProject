/**
 * Property-bag types on a USTRUCT remain unsupported, so this program is
 * rejected. FInstancedPropertyBag and FPropertyBag must not compile as members.
 *
 * @Theme Definitions.UStruct
 * @Subject UStruct.PropertyBagTypesRejected
 * @Harness CompileReject
 * @Tag Definitions.UStruct.PropertyBagTypesRejected
 * @Kind CompileReject
 * @Covers UStruct.PropertyBagTypesRejected
 * @Inputs FInstancedPropertyBag Foo and FPropertyBag Bar on FPropertyBagBoundary
 * @Return does not compile; property-bag types stay unsupported USTRUCT boundaries
 * @Provenance Theme: Definitions.UStruct. NegativeDiagnostic: property-bag types on USTRUCT.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUnsupportedBoundaryInventory block 1
 * @Provenance CompileAndExpectFailure: FInstancedPropertyBag and FPropertyBag should remain unsupported boundaries.
 * @Provenance Isolate this failing construct; do not add declarations that would compile it away.
 * @Provenance DiagnosticOnly.
 */

USTRUCT()
struct FPropertyBagBoundary
{
	FInstancedPropertyBag Foo;
	FPropertyBag Bar;
}
