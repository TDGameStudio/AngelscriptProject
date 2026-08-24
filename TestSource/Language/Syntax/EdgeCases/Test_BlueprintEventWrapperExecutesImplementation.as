// Theme: Language.Syntax.EdgeCases. Positive BlueprintEvent wrapper routes to _Implementation.
// C++: AngelscriptCompilerBlueprintEventWrapperTests.cpp::BlueprintEventWrapperExecutesImplementation
// sha256=924533a33320c352a15ba1d6e8fd721dd8e9cd3f9f0b6860326c004e87ab7b42; lines 82-98.
// Oracle: Entry() == Compute(21) == 42.
// Extra: Compute(0) == 21 is the zero boundary. DefaultSafe.

UCLASS()
class UCompilerBlueprintEventWrapperCarrier : UObject
{
	UFUNCTION(BlueprintEvent)
	int Compute(int Value)
	{
		return Value + 21;
	}

	UFUNCTION()
	int Entry()
	{
		return Compute(21);
	}
}

bool Observe_Entry_Nominal()
{
	UCompilerBlueprintEventWrapperCarrier Carrier =
		Cast<UCompilerBlueprintEventWrapperCarrier>(
			NewObject(GetTransientPackage(), UCompilerBlueprintEventWrapperCarrier::StaticClass(), n"CompilerBlueprintEventWrapperCarrier"));
	if (Carrier == nullptr)
	{
		throw("TS-LANG-0001 setup: NewObject returned null");
	}
	return Carrier.Entry() == 42 && Carrier.Compute(21) == 42;
}

bool Observe_Compute_ZeroBoundary()
{
	UCompilerBlueprintEventWrapperCarrier Carrier =
		Cast<UCompilerBlueprintEventWrapperCarrier>(
			NewObject(GetTransientPackage(), UCompilerBlueprintEventWrapperCarrier::StaticClass(), n"CompilerBlueprintEventWrapperCarrierZero"));
	if (Carrier == nullptr)
	{
		throw("TS-LANG-0001 setup: NewObject returned null");
	}
	return Carrier.Compute(0) == 21;
}

bool Observe_Compute_CopyIndependence()
{
	UCompilerBlueprintEventWrapperCarrier First =
		Cast<UCompilerBlueprintEventWrapperCarrier>(
			NewObject(GetTransientPackage(), UCompilerBlueprintEventWrapperCarrier::StaticClass(), n"CompilerBlueprintEventWrapperCarrierFirst"));
	UCompilerBlueprintEventWrapperCarrier Second =
		Cast<UCompilerBlueprintEventWrapperCarrier>(
			NewObject(GetTransientPackage(), UCompilerBlueprintEventWrapperCarrier::StaticClass(), n"CompilerBlueprintEventWrapperCarrierSecond"));
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-LANG-0001 setup: NewObject returned null");
	}
	return First.Compute(1) == 22 && Second.Entry() == 42;
}
