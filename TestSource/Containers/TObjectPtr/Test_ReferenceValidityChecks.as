// Theme: Containers.TObjectPtr. WorldStory: IsValid, TSoftObjectPtr, TWeakObjectPtr after Destroy.
// CSV NegativeDiagnostic is wrong; C++ compiles and VerifyByPath all six flags true.
// Extra: flags default false until BeginPlay; TempActor starts null. FixtureIsolated.

UCLASS()
class ACoverageHandlesValidityActor : AActor
{
	UPROPERTY()
	bool IsValidForNullObjectFailed = false;

	UPROPERTY()
	bool IsValidForValidObjectPassed = false;

	UPROPERTY()
	bool IsValidAfterDestroyFailed = false;

	UPROPERTY()
	bool SoftRefIsValidWorked = false;

	UPROPERTY()
	bool WeakRefIsValidWorked = false;

	UPROPERTY()
	bool WeakRefInvalidAfterDestroy = false;

	UPROPERTY()
	AActor TempActor;

	UPROPERTY()
	TWeakObjectPtr<AActor> WeakRef;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test IsValid with null
		AActor NullRef = nullptr;
		if (!IsValid(NullRef))
		{
			IsValidForNullObjectFailed = true;
		}

		// Test IsValid with valid object
		if (IsValid(this))
		{
			IsValidForValidObjectPassed = true;
		}

		// Test IsValid with TSoftObjectPtr
		TSoftObjectPtr<AActor> SoftRef = this;
		if (SoftRef.IsValid())
		{
			SoftRefIsValidWorked = true;
		}

		// Test IsValid with TWeakObjectPtr
		TempActor = SpawnActor(AActor::StaticClass());
		WeakRef = TempActor;
		if (WeakRef.IsValid())
		{
			WeakRefIsValidWorked = true;
		}

		// Destroy actor and check weak ref becomes invalid
		TempActor.DestroyActor();

		// After destruction, weak ref should be invalid
		if (!WeakRef.IsValid())
		{
			WeakRefInvalidAfterDestroy = true;
		}

		// IsValid on destroyed object should fail
		if (!IsValid(TempActor))
		{
			IsValidAfterDestroyFailed = true;
		}
	}
}
