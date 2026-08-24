// Purpose: Observe eligible Blueprint events published as static AngelScript
// namespace functions on the owning class.
// AS-facing API: ReturnType EventOwner::EventName(Arguments...);
// Inputs: Explicit argument 21 for Compute, then the default-argument omission
// path is not published so the same overload is called again with 0 as a
// valid empty-state counterpart. Null WorldContext is not involved; invocation
// always targets the reflected class default object.
// Expected observations: EventOwner::Compute(21) returns 42 from the CDO
// implementation, and EventOwner::Compute(0) returns 21.
// Boundary/ownership: The static namespace call does not instantiate a new
// receiver. It borrows the class default object and must not treat that CDO
// as a script-owned instance.

UCLASS()
class UTSBlueprintEventNamespaceOwner : UObject
{
	UFUNCTION(BlueprintEvent)
	int Compute(int Value)
	{
		return Value + 21;
	}
}

namespace TS_BlueprintEvent_NamespaceAndGlobalFunctions_01
{
	bool Observe_EventName_Nominal()
	{
		int ExplicitResult = UTSBlueprintEventNamespaceOwner::Compute(21);
		int EmptyStateResult = UTSBlueprintEventNamespaceOwner::Compute(0);
		return ExplicitResult == 42 && EmptyStateResult == 21;
	}
}
