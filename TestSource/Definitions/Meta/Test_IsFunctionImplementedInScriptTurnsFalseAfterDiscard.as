// Theme: Definitions.Meta. Positive: generated script function exists before C++ discard.
// C++: AngelscriptASClassMetadataTests.cpp::IsFunctionImplementedInScriptTurnsFalseAfterDiscard
// Oracle: ComputeValue() == 7. Extra: repeating ComputeValue is stable. DefaultSafe.

UCLASS()
class UMetadataDiscardCarrier : UObject
{
	UFUNCTION()
	int ComputeValue()
	{
		return 7;
	}
}

int Observe_MetadataDiscard_ComputeValueNominal()
{
	UMetadataDiscardCarrier Carrier = Cast<UMetadataDiscardCarrier>(NewObject(GetTransientPackage(), UMetadataDiscardCarrier::StaticClass()));
	if (Carrier == nullptr)
	{
		throw("TS-DEF-0379 setup: NewObject failed");
	}
	return Carrier.ComputeValue();
}

bool Observe_MetadataDiscard_RepeatCall()
{
	UMetadataDiscardCarrier Carrier = Cast<UMetadataDiscardCarrier>(NewObject(GetTransientPackage(), UMetadataDiscardCarrier::StaticClass()));
	if (Carrier == nullptr)
	{
		throw("TS-DEF-0379 setup: NewObject failed");
	}
	return Carrier.ComputeValue() == 7 && Carrier.ComputeValue() == 7;
}

bool Observe_MetadataDiscard_CopyIndependence()
{
	UMetadataDiscardCarrier First = Cast<UMetadataDiscardCarrier>(NewObject(GetTransientPackage(), UMetadataDiscardCarrier::StaticClass()));
	UMetadataDiscardCarrier Second = Cast<UMetadataDiscardCarrier>(NewObject(GetTransientPackage(), UMetadataDiscardCarrier::StaticClass()));
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-DEF-0379 setup: NewObject failed");
	}
	return First.ComputeValue() == 7 && Second.ComputeValue() == 7 && !(First is Second);
}
