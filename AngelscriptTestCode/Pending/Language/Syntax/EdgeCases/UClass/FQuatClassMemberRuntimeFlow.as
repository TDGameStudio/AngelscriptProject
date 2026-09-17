/**
 * @version v1
 * @summary FQuat class-member runtime flow: a quarter turn is assigned, copied, inverted and used to rotate a vector, with each intermediate recorded in a history array and three boolean outcomes.
 * @topic Language
 */
/**
 * @version root
 * @summary FQuat class-member runtime flow: a quarter turn is assigned, copied, inverted and used to rotate a vector, with each intermediate recorded in a history array and three boolean outcomes.
 * @topic Baseline
 */
UCLASS()
class ACoverageFQuatRuntimeFlowActor : AActor
{
	UPROPERTY()
	FQuat CurrentQuat = FQuat::Identity;

	UPROPERTY()
	FQuat CopyConstructedQuat;

	UPROPERTY()
	FQuat AssignedQuat;

	UPROPERTY()
	FQuat InverseQuat;

	UPROPERTY()
	FVector RotatedForward;

	UPROPERTY()
	TArray<FQuat> History;

	UPROPERTY()
	bool bCopyEqualsAssigned = false;

	UPROPERTY()
	bool bInverseComposesToIdentity = false;

	UPROPERTY()
	bool bHistoryPreservesValues = false;

	/**
	 * Runs the copy, assign, invert and rotate sequence.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; every member records the flow's outcome
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		const FQuat LocalTurn = FQuat(FVector::UpVector, 1.5707963267948966);
		CurrentQuat = LocalTurn;
		CopyConstructedQuat = FQuat(CurrentQuat);
		AssignedQuat = FQuat::Identity;
		AssignedQuat = CopyConstructedQuat;
		InverseQuat = CurrentQuat.Inverse();
		RotatedForward = CurrentQuat.RotateVector(FVector::ForwardVector);

		History.Add(FQuat::Identity);
		History.Add(CurrentQuat);
		History.Add(InverseQuat);

		bCopyEqualsAssigned = CopyConstructedQuat == AssignedQuat;
		bInverseComposesToIdentity = (CurrentQuat * InverseQuat).IsIdentity(0.001);
		bHistoryPreservesValues = History.Num() == 3
			&& History[1].Equals(CurrentQuat, 0.001)
			&& History[2].Equals(InverseQuat, 0.001);
	}

	/**
	 * Observe that a locally constructed actor starts untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the current is identity, history is empty and flags are false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FQuatRuntimeFlowDefaultEmpty()
	{
		if (!CurrentQuat.IsIdentity(0.001))
		{
			return false;
		}

		if (History.Num() != 0)
		{
			return false;
		}

		if (bCopyEqualsAssigned)
		{
			return false;
		}

		if (bInverseComposesToIdentity)
		{
			return false;
		}

		return !bHistoryPreservesValues;
	}

	/**
	 * Observe that copy and assignment produce equal quaternions.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a local turn assigned, copied and re-assigned
	 * @Return true when the copy equals the assignment and the current keeps the turn
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool FQuatRuntimeFlowCopyIndependenceHint()
	{
		FQuat LocalTurn = FQuat(FVector::UpVector, 1.5707963267948966);
		CurrentQuat = LocalTurn;
		CopyConstructedQuat = FQuat(CurrentQuat);
		AssignedQuat = CopyConstructedQuat;

		if (!CopyConstructedQuat.Equals(AssignedQuat, 0.001))
		{
			return false;
		}

		return CurrentQuat.Equals(LocalTurn, 0.001);
	}
}
/** @end */
