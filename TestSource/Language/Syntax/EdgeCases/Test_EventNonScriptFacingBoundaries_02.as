// Theme: Language.Syntax.EdgeCases. C++ CompileAndExpectFailure despite CSV WorldStory.
// C++: AngelscriptCoverageEventTests.cpp::EventNonScriptFacingBoundaries block 2
// sha256=1c985f6358593f0b650f16fa15face9933819e0ef07d1848e5e228329baa7515; lines 1444-1454.
// Expected diagnostic: Expected expression value
// C++ lambda timer callback syntax is not an AS-facing API. Isolate this failing program.

UCLASS()
class ACoverageEventTimerLambdaBoundaryActor : AActor
{
	UFUNCTION()
	void TryTimerLambda()
	{
		System::SetTimer(this, [](){}, 1.0f, false);
	}
}
