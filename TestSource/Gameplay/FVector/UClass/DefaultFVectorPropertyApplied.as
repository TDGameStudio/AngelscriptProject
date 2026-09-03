/**
 * A default-specifier FVector property, verified through the entrypoint C++ calls. The
 * default is applied by the compiler rather than by a constructor, so reading the
 * property back is what confirms it landed. Mismatch codes name which component failed.
 *
 * @Theme Gameplay.FVector
 * @Subject FVector.DefaultFVectorPropertyApplied
 * @Harness UClass
 * @Tag Gameplay.FVector.DefaultFVectorPropertyApplied
 * @Provenance Theme: Gameplay.FVector. Positive default-specifier FVector property oracle.
 * @Provenance C++: AngelscriptCompilerPropertyDefaultMatrixTests.cpp::DefaultFVectorPropertyApplied
 * @Provenance Oracle: VerifyVector == 42 after default MyVector = FVector(1.0f, 2.0f, 3.0f).
 * @Provenance Mismatch codes: X 1, Y 2, Z 3. Extra: empty FVector() is (0,0,0) and would
 * @Provenance return 1 from the X check. DefaultSafe.
 */

UCLASS()
class UDefaultVectorCarrier : UObject
{
	UPROPERTY()
	FVector MyVector;

	default MyVector = FVector(1.0f, 2.0f, 3.0f);

	/**
	 * Check each component against the applied default, naming the first one that missed.
	 *
	 * @Kind Observe
	 * @Covers FVector.DefaultFVectorPropertyApplied
	 * @Inputs none
	 * @Return 42 when all three match; 1, 2 or 3 naming the component that did not
	 */
	UFUNCTION()
	int VerifyVector()
	{
		if (MyVector.X < 0.9f || MyVector.X > 1.1f)
			return 1;
		if (MyVector.Y < 1.9f || MyVector.Y > 2.1f)
			return 2;
		if (MyVector.Z < 2.9f || MyVector.Z > 3.1f)
			return 3;
		return 42;
	}

	/**
	 * Observe that the applied default satisfies every component check.
	 *
	 * @Kind Observe
	 * @Covers FVector.DefaultFVectorPropertyApplied
	 * @Inputs none
	 * @Return true when the entrypoint returned 42
	 */
	UFUNCTION()
	bool VerifyVectorNominal()
	{
		return VerifyVector() == 42;
	}

	/**
	 * Observe that an empty vector would fail the X check, which is what makes the
	 * default observable.
	 *
	 * @Kind Observe
	 * @Covers FVector.DefaultFVectorPropertyApplied
	 * @Inputs a default-constructed vector
	 * @Return 1 when the X check rejects it, otherwise 0
	 * @Boundary empty vector
	 */
	UFUNCTION()
	int EmptyWouldReturnXMismatch()
	{
		FVector Empty = FVector();
		if (Empty.X < 0.9f || Empty.X > 1.1f)
		{
			return 1;
		}
		return 0;
	}

	/**
	 * Observe that zeroing one carrier leaves another carrier's default intact.
	 *
	 * @Kind Observe
	 * @Covers FVector.DefaultFVectorPropertyApplied
	 * @Inputs a second carrier
	 * @Return true when this one reports the X mismatch and the other still reports 42
	 * @Param Second the other carrier, expected to keep its applied default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UDefaultVectorCarrier Second)
	{
		if (Second is null)
		{
			throw("DefaultFVectorPropertyApplied setup: required Second is null");
		}
		MyVector = FVector::ZeroVector;

		if (VerifyVector() != 1)
		{
			return false;
		}
		return Second.VerifyVector() == 42;
	}
}
