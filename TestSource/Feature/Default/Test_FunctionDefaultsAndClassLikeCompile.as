// Theme: Feature.Default. Positive function defaults plus class-like UFUNCTION signatures.
// C++: AngelscriptCompilerEndToEndTests.cpp::FunctionDefaultsAndClassLikeCompile
// ExecuteIntFunction Entry() == 42. EchoPlainClass / EchoActorClass / EchoSoftActorClass exist.
// Extra: SumWithDefault(0, 0) == 0; SumWithDefault(21) == 42; null/empty class echoes.
// DefaultSafe.

int SumWithDefault(int Value = 21, int Extra = 21)
{
	return Value + Extra;
}

int Entry()
{
	return SumWithDefault();
}

UCLASS()
class UCompilerFunctionCarrier : UObject
{
	UFUNCTION()
	UClass EchoPlainClass(UClass Value)
	{
		return Value;
	}

	UFUNCTION()
	TSubclassOf<AActor> EchoActorClass(TSubclassOf<AActor> Value)
	{
		return Value;
	}

	UFUNCTION()
	TSoftClassPtr<AActor> EchoSoftActorClass(TSoftClassPtr<AActor> Value)
	{
		return Value;
	}
}

int Observe_Entry_DefaultSum()
{
	return Entry();
}

int Observe_SumWithDefault_ZeroBoundary()
{
	return SumWithDefault(0, 0);
}

int Observe_SumWithDefault_OneExplicitKeepsSecondDefault()
{
	return SumWithDefault(21);
}

UClass Observe_EchoPlainClass_Null(UCompilerFunctionCarrier Carrier)
{
	if (Carrier == nullptr)
	{
		throw("TS-FEAT-0006 setup: required UCompilerFunctionCarrier is null");
	}
	return Carrier.EchoPlainClass(nullptr);
}

TSubclassOf<AActor> Observe_EchoActorClass_Empty(UCompilerFunctionCarrier Carrier)
{
	if (Carrier == nullptr)
	{
		throw("TS-FEAT-0006 setup: required UCompilerFunctionCarrier is null");
	}
	TSubclassOf<AActor> Empty;
	return Carrier.EchoActorClass(Empty);
}

TSoftClassPtr<AActor> Observe_EchoSoftActorClass_Empty(UCompilerFunctionCarrier Carrier)
{
	if (Carrier == nullptr)
	{
		throw("TS-FEAT-0006 setup: required UCompilerFunctionCarrier is null");
	}
	TSoftClassPtr<AActor> Empty;
	return Carrier.EchoSoftActorClass(Empty);
}
