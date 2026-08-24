// Theme: Definitions.Meta. Positive: ReplicatedUsing / BlueprintGetter / BlueprintSetter round-trip.
// C++: AngelscriptCompilerPropertyMetadataTests.cpp::PropertyCallbackMetadataRoundTrip
// Oracle: Entry() == 42; GetTrackedValue after SetTrackedValue(42) is 42.
// Extra: default TrackedValue 0; SetTrackedValue(0) stays 0. DefaultSafe.

UCLASS()
class UPropertyCallbackCarrier : UObject
{
	UPROPERTY(ReplicatedUsing=OnRep_TrackedValue, BlueprintGetter=GetTrackedValue, BlueprintSetter=SetTrackedValue)
	int TrackedValue;

	UFUNCTION()
	void OnRep_TrackedValue()
	{
	}

	UFUNCTION(BlueprintPure)
	int GetTrackedValue() const
	{
		return TrackedValue;
	}

	UFUNCTION()
	void SetTrackedValue(int Value)
	{
		TrackedValue = Value;
	}
}

int Entry()
{
	return 42;
}

int Observe_PropertyCallback_Entry()
{
	return Entry();
}

int Observe_PropertyCallback_DefaultTrackedValue()
{
	UPropertyCallbackCarrier Carrier = Cast<UPropertyCallbackCarrier>(NewObject(GetTransientPackage(), UPropertyCallbackCarrier::StaticClass()));
	if (Carrier == nullptr)
	{
		throw("TS-DEF-0006 setup: NewObject failed");
	}
	return Carrier.GetTrackedValue();
}

int Observe_PropertyCallback_SetZeroBoundary()
{
	UPropertyCallbackCarrier Carrier = Cast<UPropertyCallbackCarrier>(NewObject(GetTransientPackage(), UPropertyCallbackCarrier::StaticClass()));
	if (Carrier == nullptr)
	{
		throw("TS-DEF-0006 setup: NewObject failed");
	}
	Carrier.SetTrackedValue(0);
	return Carrier.GetTrackedValue();
}

int Observe_PropertyCallback_SetNominal()
{
	UPropertyCallbackCarrier Carrier = Cast<UPropertyCallbackCarrier>(NewObject(GetTransientPackage(), UPropertyCallbackCarrier::StaticClass()));
	if (Carrier == nullptr)
	{
		throw("TS-DEF-0006 setup: NewObject failed");
	}
	Carrier.SetTrackedValue(42);
	Carrier.OnRep_TrackedValue();
	return Carrier.GetTrackedValue();
}

bool Observe_PropertyCallback_CopyIndependence()
{
	UPropertyCallbackCarrier First = Cast<UPropertyCallbackCarrier>(NewObject(GetTransientPackage(), UPropertyCallbackCarrier::StaticClass()));
	UPropertyCallbackCarrier Second = Cast<UPropertyCallbackCarrier>(NewObject(GetTransientPackage(), UPropertyCallbackCarrier::StaticClass()));
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-DEF-0006 setup: NewObject failed");
	}
	First.SetTrackedValue(42);
	return First.GetTrackedValue() == 42 && Second.GetTrackedValue() == 0;
}
