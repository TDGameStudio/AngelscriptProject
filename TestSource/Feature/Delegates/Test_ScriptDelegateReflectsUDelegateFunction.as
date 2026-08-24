// Theme: Feature.Delegates. WorldStory: script delegate materializes UDelegateFunction.
// C++: AngelscriptCoverageMacrosTests.cpp::ScriptDelegateReflectsUDelegateFunction
// Compile + reflection oracle: FCoverageMacroSignal is single-cast; Signal is FDelegateProperty;
// signature exposes int Value.
// Extra: default-constructed actor non-null; nullptr assignment is the null boundary.
// Keep Signal. FixtureIsolated.

delegate void FCoverageMacroSignal(int Value);

UCLASS()
class ACoverageMacrosDelegateActor : AActor
{
	UPROPERTY()
	FCoverageMacroSignal Signal;
}

bool Observe_Carrier_DefaultNonNull()
{
	ACoverageMacrosDelegateActor Actor;
	return Actor != nullptr;
}

bool Observe_Carrier_NullBoundary()
{
	ACoverageMacrosDelegateActor Actor = nullptr;
	return Actor == nullptr;
}
