// Theme: Feature.Inheritance. WorldStory parent Execute_ bridge through child implementation.
// C++: AngelscriptInterfaceNativeTests.cpp::NativeInheritedParentBridgeSetterAndRef
// Oracle after C++ Execute_SetNativeMarker("FromParentExecute") + AdjustNativeValue(9) on 20:
// NativeMarker==n"FromParentExecute", AdjustedValue==29, ParentAdjustedValue==29.
// Extra: empty handle null; defaults NAME_None/0; AdjustNativeValue(0) stays 20.
// FixtureIsolated. Keep NativeMarker/ParentAdjustedValue.

UCLASS()
class ATestInterfaceNativeInheritedParentBridge : AActor, UAngelscriptNativeChildInterface
{
	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	int ParentAdjustedValue = 0;

	UFUNCTION()
	int GetNativeValue() const
	{
		return 0;
	}

	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		NativeMarker = Marker;
	}

	UFUNCTION()
	void AdjustNativeValue(int Delta, int& Value)
	{
		Value += Delta;
		ParentAdjustedValue = Value;
	}

	UFUNCTION()
	int GetChildValue() const
	{
		return 11;
	}
}

bool Observe_ParentBridge_EmptyHandleIsNull()
{
	ATestInterfaceNativeInheritedParentBridge Actor;
	return Actor == nullptr;
}

FName Observe_ParentBridge_DefaultMarker(ATestInterfaceNativeInheritedParentBridge Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0220 setup: required ATestInterfaceNativeInheritedParentBridge is null");
	}
	return Actor.NativeMarker;
}

int Observe_ParentBridge_ScriptAdjustFrom20(ATestInterfaceNativeInheritedParentBridge Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0220 setup: required ATestInterfaceNativeInheritedParentBridge is null");
	}
	int Value = 20;
	Actor.AdjustNativeValue(9, Value);
	return Value;
}

int Observe_ParentBridge_PersistedAdjusted(ATestInterfaceNativeInheritedParentBridge Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0220 setup: required ATestInterfaceNativeInheritedParentBridge is null");
	}
	int Value = 20;
	Actor.AdjustNativeValue(9, Value);
	return Actor.ParentAdjustedValue;
}

FName Observe_ParentBridge_SetFromParentExecute(ATestInterfaceNativeInheritedParentBridge Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0220 setup: required ATestInterfaceNativeInheritedParentBridge is null");
	}
	Actor.SetNativeMarker(n"FromParentExecute");
	return Actor.NativeMarker;
}

int Observe_ParentBridge_ZeroDeltaBoundary(ATestInterfaceNativeInheritedParentBridge Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0220 setup: required ATestInterfaceNativeInheritedParentBridge is null");
	}
	int Value = 20;
	Actor.AdjustNativeValue(0, Value);
	return Value;
}
