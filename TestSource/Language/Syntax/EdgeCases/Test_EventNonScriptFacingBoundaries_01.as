// Theme: Language.Syntax.EdgeCases. C++ CompileAndExpectFailure despite CSV WorldStory.
// C++: AngelscriptCoverageEventTests.cpp::EventNonScriptFacingBoundaries block 1
// sha256=73589d9425943f8e7f6989596790fa0392ade226941fcb0a92f8ba3573986ae1; lines 1411-1431.
// Expected diagnostic: No matching signatures to 'FCoverageBoundaryEvent::AddDynamic
// Isolate this failing program. DiagnosticOnly.

event void FCoverageBoundaryEvent();

UCLASS()
class ACoverageEventAddDynamicBoundaryActor : AActor
{
	UPROPERTY()
	FCoverageBoundaryEvent OnBoundary;

	UFUNCTION()
	void Handler()
	{
	}

	UFUNCTION()
	void TryAddDynamic()
	{
		OnBoundary.AddDynamic(this, n"Handler");
	}
}
