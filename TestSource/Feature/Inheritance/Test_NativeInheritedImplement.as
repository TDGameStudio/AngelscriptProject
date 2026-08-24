// Theme: Feature.Inheritance. WorldStory script actor implements native child+parent interfaces.
// C++: AngelscriptInterfaceNativeTests.cpp::NativeInheritedImplement
// Oracle after BeginPlay: ParentCastWorked==1, ChildCastWorked==1, ParentResult==7,
// ChildResult==11, NativeMarker==n"ParentRoute".
// Extra: empty handle null; pre-BeginPlay zeros/NAME_None. FixtureIsolated.
// Keep ParentCastWorked/ChildCastWorked/ParentResult/ChildResult/NativeMarker.

UCLASS()
class ATestInterfaceNativeInheritedImplement : AActor, UAngelscriptNativeChildInterface
{
	UPROPERTY()
	int ParentCastWorked = 0;

	UPROPERTY()
	int ChildCastWorked = 0;

	UPROPERTY()
	int ParentResult = 0;

	UPROPERTY()
	int ChildResult = 0;

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
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(Self);
		if (ParentRef != nullptr)
		{
			ParentCastWorked = 1;
			ParentResult = ParentRef.GetNativeValue();
			ParentRef.SetNativeMarker(n"ParentRoute");
		}

		UAngelscriptNativeChildInterface ChildRef = Cast<UAngelscriptNativeChildInterface>(Self);
		if (ChildRef != nullptr)
		{
			ChildCastWorked = 1;
			ChildResult = ChildRef.GetChildValue();
		}
	}
}

bool Observe_NativeInherited_EmptyHandleIsNull()
{
	ATestInterfaceNativeInheritedImplement Actor;
	return Actor == nullptr;
}

int Observe_NativeInherited_BeforeBeginPlay(ATestInterfaceNativeInheritedImplement Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0219 setup: required ATestInterfaceNativeInheritedImplement is null");
	}
	return Actor.ParentCastWorked + Actor.ChildCastWorked + Actor.ParentResult + Actor.ChildResult;
}

bool Observe_NativeInherited_AfterBeginPlay(ATestInterfaceNativeInheritedImplement Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0219 setup: required ATestInterfaceNativeInheritedImplement is null");
	}
	return Actor.ParentCastWorked == 1
		&& Actor.ChildCastWorked == 1
		&& Actor.ParentResult == 7
		&& Actor.ChildResult == 11
		&& Actor.NativeMarker == n"ParentRoute";
}

int Observe_NativeInherited_AdjustZeroBoundary(ATestInterfaceNativeInheritedImplement Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0219 setup: required ATestInterfaceNativeInheritedImplement is null");
	}
	int Value = 0;
	Actor.AdjustNativeValue(0, Value);
	return Value;
}
