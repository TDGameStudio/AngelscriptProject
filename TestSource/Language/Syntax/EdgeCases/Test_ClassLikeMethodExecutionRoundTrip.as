// Theme: Language.Syntax.EdgeCases. Positive class-like UClass / TSubclassOf / TSoftClassPtr round-trip.
// C++: AngelscriptCompilerClassLikeExecutionTests.cpp::ClassLikeMethodExecutionRoundTrip
// sha256=2bb93edc54e28c759785d83f681f681d22ac360ec8d1d94d58c809ac7ba2e6db; lines 27-65.
// Oracle: VerifyRoundTrip() == 1 (plain AActor, TSubclassOf ACameraActor, TSoftClassPtr AActor).
// Extra: null UClass echo stays null. DefaultSafe.

UCLASS()
class UCompilerClassLikeExecutionCarrier : UObject
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

	UFUNCTION()
	int VerifyRoundTrip()
	{
		if (!(EchoPlainClass(AActor::StaticClass()) == AActor::StaticClass()))
			return 10;

		if (!(EchoActorClass(ACameraActor::StaticClass()) == ACameraActor::StaticClass()))
			return 20;

		TSoftClassPtr<AActor> SoftActorClass = TSoftClassPtr<AActor>(AActor::StaticClass());
		if (!(EchoSoftActorClass(SoftActorClass).Get() == AActor::StaticClass()))
			return 30;

		return 1;
	}
}

bool Observe_VerifyRoundTrip_Nominal()
{
	UCompilerClassLikeExecutionCarrier Carrier =
		Cast<UCompilerClassLikeExecutionCarrier>(
			NewObject(GetTransientPackage(), UCompilerClassLikeExecutionCarrier::StaticClass(), n"CompilerClassLikeExecutionCarrier"));
	if (Carrier == nullptr)
	{
		throw("TS-LANG-0005 setup: NewObject returned null");
	}
	return Carrier.VerifyRoundTrip() == 1;
}

bool Observe_EchoPlainClass_NullBoundary()
{
	UCompilerClassLikeExecutionCarrier Carrier =
		Cast<UCompilerClassLikeExecutionCarrier>(
			NewObject(GetTransientPackage(), UCompilerClassLikeExecutionCarrier::StaticClass(), n"CompilerClassLikeExecutionCarrierNull"));
	if (Carrier == nullptr)
	{
		throw("TS-LANG-0005 setup: NewObject returned null");
	}
	return Carrier.EchoPlainClass(nullptr) == nullptr;
}

bool Observe_EchoActorClass_EmptyBoundary()
{
	UCompilerClassLikeExecutionCarrier Carrier =
		Cast<UCompilerClassLikeExecutionCarrier>(
			NewObject(GetTransientPackage(), UCompilerClassLikeExecutionCarrier::StaticClass(), n"CompilerClassLikeExecutionCarrierEmpty"));
	if (Carrier == nullptr)
	{
		throw("TS-LANG-0005 setup: NewObject returned null");
	}
	TSubclassOf<AActor> Empty;
	return Carrier.EchoActorClass(Empty) == Empty && Carrier.EchoActorClass(ACameraActor::StaticClass()) == ACameraActor::StaticClass();
}
