/**
 * @version v1
 * @summary Inverse, GetNormalized and the IsNormalized and IsIdentity flags. C++ executes each entrypoint and compares the result with the native equivalent, so those names are part of the contract and are kept verbatim. The.
 * @topic Math
 */
/**
 * @version root
 * @summary Inverse, GetNormalized and the IsNormalized and IsIdentity flags. C++ executes each entrypoint and compares the result with the native equivalent, so those names are part of the contract and are kept verbatim. The.
 * @topic Baseline
 */
namespace FQuatTest
{
	/**
	 * Invert a ninety degree yaw.
	 *
	 * @Kind Observe
	 * @Covers FQuat.InverseAndNormalize
	 * @Inputs none
	 * @Return the inverse of a yaw-90 quaternion
	 */
	UFUNCTION()
	FQuat InverseQuat()
	{
		FQuat q = FQuat(FRotator(0, 90, 0));
		return q.Inverse();
	}

	/**
	 * Normalize an unnormalized quaternion.
	 *
	 * @Kind Observe
	 * @Covers FQuat.InverseAndNormalize
	 * @Inputs none
	 * @Return FQuat(0.1, 0.2, 0.3, 0.9) brought back to unit length
	 */
	UFUNCTION()
	FQuat NormalizeQuat()
	{
		FQuat q = FQuat(0.1, 0.2, 0.3, 0.9);
		return q.GetNormalized();
	}

	/**
	 * Report whether the identity is normalized.
	 *
	 * @Kind Observe
	 * @Covers FQuat.InverseAndNormalize
	 * @Inputs none
	 * @Return the IsNormalized flag of the identity, expected true
	 */
	UFUNCTION()
	bool IsNormalized()
	{
		FQuat q = FQuat::Identity;
		return q.IsNormalized();
	}

	/**
	 * Report whether the identity is the identity.
	 *
	 * @Kind Observe
	 * @Covers FQuat.InverseAndNormalize
	 * @Inputs none
	 * @Return the IsIdentity flag of the identity, expected true
	 */
	UFUNCTION()
	bool IsIdentityQuat()
	{
		FQuat q = FQuat::Identity;
		return q.IsIdentity();
	}

	/**
	 * Observe that the inversion matches the native result.
	 *
	 * @Kind Observe
	 * @Covers FQuat.InverseAndNormalize
	 * @Inputs none
	 * @Return true when the result equals q.Inverse()
	 */
	UFUNCTION()
	bool InverseQuatNominal()
	{
		FQuat q = FQuat(FRotator(0, 90, 0));
		return InverseQuat().Equals(q.Inverse(), 0.01);
	}

	/**
	 * Observe that the normalization matches the native result.
	 *
	 * @Kind Observe
	 * @Covers FQuat.InverseAndNormalize
	 * @Inputs none
	 * @Return true when the result equals q.GetNormalized()
	 */
	UFUNCTION()
	bool NormalizeQuatNominal()
	{
		FQuat q = FQuat(0.1, 0.2, 0.3, 0.9);
		return NormalizeQuat().Equals(q.GetNormalized(), 0.01);
	}

	/**
	 * Observe that the identity reports itself normalized.
	 *
	 * @Kind Observe
	 * @Covers FQuat.InverseAndNormalize
	 * @Inputs none
	 * @Return true when the flag is set
	 */
	UFUNCTION()
	bool IsNormalizedNominal()
	{
		return IsNormalized();
	}

	/**
	 * Observe that the identity reports itself as the identity.
	 *
	 * @Kind Observe
	 * @Covers FQuat.InverseAndNormalize
	 * @Inputs none
	 * @Return true when the flag is set
	 */
	UFUNCTION()
	bool IsIdentityQuatNominal()
	{
		return IsIdentityQuat();
	}

	/**
	 * Observe that a default quaternion carries both identity flags.
	 *
	 * @Kind Observe
	 * @Covers FQuat.InverseAndNormalize
	 * @Inputs a default-constructed quaternion
	 * @Return true when it reports both as the identity and as normalized
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (!FQuat().IsIdentity())
		{
			return false;
		}
		return FQuat().IsNormalized();
	}

	/**
	 * Observe that an unnormalized quaternion reports itself as not normalized.
	 *
	 * @Kind Observe
	 * @Covers FQuat.InverseAndNormalize
	 * @Inputs a quaternion whose length is not one
	 * @Return true when the flag is clear
	 * @Boundary unnormalized
	 */
	UFUNCTION()
	bool UnnormalizedBoundary()
	{
		FQuat Inflated = FQuat(0.1, 0.2, 0.3, 0.9);
		return !Inflated.IsNormalized();
	}
}
/** @end */
