/**
 * FVectors declared in every storage class script can reach, plus the index operator read
 * and write. C++ executes each entrypoint and checks the value it produces, so those
 * names are part of the contract and are kept verbatim. PlainClassMemberValueRaisesBoundary
 * reads a member off an unconstructed plain struct, which raises a null pointer access at
 * run time; C++ asserts that exception and no observer calls it.
 *
 * @Theme Gameplay.FVector
 * @Subject FVector.DeclarationsAndIndexAccess
 * @Harness Function
 * @Tag Gameplay.FVector.FVectorDeclarationsAndIndexAccess
 * @Namespace FVectorTest
 * @Provenance Theme: Gameplay.FVector. Positive declaration/index oracles plus runtime boundary.
 * @Provenance C++: AngelscriptCoverageFVectorExpressionTests.cpp::FVectorDeclarationsAndIndexAccess
 * @Provenance Oracle: LocalDefaultIsZero 0.0; LocalDefaultValue 6.0; LocalConstValue 1.0;
 * @Provenance GlobalConstValue 0.0; IndexRead 15.0; IndexWrite (7,8,9).
 * @Provenance PlainClassMemberValueRaisesBoundary raises Null pointer access.
 * @Provenance Extra: empty local default; do not wrap the exception function in Observe.
 * @Provenance DefaultSafe.
 */

const FVector GlobalConstVector = FVector::ZeroVector;

/**
 * A plain script struct holding a vector, used to show that reading a member off an
 * unconstructed one is a runtime boundary rather than a compile error.
 *
 * @Covers FVector.DeclarationsAndIndexAccess
 * @Inputs none
 * @Return a holder whose Value is set during construction
 */
class FPlainVectorHolder
{
	FVector Value;

	/**
	 * Populate the held vector.
	 *
	 * @Kind Helper
	 * @Covers FVector.DeclarationsAndIndexAccess
	 * @Inputs none
	 * @Return Value set to FVector(2, 4, 6)
	 */
	FPlainVectorHolder()
	{
		Value = FVector(2, 4, 6);
	}
}

namespace FVectorTest
{
	/**
	 * Sum the components of an uninitialised local.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationsAndIndexAccess
	 * @Inputs none
	 * @Return 0, the sum of a default vector's components
	 * @Boundary default value
	 */
	UFUNCTION()
	float LocalDefaultIsZero()
	{
		FVector v;
		return v.X + v.Y + v.Z;
	}

	/**
	 * Sum the components of an initialised local.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationsAndIndexAccess
	 * @Inputs none
	 * @Return 6, the sum of FVector(1, 2, 3)
	 */
	UFUNCTION()
	float LocalDefaultValue()
	{
		FVector v = FVector(1, 2, 3);
		return v.X + v.Y + v.Z;
	}

	/**
	 * Read a component through a const local.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationsAndIndexAccess
	 * @Inputs none
	 * @Return 1, the X component of FVector(1, 0, 0)
	 */
	UFUNCTION()
	float LocalConstValue()
	{
		const FVector v = FVector(1, 0, 0);
		return v.X;
	}

	/**
	 * Sum the components of a module-level const.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationsAndIndexAccess
	 * @Inputs none
	 * @Return 0, the sum of the zero vector's components
	 */
	UFUNCTION()
	float GlobalConstValue()
	{
		return GlobalConstVector.X + GlobalConstVector.Y + GlobalConstVector.Z;
	}

	/**
	 * Read every component through the index operator.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationsAndIndexAccess
	 * @Inputs none
	 * @Return 15, the sum of FVector(4, 5, 6)
	 */
	UFUNCTION()
	float IndexRead()
	{
		FVector v = FVector(4, 5, 6);
		return v[0] + v[1] + v[2];
	}

	/**
	 * Write every component through the index operator.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationsAndIndexAccess
	 * @Inputs none
	 * @Return FVector(7, 8, 9)
	 */
	UFUNCTION()
	FVector IndexWrite()
	{
		FVector v = FVector::ZeroVector;
		v[0] = 7;
		v[1] = 8;
		v[2] = 9;
		return v;
	}

	/**
	 * Read a member off an unconstructed plain struct, which raises a null pointer access.
	 * C++ asserts that exception; no observer calls this.
	 *
	 * @Kind Action
	 * @Covers FVector.DeclarationsAndIndexAccess
	 * @Inputs none
	 * @Return nothing reachable; throws before a value can be produced
	 * @Boundary unconstructed plain struct
	 */
	UFUNCTION()
	int PlainClassMemberValueRaisesBoundary()
	{
		FPlainVectorHolder Holder;
		return Holder.Value.X + Holder.Value.Y + Holder.Value.Z;
	}

	/**
	 * Observe that an uninitialised local sums to zero.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationsAndIndexAccess
	 * @Inputs none
	 * @Return true when the sum is 0
	 */
	UFUNCTION()
	bool LocalDefaultIsZeroNominal()
	{
		return Math::IsNearlyEqual(LocalDefaultIsZero(), 0.0);
	}

	/**
	 * Observe that an initialised local sums to its component total.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationsAndIndexAccess
	 * @Inputs none
	 * @Return true when the sum is 6
	 */
	UFUNCTION()
	bool LocalDefaultValueNominal()
	{
		return Math::IsNearlyEqual(LocalDefaultValue(), 6.0);
	}

	/**
	 * Observe that a const local reads through.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationsAndIndexAccess
	 * @Inputs none
	 * @Return true when the value is 1
	 */
	UFUNCTION()
	bool LocalConstValueNominal()
	{
		return Math::IsNearlyEqual(LocalConstValue(), 1.0);
	}

	/**
	 * Observe that a module-level const reads through.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationsAndIndexAccess
	 * @Inputs none
	 * @Return true when the sum is 0
	 */
	UFUNCTION()
	bool GlobalConstValueNominal()
	{
		return Math::IsNearlyEqual(GlobalConstValue(), 0.0);
	}

	/**
	 * Observe that the index operator reads every component.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationsAndIndexAccess
	 * @Inputs none
	 * @Return true when the sum is 15
	 */
	UFUNCTION()
	bool IndexReadNominal()
	{
		return Math::IsNearlyEqual(IndexRead(), 15.0);
	}

	/**
	 * Observe that the index operator writes every component.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationsAndIndexAccess
	 * @Inputs none
	 * @Return true when the result equals FVector(7, 8, 9)
	 */
	UFUNCTION()
	bool IndexWriteNominal()
	{
		return IndexWrite().Equals(FVector(7, 8, 9));
	}

	/**
	 * Observe that an uninitialised local equals the zero vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationsAndIndexAccess
	 * @Inputs an uninitialised local
	 * @Return true when it equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool LocalDefaultEmptyZero()
	{
		FVector Empty;
		return Empty.Equals(FVector::ZeroVector);
	}

	/**
	 * Observe that writing through the index operator on a copy leaves the source alone.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationsAndIndexAccess
	 * @Inputs the zero vector and a written copy of it
	 * @Return true when the source is still zero and the copy reads (7, 8, 9)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool IndexWriteCopyIndependence()
	{
		FVector Original = FVector::ZeroVector;
		FVector Written = Original;
		Written[0] = 7;
		Written[1] = 8;
		Written[2] = 9;

		if (!Original.Equals(FVector::ZeroVector))
		{
			return false;
		}
		return Written.Equals(FVector(7, 8, 9));
	}
}
