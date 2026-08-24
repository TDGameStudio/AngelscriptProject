// Theme: Language.Syntax.EdgeCases. WorldStory event bind/broadcast.
// C++: AngelscriptCoverageEventTests.cpp::EventBindAndTrigger
// sha256=6514ea829d74750c9b5916a0160e9d0f2dbd414028818cc618b697feef9a43c7; lines 80-123.
// Oracle after spawn+BeginPlay: EventCount=43 (1 + 42); EventLog="Custom;TestData;".
// Extra: local construct keeps EventCount 0 and empty EventLog (BeginPlay not run).
// FixtureIsolated. AddUFunction binds by n"" name; Broadcast is the owner of side effects.

event void FCoverageCustomEvent();
event void FCoverageDataChangedEvent(int Value, FString Data);

UCLASS()
class ACoverageEventBindTriggerActor : AActor
{
	UPROPERTY()
	int EventCount = 0;

	UPROPERTY()
	FString EventLog;

	// Custom events
	FCoverageCustomEvent OnCustomEvent;
	FCoverageDataChangedEvent OnDataChanged;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Bind event handlers
		OnCustomEvent.AddUFunction(this, n"HandleCustomEvent");
		OnDataChanged.AddUFunction(this, n"HandleDataChanged");

		// Trigger events
		OnCustomEvent.Broadcast();
		OnDataChanged.Broadcast(42, "TestData");
	}

	UFUNCTION()
	void HandleCustomEvent()
	{
		EventCount++;
		EventLog += "Custom;";
	}

	UFUNCTION()
	void HandleDataChanged(int Value, FString Data)
	{
		EventCount += Value;
		EventLog += Data + ";";
	}
}

bool Observe_EventBindAndTrigger_DefaultEmpty(ACoverageEventBindTriggerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventBindAndTrigger setup: required Actor is null");
	}
	return Actor.EventCount == 0 && Actor.EventLog.Len() == 0;
}
