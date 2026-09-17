/**
 * @version v1
 * @summary The FVector X, Y and Z components read and written as members. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The observers cover the empty.
 * @topic Math
 */
/**
 * @version root
 * @summary The FVector X, Y and Z components read and written as members. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The observers cover the empty.
 * @topic Baseline
 */
namespace FVectorTest
{
	/**
	 * Read the X component of a known vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.MemberAccess
	 * @Inputs none
	 * @Return 10
	 */
	UFUNCTION()
	float GetX()
	{
		FVector v = FVector(10, 20, 30);
		return v.X;
	}

	/**
	 * Read the Y component of a known vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.MemberAccess
	 * @Inputs none
	 * @Return 20
	 */
	UFUNCTION()
	float GetY()
	{
		FVector v = FVector(10, 20, 30);
		return v.Y;
	}

	/**
	 * Read the Z component of a known vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.MemberAccess
	 * @Inputs none
	 * @Return 30
	 */
	UFUNCTION()
	float GetZ()
	{
		FVector v = FVector(10, 20, 30);
		return v.Z;
	}

	/**
	 * Write the X component of a known vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.MemberAccess
	 * @Inputs none
	 * @Return FVector(100, 20, 30)
	 */
	UFUNCTION()
	FVector SetX()
	{
		FVector v = FVector(10, 20, 30);
		v.X = 100;
		return v;
	}

	/**
	 * Write the Y component of a known vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.MemberAccess
	 * @Inputs none
	 * @Return FVector(10, 200, 30)
	 */
	UFUNCTION()
	FVector SetY()
	{
		FVector v = FVector(10, 20, 30);
		v.Y = 200;
		return v;
	}

	/**
	 * Write the Z component of a known vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.MemberAccess
	 * @Inputs none
	 * @Return FVector(10, 20, 300)
	 */
	UFUNCTION()
	FVector SetZ()
	{
		FVector v = FVector(10, 20, 30);
		v.Z = 300;
		return v;
	}

	/**
	 * Observe that reading X yields the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.MemberAccess
	 * @Inputs none
	 * @Return true when X reads 10
	 */
	UFUNCTION()
	bool GetXNominal()
	{
		return Math::IsNearlyEqual(GetX(), 10.0);
	}

	/**
	 * Observe that reading Y yields the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.MemberAccess
	 * @Inputs none
	 * @Return true when Y reads 20
	 */
	UFUNCTION()
	bool GetYNominal()
	{
		return Math::IsNearlyEqual(GetY(), 20.0);
	}

	/**
	 * Observe that reading Z yields the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.MemberAccess
	 * @Inputs none
	 * @Return true when Z reads 30
	 */
	UFUNCTION()
	bool GetZNominal()
	{
		return Math::IsNearlyEqual(GetZ(), 30.0);
	}

	/**
	 * Observe that writing X is visible on the result.
	 *
	 * @Kind Observe
	 * @Covers FVector.MemberAccess
	 * @Inputs none
	 * @Return true when the result equals FVector(100, 20, 30)
	 */
	UFUNCTION()
	bool SetXNominal()
	{
		return SetX().Equals(FVector(100, 20, 30));
	}

	/**
	 * Observe that writing Y is visible on the result.
	 *
	 * @Kind Observe
	 * @Covers FVector.MemberAccess
	 * @Inputs none
	 * @Return true when the result equals FVector(10, 200, 30)
	 */
	UFUNCTION()
	bool SetYNominal()
	{
		return SetY().Equals(FVector(10, 200, 30));
	}

	/**
	 * Observe that writing Z is visible on the result.
	 *
	 * @Kind Observe
	 * @Covers FVector.MemberAccess
	 * @Inputs none
	 * @Return true when the result equals FVector(10, 20, 300)
	 */
	UFUNCTION()
	bool SetZNominal()
	{
		return SetZ().Equals(FVector(10, 20, 300));
	}

	/**
	 * Observe that a default vector reads as zero on every axis.
	 *
	 * @Kind Observe
	 * @Covers FVector.MemberAccess
	 * @Inputs a default-constructed vector
	 * @Return true when all three components are 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool GetXDefaultEmpty()
	{
		FVector Empty = FVector();

		if (!Math::IsNearlyEqual(Empty.X, 0.0))
		{
			return false;
		}
		if (!Math::IsNearlyEqual(Empty.Y, 0.0))
		{
			return false;
		}
		return Math::IsNearlyEqual(Empty.Z, 0.0);
	}

	/**
	 * Observe that mutating a copy leaves the source vector untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector.MemberAccess
	 * @Inputs a known vector and a mutated copy of it
	 * @Return true when the source still reads (10, 20, 30) and the copy reads (100, 20, 30)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool SetXCopyIndependence()
	{
		FVector Original = FVector(10, 20, 30);
		FVector Mutated = Original;
		Mutated.X = 100;

		if (!Original.Equals(FVector(10, 20, 30)))
		{
			return false;
		}
		return Mutated.Equals(FVector(100, 20, 30));
	}
}
/** @end */
