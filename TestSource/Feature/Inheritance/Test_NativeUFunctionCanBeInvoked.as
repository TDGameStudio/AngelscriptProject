// Theme: Feature.Inheritance. WorldStory native CallFunctionByNameWithArguments into script UFUNCTION.
// C++: AngelscriptActorScriptOverrideTests.cpp::NativeUFunctionCanBeInvoked
// Oracle after ReceiveNativeValue(77): NativeInvokeObserved==1, LastNativeValue==77.
// Extra: empty handle null; default LastNativeValue 0. FixtureIsolated.
// Keep NativeInvokeObserved/LastNativeValue.

UCLASS()
class ATestScriptActorNativeUFunctionCanBeInvoked : AActor
{
	UPROPERTY()
	int NativeInvokeObserved = 0;

	UPROPERTY()
	int LastNativeValue = 0;

	UFUNCTION()
	void ReceiveNativeValue(int Value)
	{
		NativeInvokeObserved = 1;
		LastNativeValue = Value;
	}
}

bool Observe_NativeInvoke_EmptyHandleIsNull()
{
	ATestScriptActorNativeUFunctionCanBeInvoked Actor;
	return Actor == nullptr;
}

int Observe_NativeInvoke_DefaultLastValue(ATestScriptActorNativeUFunctionCanBeInvoked Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0169 setup: required ATestScriptActorNativeUFunctionCanBeInvoked is null");
	}
	return Actor.LastNativeValue;
}

int Observe_NativeInvoke_Receive77(ATestScriptActorNativeUFunctionCanBeInvoked Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0169 setup: required ATestScriptActorNativeUFunctionCanBeInvoked is null");
	}
	Actor.ReceiveNativeValue(77);
	return Actor.LastNativeValue;
}

int Observe_NativeInvoke_ZeroBoundary(ATestScriptActorNativeUFunctionCanBeInvoked Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0169 setup: required ATestScriptActorNativeUFunctionCanBeInvoked is null");
	}
	Actor.ReceiveNativeValue(0);
	return Actor.LastNativeValue;
}
