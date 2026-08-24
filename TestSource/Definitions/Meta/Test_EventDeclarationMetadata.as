// Theme: Definitions.Meta. WorldStory: plain event UPROPERTY declarations compile to multicast delegates.
// C++: AngelscriptCoverageEventTests.cpp::EventDeclarationMetadata
// Oracle: OnPlainEvent / OnAssignableEvent / OnCallableEvent exist on the generated class.
// Extra: default actor handle is null; OnCallableEvent takes int Value. FixtureIsolated.

event void FCoverageEventPlain();
event void FCoverageEventAssignable();
event void FCoverageEventCallable(int Value);

UCLASS()
class ACoverageEventMetadataActor : AActor
{
	UPROPERTY()
	FCoverageEventPlain OnPlainEvent;

	UPROPERTY()
	FCoverageEventAssignable OnAssignableEvent;

	UPROPERTY()
	FCoverageEventCallable OnCallableEvent;
}

int Observe_EventMetadata_EmptyDefaultIsNull()
{
	ACoverageEventMetadataActor Unset;
	if (Unset is null)
	{
		return 1;
	}
	return 0;
}

bool Observe_EventMetadata_AssignAliases()
{
	ACoverageEventMetadataActor First;
	ACoverageEventMetadataActor Second;
	First = Second;
	return First is Second;
}
