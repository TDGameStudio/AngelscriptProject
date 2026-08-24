// Theme: Definitions.UInterface. WorldStory: script casts one C++ multi-interface actor to parent and secondary.
// C++: bParentCastSucceeded/bSecondaryCastSucceeded 1; ParentReadValue 777; SecondaryReadValue 4242;
// NativeMarker FromParent; SecondaryLabel FromSecondary.
// Extra: null Target leaves both success flags 0. FixtureIsolated.

UCLASS()
class ATestInterfaceNativePointerOffset : AActor
{
	UPROPERTY()
	UObject Target;

	UPROPERTY()
	int bParentCastSucceeded = 0;

	UPROPERTY()
	int bSecondaryCastSucceeded = 0;

	UPROPERTY()
	int ParentReadValue = 0;

	UPROPERTY()
	int SecondaryReadValue = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(Target);
		if (ParentRef != nullptr)
		{
			bParentCastSucceeded = 1;
			ParentReadValue = ParentRef.GetNativeValue();
			ParentRef.SetNativeMarker(n"FromParent");
		}

		UAngelscriptNativeSecondaryInterface SecondaryRef = Cast<UAngelscriptNativeSecondaryInterface>(Target);
		if (SecondaryRef != nullptr)
		{
			bSecondaryCastSucceeded = 1;
			SecondaryReadValue = SecondaryRef.GetSecondaryValue();
			SecondaryRef.SetSecondaryLabel("FromSecondary");
		}
	}
}

bool Observe_NullTargetDoesNotCastParent()
{
	UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
	return ParentRef == nullptr;
}

bool Observe_NullTargetDoesNotCastSecondary()
{
	UAngelscriptNativeSecondaryInterface SecondaryRef = Cast<UAngelscriptNativeSecondaryInterface>(nullptr);
	return SecondaryRef == nullptr;
}
