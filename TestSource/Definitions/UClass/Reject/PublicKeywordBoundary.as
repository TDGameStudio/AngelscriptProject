/**
 * The public member keyword is rejected on a UCLASS. AngelScript UCLASS
 * members do not use C++ public/private keywords as property introducers.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.PublicKeywordBoundary
 * @Harness CompileReject
 * @Tag Definitions.UClass.PublicKeywordBoundary
 * @Kind CompileReject
 * @Covers UClass.Access
 * @Inputs public int UnsupportedPublicKeyword = 1
 * @Return does not compile; diagnostic "Expected method or property" / "Instead found identifier 'public'"
 * @Provenance Theme: Definitions.UClass. NegativeDiagnostic: public member keyword.
 * @Provenance C++: AngelscriptCoverageClassFeaturesTests.cpp::AccessModifiers ExpectCompileBoundaryRejected.
 * @Provenance Expected diagnostic: "Expected method or property" / "Instead found identifier 'public'".
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

UCLASS()
class AAccessModifierPublicKeywordBoundary : AActor
{
	public int UnsupportedPublicKeyword = 1;
}
