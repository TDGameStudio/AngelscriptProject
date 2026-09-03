/**
 * Object handles compare with == and != by reference identity, not by value:
 * two handles to the same actor are equal, a handle compared against nullptr
 * reports whether it is null, and handles to two different actors are unequal.
 * A UPROPERTY holding an actor starts null before anything is spawned into it.
 * The results are recorded on UPROPERTYs so C++ can read them by path after
 * BeginPlay runs.
 * The UPROPERTY names are read by path from C++ and must not be renamed:
 * SameRefEqual, NullComparison, DifferentRefNotEqual, OtherActor,
 * OtherActorStartedNull.
 *
 * @Theme Language.Operators
 * @Subject Operators.HandleComparison
 * @Harness UClass
 * @Tag Language.Operators.HandleComparison
 * @Namespace OperatorsTest
 * @Provenance C++: AngelscriptCoverageHandleTests.cpp::HandleComparison
 * @Provenance sha256=a70230f3b5140d84fe7283fe12d9ab8634f014d1091c0f8af16017859e94897d; lines 179-222.
 * @Provenance Oracle VerifyByPath: SameRefEqual true; NullComparison true; DifferentRefNotEqual true.
 * @Provenance Extra: OtherActorStartedNull is the default-null vector before SpawnActor.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

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

	/**
	 * Run the handle comparisons once at play time, so the C++ fixture can read
	 * the resulting property values by path.
	 */
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

namespace OperatorsTest
{
	/**
	 * Observe reference equality: two handles to the same object are equal.
	 *
	 * @Kind WorldStory
	 * @Covers Operators.Comparison
	 * @Inputs Spawn the comparison actor and read its SameRefEqual property
	 * @Return true when the two handles to the same actor compared equal
	 */
	UFUNCTION()
	bool HandlesToSameObjectAreEqual()
	{
		ACoverageHandleComparisonActor Actor = SpawnActor(ACoverageHandleComparisonActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}
		return Actor.SameRefEqual;
	}

	/**
	 * Observe null comparison: a null handle equals nullptr while a live actor
	 * does not.
	 *
	 * @Kind WorldStory
	 * @Covers Operators.Comparison
	 * @Inputs Spawn the comparison actor and read its NullComparison property
	 * @Return true when the null check behaved as expected
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullHandleComparesEqualToNullptr()
	{
		ACoverageHandleComparisonActor Actor = SpawnActor(ACoverageHandleComparisonActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}
		return Actor.NullComparison;
	}

	/**
	 * Observe the default-null boundary: an unset actor property is null before
	 * anything is spawned into it.
	 *
	 * @Kind WorldStory
	 * @Covers Operators.Comparison
	 * @Inputs Spawn the comparison actor and read its OtherActorStartedNull property
	 * @Return true when the property started null
	 * @Boundary unset actor property
	 */
	UFUNCTION()
	bool UnsetActorPropertyStartsNull()
	{
		ACoverageHandleComparisonActor Actor = SpawnActor(ACoverageHandleComparisonActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}
		return Actor.OtherActorStartedNull;
	}

	/**
	 * Observe reference inequality: handles to two different objects compare
	 * unequal.
	 *
	 * @Kind WorldStory
	 * @Covers Operators.Comparison
	 * @Inputs Spawn the comparison actor and read its DifferentRefNotEqual property
	 * @Return true when the two distinct actors compared unequal
	 */
	UFUNCTION()
	bool HandlesToDifferentObjectsAreUnequal()
	{
		ACoverageHandleComparisonActor Actor = SpawnActor(ACoverageHandleComparisonActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}
		return Actor.DifferentRefNotEqual;
	}
}
