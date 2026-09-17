/**
 * @version v1
 * @summary Component-wise writes to an FQuat UPROPERTY. The observers confirm the default identity-like state and that each component write sticks.
 * @topic Language
 */
/**
 * @version root
 * @summary Component-wise writes to an FQuat UPROPERTY. The observers confirm the default identity-like state and that each component write sticks.
 * @topic Baseline
 */
UCLASS()
class ACoverageFQuatWriteActor : AActor
{
	UPROPERTY()
	FQuat QuatValue;

	/**
	 * Observe that the property defaults to the identity-like state.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the value is 0,0,0,1
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FQuatWriteDefaultEmpty()
	{
		if (!Math::IsNearlyEqual(QuatValue.X, 0.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(QuatValue.Y, 0.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(QuatValue.Z, 0.0))
		{
			return false;
		}

		return Math::IsNearlyEqual(QuatValue.W, 1.0);
	}

	/**
	 * Observe that script-side component writes all stick.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs all four components written from script
	 * @Return true when all four components read back
	 * @Boundary component writes
	 */
	UFUNCTION()
	bool FQuatWriteScriptComponentBoundary()
	{
		QuatValue.X = 0.1;
		QuatValue.Y = 0.2;
		QuatValue.Z = 0.3;
		QuatValue.W = 0.9;

		if (!Math::IsNearlyEqual(QuatValue.X, 0.1))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(QuatValue.Y, 0.2))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(QuatValue.Z, 0.3))
		{
			return false;
		}

		return Math::IsNearlyEqual(QuatValue.W, 0.9);
	}
}
/** @end */
