// Theme: Definitions.UClass. Positive UObject CDO defaults plus UFUNCTION dispatch.
// C++: AngelscriptCoverageUClassTests.cpp::UClassUObjectDefaultObjectAndMethodDispatch
// Oracle: CDO Counter=12 Label=Seed; AddCounter(8) returns 20; BuildLabel("Done")="Seed_Done".
// Extra: AddCounter(0) leaves 12; empty suffix "Seed_". DefaultSafe.

UCLASS(BlueprintType)
class UCoverageUClassPlainDataObject : UObject
{
	UPROPERTY()
	int Counter = 12;

	UPROPERTY()
	FString Label = "Seed";

	UFUNCTION()
	int AddCounter(int Value)
	{
		Counter += Value;
		return Counter;
	}

	UFUNCTION()
	FString BuildLabel(const FString&in Suffix)
	{
		return Label + "_" + Suffix;
	}
}

bool Observe_PlainDataObject_EmptyDefaultIsNull()
{
	UCoverageUClassPlainDataObject Obj;
	return Obj == nullptr;
}

int Observe_PlainDataObject_AddCounterNominal(UCoverageUClassPlainDataObject Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-DEF-0152 setup: required UCoverageUClassPlainDataObject is null");
	}
	Obj.Counter = 12;
	return Obj.AddCounter(8);
}

int Observe_PlainDataObject_AddCounterZeroBoundary(UCoverageUClassPlainDataObject Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-DEF-0152 setup: required UCoverageUClassPlainDataObject is null");
	}
	Obj.Counter = 12;
	return Obj.AddCounter(0);
}

FString Observe_PlainDataObject_BuildLabelNominal(UCoverageUClassPlainDataObject Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-DEF-0152 setup: required UCoverageUClassPlainDataObject is null");
	}
	Obj.Label = "Seed";
	return Obj.BuildLabel("Done");
}

FString Observe_PlainDataObject_BuildLabelEmptySuffix(UCoverageUClassPlainDataObject Obj)
{
	if (Obj == nullptr)
	{
		throw("TS-DEF-0152 setup: required UCoverageUClassPlainDataObject is null");
	}
	Obj.Label = "Seed";
	return Obj.BuildLabel("");
}
