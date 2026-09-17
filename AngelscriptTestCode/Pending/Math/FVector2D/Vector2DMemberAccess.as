/**
 * @version v1
 * @summary The FVector2D X and Y components read and written as members. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The observers cover the empty.
 * @topic Math
 */
/**
 * @version root
 * @summary The FVector2D X and Y components read and written as members. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The observers cover the empty.
 * @topic Baseline
 */
namespace FVector2DTest
{
	/**
	 * Read the X component of a known vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.MemberAccess
	 * @Inputs none
	 * @Return 10.5
	 */
	UFUNCTION()
	float GetX()
	{
		FVector2D v = FVector2D(10.5, 20.5);
		return v.X;
	}

	/**
	 * Read the Y component of a known vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.MemberAccess
	 * @Inputs none
	 * @Return 20.5
	 */
	UFUNCTION()
	float GetY()
	{
		FVector2D v = FVector2D(10.5, 20.5);
		return v.Y;
	}

	/**
	 * Write the X component of a known vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.MemberAccess
	 * @Inputs none
	 * @Return FVector2D(100.0, 20.0)
	 */
	UFUNCTION()
	FVector2D SetX()
	{
		FVector2D v = FVector2D(10.0, 20.0);
		v.X = 100.0;
		return v;
	}

	/**
	 * Write the Y component of a known vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.MemberAccess
	 * @Inputs none
	 * @Return FVector2D(10.0, 200.0)
	 */
	UFUNCTION()
	FVector2D SetY()
	{
		FVector2D v = FVector2D(10.0, 20.0);
		v.Y = 200.0;
		return v;
	}

	/**
	 * Write both components of a known vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.MemberAccess
	 * @Inputs none
	 * @Return FVector2D(99.0, 88.0)
	 */
	UFUNCTION()
	FVector2D SetBoth()
	{
		FVector2D v = FVector2D(1.0, 2.0);
		v.X = 99.0;
		v.Y = 88.0;
		return v;
	}

	/**
	 * Observe that reading X yields the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.MemberAccess
	 * @Inputs none
	 * @Return true when X reads 10.5
	 */
	UFUNCTION()
	bool GetXNominal()
	{
		return Math::IsNearlyEqual(GetX(), 10.5);
	}

	/**
	 * Observe that reading Y yields the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.MemberAccess
	 * @Inputs none
	 * @Return true when Y reads 20.5
	 */
	UFUNCTION()
	bool GetYNominal()
	{
		return Math::IsNearlyEqual(GetY(), 20.5);
	}

	/**
	 * Observe that writing X is visible on the result.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.MemberAccess
	 * @Inputs none
	 * @Return true when the result equals FVector2D(100.0, 20.0)
	 */
	UFUNCTION()
	bool SetXNominal()
	{
		return SetX().Equals(FVector2D(100.0, 20.0));
	}

	/**
	 * Observe that writing Y is visible on the result.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.MemberAccess
	 * @Inputs none
	 * @Return true when the result equals FVector2D(10.0, 200.0)
	 */
	UFUNCTION()
	bool SetYNominal()
	{
		return SetY().Equals(FVector2D(10.0, 200.0));
	}

	/**
	 * Observe that writing both components is visible on the result.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.MemberAccess
	 * @Inputs none
	 * @Return true when the result equals FVector2D(99.0, 88.0)
	 */
	UFUNCTION()
	bool SetBothNominal()
	{
		return SetBoth().Equals(FVector2D(99.0, 88.0));
	}

	/**
	 * Observe that a default vector reads as zero on every axis.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.MemberAccess
	 * @Inputs a default-constructed vector
	 * @Return true when both components are 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool GetXDefaultEmpty()
	{
		FVector2D Empty = FVector2D();

		if (!Math::IsNearlyEqual(Empty.X, 0.0))
		{
			return false;
		}
		return Math::IsNearlyEqual(Empty.Y, 0.0);
	}

	/**
	 * Observe that mutating a copy leaves the source vector untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.MemberAccess
	 * @Inputs a known vector and a mutated copy of it
	 * @Return true when the source still reads (10.0, 20.0) and the copy reads (100.0, 20.0)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool SetXCopyIndependence()
	{
		FVector2D Original = FVector2D(10.0, 20.0);
		FVector2D Mutated = Original;
		Mutated.X = 100.0;

		if (!Original.Equals(FVector2D(10.0, 20.0)))
		{
			return false;
		}
		return Mutated.Equals(FVector2D(100.0, 20.0));
	}
}
/** @end */
