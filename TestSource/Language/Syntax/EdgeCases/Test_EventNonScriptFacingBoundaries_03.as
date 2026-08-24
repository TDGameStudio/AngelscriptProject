// Theme: Language.Syntax.EdgeCases. C++ CompileAndExpectFailure despite CSV WorldStory.
// C++: AngelscriptCoverageEventTests.cpp::EventNonScriptFacingBoundaries block 3
// sha256=75a3d0113a90c408bacb5b7aaa98fe6a949ae75f9e408934158c623c077ac715; lines 1467-1477.
// Expected diagnostic: HttpRequest
// HTTP BindLambda callback surface is outside current AS event coverage.
// Isolate this failing program; do not declare HttpRequest.

UCLASS()
class ACoverageEventHttpBoundaryActor : AActor
{
	UFUNCTION()
	void TryHttpRequestCallback()
	{
		HttpRequest.OnProcessRequestComplete.BindLambda(this, n"Handler");
	}
}
