// Theme: Language.Operators.Comparison. WorldStory handle == and !=.
// C++: AngelscriptCoverageHandleTests.cpp::HandleComparison
// sha256=a70230f3b5140d84fe7283fe12d9ab8634f014d1091c0f8af16017859e94897d; lines 179-222.
// Oracle VerifyByPath: SameRefEqual true; NullComparison true; DifferentRefNotEqual true.
// Extra: OtherActorStartedNull is the default-null vector before SpawnActor.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageHandleComparisonActor : AActor
{
	UPROPERTY()
	bool SameRefEqual = false;

	UPROPERTY()
	bool NullComparison = false;

	UPROPERTY()
	bool DifferentRefNotEqual = false;

	UPROPERTY()
	AActor OtherActor;

	UPROPERTY()
	bool OtherActorStartedNull = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		AActor Handle1 = this;
		AActor Handle2 = this;

		// Same object should be equal
		if (Handle1 == Handle2)
		{
			SameRefEqual = true;
		}

		// Null comparisons
		AActor NullHandle = nullptr;
		if (NullHandle == nullptr && this != nullptr)
		{
			NullComparison = true;
		}

		OtherActorStartedNull = (OtherActor == nullptr);

		// Different objects should not be equal
		OtherActor = SpawnActor(AActor::StaticClass());
		if (this != OtherActor && OtherActor != nullptr)
		{
			DifferentRefNotEqual = true;
		}
	}
}
