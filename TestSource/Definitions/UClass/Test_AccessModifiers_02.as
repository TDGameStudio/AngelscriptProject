// Theme: Definitions.UClass. NegativeDiagnostic: public member keyword.
// C++: AngelscriptCoverageClassFeaturesTests.cpp::AccessModifiers ExpectCompileBoundaryRejected.
// Expected diagnostic: "Expected method or property" / "Instead found identifier 'public'".
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class AAccessModifierPublicKeywordBoundary : AActor
{
	public int UnsupportedPublicKeyword = 1;
}
