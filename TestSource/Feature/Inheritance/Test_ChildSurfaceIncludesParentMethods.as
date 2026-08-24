// Theme: Feature.Inheritance. WorldStory native child interface exposes inherited parent methods.
// C++: AngelscriptInterfaceNativeInheritedChildSurfaceTests.cpp::ChildSurfaceIncludesParentMethods
// Oracle after BeginPlay: ChildCastWorked==1, ChildParentResult==7, ChildAdjustedValue==29,
// ChildOwnResult==11, NativeMarker==n"ChildRoute".
// Extra: empty handle null; pre-BeginPlay zeros/NAME_None. FixtureIsolated.
// Keep ChildCastWorked/ChildParentResult/ChildAdjustedValue/ChildOwnResult/NativeMarker.

UCLASS()
class ATestInterfaceNativeInheritedChildSurface : AActor, UAngelscriptNativeChildInterface
{
	UPROPERTY()
	int ChildCastWorked = 0;

	UPROPERTY()
	int ChildParentResult = 0;

	UPROPERTY()
	int ChildAdjustedValue = 0;

	UPROPERTY()
	int ChildOwnResult = 0;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UFUNCTION()
	int GetNativeValue() const
	{
		return 7;
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
	}

	UFUNCTION()
	int GetChildValue() const
	{
		return 11;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UAngelscriptNativeChildInterface ChildRef = Cast<UAngelscriptNativeChildInterface>(Self);
		if (ChildRef == nullptr)
		{
			return;
		}

		ChildCastWorked = 1;
		ChildParentResult = ChildRef.GetNativeValue();
		int Value = 20;
		ChildRef.AdjustNativeValue(9, Value);
		ChildAdjustedValue = Value;
		ChildOwnResult = ChildRef.GetChildValue();
		ChildRef.SetNativeMarker(n"ChildRoute");
	}
}

bool Observe_ChildSurface_EmptyHandleIsNull()
{
	ATestInterfaceNativeInheritedChildSurface Actor;
	return Actor == nullptr;
}

int Observe_ChildSurface_BeforeBeginPlay(ATestInterfaceNativeInheritedChildSurface Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0218 setup: required ATestInterfaceNativeInheritedChildSurface is null");
	}
	return Actor.ChildCastWorked + Actor.ChildParentResult + Actor.ChildAdjustedValue + Actor.ChildOwnResult;
}

bool Observe_ChildSurface_AfterBeginPlay(ATestInterfaceNativeInheritedChildSurface Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0218 setup: required ATestInterfaceNativeInheritedChildSurface is null");
	}
	return Actor.ChildCastWorked == 1
		&& Actor.ChildParentResult == 7
		&& Actor.ChildAdjustedValue == 29
		&& Actor.ChildOwnResult == 11
		&& Actor.NativeMarker == n"ChildRoute";
}

int Observe_ChildSurface_GetNativeValueDirect(ATestInterfaceNativeInheritedChildSurface Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0218 setup: required ATestInterfaceNativeInheritedChildSurface is null");
	}
	return Actor.GetNativeValue();
}

FName Observe_ChildSurface_EmptyMarkerDefault(ATestInterfaceNativeInheritedChildSurface Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0218 setup: required ATestInterfaceNativeInheritedChildSurface is null");
	}
	return Actor.NativeMarker;
}
