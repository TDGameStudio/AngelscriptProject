/**
 * @version v1
 * @summary FQuat UPROPERTY defaults: an explicit identity, a constructor expression, a property with no initializer, and one built from a rotator. The observers confirm the identity default and the uninitialized fallback.
 * @topic Language
 */
/**
 * @version root
 * @summary FQuat UPROPERTY defaults: an explicit identity, a constructor expression, a property with no initializer, and one built from a rotator. The observers confirm the identity default and the uninitialized fallback.
 * @topic Baseline
 */
UCLASS()
class ACoverageFQuatDefaultsActor : AActor
{
	UPROPERTY()
	FQuat IdentityQuat = FQuat::Identity;

	UPROPERTY()
	FQuat CustomQuat = FQuat(0, 0, 0.707107, 0.707107);

	UPROPERTY()
	FQuat NoDefaultQuat;

	UPROPERTY()
	FQuat FromRotator = FQuat(FRotator(0, 90, 0));

	/**
	 * Observe that the explicit identity default materializes.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when IdentityQuat is the identity
	 * @Boundary identity default
	 */
	UFUNCTION()
	bool FQuatDefaultsIdentity()
	{
		if (!Math::IsNearlyEqual(IdentityQuat.X, 0.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(IdentityQuat.Y, 0.0))
		{
			return false;
		}

		if (!Math::IsNearlyEqual(IdentityQuat.Z, 0.0))
		{
			return false;
		}

		return Math::IsNearlyEqual(IdentityQuat.W, 1.0);
	}

	/**
	 * Observe that an uninitialized FQuat falls back to identity.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when NoDefaultQuat is the identity
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool FQuatDefaultsNoDefaultEmpty()
	{
		if (!Math::IsNearlyEqual(NoDefaultQuat.X, 0.0))
		{
			return false;
		}

		return Math::IsNearlyEqual(NoDefaultQuat.W, 1.0);
	}
}
/** @end */
