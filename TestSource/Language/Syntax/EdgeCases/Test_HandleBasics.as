// Theme: Language.Syntax.EdgeCases. WorldStory AActor handle null/IsValid/assign.
// C++: AngelscriptCoverageHandleTests.cpp::HandleBasics
// sha256=054e81fae4daf61d72e9537c72c6f0bd8b90601c27dde1c4b89da0ba6ffd9100; lines 79-137.
// Oracle: TestPassed=true; NullCheckResult=3; IsValidResult=2.
// Extra: TargetActor null, results 0, TestPassed false. FixtureIsolated.

UCLASS()
class ACoverageHandleBasicsActor : AActor
{
	UPROPERTY()
	bool TestPassed = false;

	UPROPERTY()
	AActor TargetActor;

	UPROPERTY()
	int NullCheckResult = 0;

	UPROPERTY()
	int IsValidResult = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test null by default
		if (TargetActor == nullptr)
		{
			NullCheckResult = 1;
		}

		// Test IsValid with nullptr
		if (!IsValid(TargetActor))
		{
			IsValidResult = 1;
		}

		// Assign self
		TargetActor = this;

		// Test non-null after assignment
		if (TargetActor != nullptr)
		{
			NullCheckResult = 2;
		}

		// Test IsValid with valid object
		if (IsValid(TargetActor))
		{
			IsValidResult = 2;
		}

		// Assign back to null
		TargetActor = nullptr;

		// Verify null again
		if (TargetActor == nullptr)
		{
			NullCheckResult = 3;
		}

		TestPassed = (NullCheckResult == 3 && IsValidResult == 2);
	}
}

bool Observe_HandleBasics_DefaultEmpty(ACoverageHandleBasicsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_HandleBasics setup: required Actor is null");
	}
	return !Actor.TestPassed && Actor.TargetActor == nullptr && Actor.NullCheckResult == 0 && Actor.IsValidResult == 0;
}
