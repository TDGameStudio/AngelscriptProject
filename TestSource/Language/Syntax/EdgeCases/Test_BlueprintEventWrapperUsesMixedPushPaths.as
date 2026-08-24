// Theme: Language.Syntax.EdgeCases. Positive BlueprintEvent mixed FString + TSubclassOf push paths.
// C++: AngelscriptCompilerBlueprintEventWrapperTests.cpp::BlueprintEventWrapperUsesMixedPushPaths
// sha256=79b7d5bf397ed918e8ea638086ac64d0aef5fc081364dbd00c975efb18fd5dc3; lines 257-273.
// Oracle: Entry() == EvaluateMixedPush("Alpha", AActor::StaticClass()) == 42.
// Extra: empty TSubclassOf returns 0; empty Label still matches the class. DefaultSafe.

UCLASS()
class UCompilerBlueprintEventMixedPushCarrier : UObject
{
	UFUNCTION(BlueprintEvent)
	int EvaluateMixedPush(const FString& Label, TSubclassOf<AActor> TypeValue)
	{
		return TypeValue == AActor::StaticClass() ? 42 : 0;
	}

	UFUNCTION()
	int Entry()
	{
		return EvaluateMixedPush("Alpha", AActor::StaticClass());
	}
}

bool Observe_Entry_Nominal()
{
	UCompilerBlueprintEventMixedPushCarrier Carrier =
		Cast<UCompilerBlueprintEventMixedPushCarrier>(
			NewObject(GetTransientPackage(), UCompilerBlueprintEventMixedPushCarrier::StaticClass(), n"CompilerBlueprintEventMixedPushCarrier"));
	if (Carrier == nullptr)
	{
		throw("TS-LANG-0002 setup: NewObject returned null");
	}
	return Carrier.Entry() == 42;
}

bool Observe_EvaluateMixedPush_EmptyTypeBoundary()
{
	UCompilerBlueprintEventMixedPushCarrier Carrier =
		Cast<UCompilerBlueprintEventMixedPushCarrier>(
			NewObject(GetTransientPackage(), UCompilerBlueprintEventMixedPushCarrier::StaticClass(), n"CompilerBlueprintEventMixedPushCarrierEmpty"));
	if (Carrier == nullptr)
	{
		throw("TS-LANG-0002 setup: NewObject returned null");
	}
	TSubclassOf<AActor> Empty;
	return Carrier.EvaluateMixedPush("Alpha", Empty) == 0;
}

bool Observe_EvaluateMixedPush_EmptyLabel()
{
	UCompilerBlueprintEventMixedPushCarrier Carrier =
		Cast<UCompilerBlueprintEventMixedPushCarrier>(
			NewObject(GetTransientPackage(), UCompilerBlueprintEventMixedPushCarrier::StaticClass(), n"CompilerBlueprintEventMixedPushCarrierLabel"));
	if (Carrier == nullptr)
	{
		throw("TS-LANG-0002 setup: NewObject returned null");
	}
	return Carrier.EvaluateMixedPush("", AActor::StaticClass()) == 42;
}
