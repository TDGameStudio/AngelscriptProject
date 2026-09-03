/**
 * FQuat UPROPERTY defaults: an explicit identity, a constructor expression, a
 * property with no initializer, and one built from a rotator. The observers
 * confirm the identity default and the uninitialized fallback.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.FQuatDeclarationDefaults
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.FQuatDeclarationDefaults
 * @Provenance C++: AngelscriptCoverageFQuatPropertyTests.cpp::FQuatDeclarationDefaults
 * @Provenance sha256=1e3daff9e47c667b507db90e2f756daf735901b5c66beb81f499a045fee14b09; lines 134-150.
 * @Provenance Oracle: IdentityQuat XYZ=0 W=1; constructor-expression CustomQuat/FromRotator currently
 * @Provenance materialize as Identity (W=1, Z=0); NoDefaultQuat is Identity. Extra: local construct.
 * @Provenance FixtureIsolated. Keep the C++ VerifyByPath field names.
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
