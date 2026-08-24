// Theme: Definitions.Meta. Positive: BlueprintEvent wrappers execute the script implementation.
// C++: AngelscriptCoverageEventTests.cpp::EventBlueprintEventMetadataAndExecution
// Oracle: RunEvents() == 48; LastInput == 37; LastLabel == "Event".
// Extra: ComputeEvent(0, "") == 5; CallableEvent(0) == 0; copy independence. DefaultSafe.

UCLASS()
class UCoverageBlueprintEventObject : UObject
{
	UPROPERTY()
	int LastInput = 0;

	UPROPERTY()
	FString LastLabel;

	UFUNCTION(BlueprintEvent)
	int ComputeEvent(int Value, const FString& Label)
	{
		LastInput = Value;
		LastLabel = Label;
		return Value + 5;
	}

	UFUNCTION(BlueprintCallable, BlueprintEvent)
	int CallableEvent(int Value)
	{
		return Value * 3;
	}

	UFUNCTION()
	int RunEvents()
	{
		return ComputeEvent(37, "Event") + CallableEvent(2);
	}
}

int Observe_BlueprintEvent_RunEventsNominal()
{
	UCoverageBlueprintEventObject Obj = Cast<UCoverageBlueprintEventObject>(NewObject(GetTransientPackage(), UCoverageBlueprintEventObject::StaticClass()));
	if (Obj == nullptr)
	{
		throw("TS-DEF-0058 setup: NewObject failed");
	}
	return Obj.RunEvents();
}

int Observe_BlueprintEvent_LastInputAfterRun()
{
	UCoverageBlueprintEventObject Obj = Cast<UCoverageBlueprintEventObject>(NewObject(GetTransientPackage(), UCoverageBlueprintEventObject::StaticClass()));
	if (Obj == nullptr)
	{
		throw("TS-DEF-0058 setup: NewObject failed");
	}
	Obj.RunEvents();
	return Obj.LastInput;
}

FString Observe_BlueprintEvent_LastLabelAfterRun()
{
	UCoverageBlueprintEventObject Obj = Cast<UCoverageBlueprintEventObject>(NewObject(GetTransientPackage(), UCoverageBlueprintEventObject::StaticClass()));
	if (Obj == nullptr)
	{
		throw("TS-DEF-0058 setup: NewObject failed");
	}
	Obj.RunEvents();
	return Obj.LastLabel;
}

int Observe_BlueprintEvent_ZeroBoundary()
{
	UCoverageBlueprintEventObject Obj = Cast<UCoverageBlueprintEventObject>(NewObject(GetTransientPackage(), UCoverageBlueprintEventObject::StaticClass()));
	if (Obj == nullptr)
	{
		throw("TS-DEF-0058 setup: NewObject failed");
	}
	return Obj.ComputeEvent(0, "") + Obj.CallableEvent(0);
}

bool Observe_BlueprintEvent_CopyIndependence()
{
	UCoverageBlueprintEventObject First = Cast<UCoverageBlueprintEventObject>(NewObject(GetTransientPackage(), UCoverageBlueprintEventObject::StaticClass()));
	UCoverageBlueprintEventObject Second = Cast<UCoverageBlueprintEventObject>(NewObject(GetTransientPackage(), UCoverageBlueprintEventObject::StaticClass()));
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-DEF-0058 setup: NewObject failed");
	}
	First.RunEvents();
	return First.LastInput == 37 && Second.LastInput == 0 && Second.LastLabel.Len() == 0;
}
