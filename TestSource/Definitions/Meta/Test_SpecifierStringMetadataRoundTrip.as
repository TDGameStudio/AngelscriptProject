// Theme: Definitions.Meta. Positive: specifier strings keep commas and escaped quotes.
// C++: AngelscriptCompilerSpecifierMetadataTests.cpp::SpecifierStringMetadataRoundTrip
// Oracle: Entry() == 7; Compute() == 7. Extra: Count default 0; Compute is independent of Count.
// DefaultSafe.

UCLASS(meta=(DisplayName="Alpha, Beta", ToolTip="He said \"Hi\""))
class USpecifierCarrier : UObject
{
	UPROPERTY(meta=(DisplayName="Count, Total", ToolTip="Quoted \"Value\""))
	int Count;

	UFUNCTION(meta=(DisplayName="Call, Verify", ToolTip="Escaped \"quote\""))
	int Compute()
	{
		return 7;
	}
}

int Entry()
{
	return 7;
}

int Observe_Specifier_Entry()
{
	return Entry();
}

int Observe_Specifier_ComputeNominal()
{
	USpecifierCarrier Carrier = Cast<USpecifierCarrier>(NewObject(GetTransientPackage(), USpecifierCarrier::StaticClass()));
	if (Carrier == nullptr)
	{
		throw("TS-DEF-0010 setup: NewObject failed");
	}
	return Carrier.Compute();
}

int Observe_Specifier_CountDefaultZero()
{
	USpecifierCarrier Carrier = Cast<USpecifierCarrier>(NewObject(GetTransientPackage(), USpecifierCarrier::StaticClass()));
	if (Carrier == nullptr)
	{
		throw("TS-DEF-0010 setup: NewObject failed");
	}
	return Carrier.Count;
}

bool Observe_Specifier_CopyIndependence()
{
	USpecifierCarrier First = Cast<USpecifierCarrier>(NewObject(GetTransientPackage(), USpecifierCarrier::StaticClass()));
	USpecifierCarrier Second = Cast<USpecifierCarrier>(NewObject(GetTransientPackage(), USpecifierCarrier::StaticClass()));
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-DEF-0010 setup: NewObject failed");
	}
	First.Count = 3;
	return First.Count == 3 && Second.Count == 0 && First.Compute() == 7 && Second.Compute() == 7;
}
