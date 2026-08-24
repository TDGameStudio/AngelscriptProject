// Theme: Containers.TObjectPtr. WorldStory: Cast, comparison, GetClass, GetName on APawn.
// C++ VerifyByPath: CastToBaseWorked, CastToDerivedWorked, CastToUnrelatedFailed,
// ComparisonWorked, GetClassWorked, GetNameWorked all true.
// Extra: flags default false until BeginPlay. FixtureIsolated.

UCLASS()
class ACoverageHandlesObjectRefOpsActor : APawn
{
	UPROPERTY()
	bool CastToBaseWorked = false;

	UPROPERTY()
	bool CastToDerivedWorked = false;

	UPROPERTY()
	bool CastToUnrelatedFailed = false;

	UPROPERTY()
	bool ComparisonWorked = false;

	UPROPERTY()
	bool GetClassWorked = false;

	UPROPERTY()
	bool GetNameWorked = false;

	UPROPERTY()
	FString ActorName;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test Cast to base class
		AActor ActorBase = Cast<AActor>(this);
		if (ActorBase != nullptr)
		{
			CastToBaseWorked = true;
		}

		// Test Cast back to derived
		APawn PawnDerived = Cast<APawn>(ActorBase);
		if (PawnDerived != nullptr && PawnDerived == this)
		{
			CastToDerivedWorked = true;
		}

		// Test Cast to unrelated type
		APlayerController Controller = Cast<APlayerController>(this);
		if (Controller == nullptr)
		{
			CastToUnrelatedFailed = true;
		}

		// Test comparison operators
		AActor Ref1 = this;
		AActor Ref2 = this;
		AActor OtherRef = SpawnActor(AActor::StaticClass());
		if (Ref1 == Ref2 && Ref1 != OtherRef)
		{
			ComparisonWorked = true;
		}

		// Test GetClass
		UClass MyClass = GetClass();
		if (MyClass != nullptr)
		{
			GetClassWorked = true;
		}

		// Test GetName
		FString Name = GetName().ToString();
		if (!Name.IsEmpty())
		{
			GetNameWorked = true;
			ActorName = Name;
		}
	}
}
