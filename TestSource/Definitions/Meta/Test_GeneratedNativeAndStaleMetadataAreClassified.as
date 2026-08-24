// Theme: Definitions.Meta. Positive: generated UASFunction / WorldContext property classification fixture.
// C++: AngelscriptASFunctionMetadataTests.cpp::GeneratedNativeAndStaleMetadataAreClassified
// Oracle: ComputeValue(0) == 12; CheckMetadataWorldContext(_, 7) == 7.
// Extra: ComputeValue with 0; null WorldContext still returns Value. DefaultSafe.

UCLASS()
class UASFunctionMetadataClassification : UObject
{
	UPROPERTY()
	int StoredValue = 12;

	UFUNCTION()
	int ComputeValue(int Value)
	{
		return Value + StoredValue;
	}
}

UFUNCTION(BlueprintCallable, meta = (WorldContext = "WorldContextObject"))
int CheckMetadataWorldContext(UObject WorldContextObject, int Value)
{
	return Value;
}

int Observe_MetadataClassification_ComputeDefaultStored()
{
	UASFunctionMetadataClassification Obj = Cast<UASFunctionMetadataClassification>(NewObject(GetTransientPackage(), UASFunctionMetadataClassification::StaticClass()));
	if (Obj == nullptr)
	{
		throw("TS-DEF-0382 setup: NewObject failed");
	}
	return Obj.ComputeValue(0);
}

int Observe_MetadataClassification_ComputeNominal()
{
	UASFunctionMetadataClassification Obj = Cast<UASFunctionMetadataClassification>(NewObject(GetTransientPackage(), UASFunctionMetadataClassification::StaticClass()));
	if (Obj == nullptr)
	{
		throw("TS-DEF-0382 setup: NewObject failed");
	}
	return Obj.ComputeValue(5);
}

int Observe_MetadataClassification_WorldContextNullBoundary()
{
	UObject Missing;
	return CheckMetadataWorldContext(Missing, 0);
}

int Observe_MetadataClassification_WorldContextNominal()
{
	UASFunctionMetadataClassification Obj = Cast<UASFunctionMetadataClassification>(NewObject(GetTransientPackage(), UASFunctionMetadataClassification::StaticClass()));
	if (Obj == nullptr)
	{
		throw("TS-DEF-0382 setup: NewObject failed");
	}
	return CheckMetadataWorldContext(Obj, 7);
}

bool Observe_MetadataClassification_CopyIndependence()
{
	UASFunctionMetadataClassification First = Cast<UASFunctionMetadataClassification>(NewObject(GetTransientPackage(), UASFunctionMetadataClassification::StaticClass()));
	UASFunctionMetadataClassification Second = Cast<UASFunctionMetadataClassification>(NewObject(GetTransientPackage(), UASFunctionMetadataClassification::StaticClass()));
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-DEF-0382 setup: NewObject failed");
	}
	First.StoredValue = 1;
	return First.ComputeValue(0) == 1 && Second.ComputeValue(0) == 12;
}
