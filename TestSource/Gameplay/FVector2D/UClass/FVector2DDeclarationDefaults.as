/**
 * FVector2D UPROPERTY declaration defaults read off a spawned actor. C++ verifies each
 * vector by path, so the UPROPERTY names are part of the contract and are kept verbatim.
 * The observers cover every declared vector and the independence of two instances.
 *
 * @Theme Gameplay.FVector2D
 * @Subject FVector2D.DeclarationDefaults
 * @Harness UClass
 * @Tag Gameplay.FVector2D.FVector2DDeclarationDefaults
 * @Provenance Theme: Gameplay.FVector2D. WorldStory declaration defaults after spawn.
 * @Provenance C++: AngelscriptCoverageFVector2DPropertyTests.cpp::FVector2DDeclarationDefaults
 * @Provenance Oracle VerifyByPath: ZeroVec (0,0); OneVec (1,1); CustomVec (5,10);
 * @Provenance NoDefaultVec (0,0); UnitXVec (1,0). Extra: NoDefaultVec empty zero.
 * @Provenance FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class ACoverageFVector2DDefaultsActor : AActor
{
	UPROPERTY()
	FVector2D ZeroVec = FVector2D::ZeroVector;

	UPROPERTY()
	FVector2D OneVec = FVector2D(1, 1);

	UPROPERTY()
	FVector2D CustomVec = FVector2D(5, 10);

	UPROPERTY()
	FVector2D NoDefaultVec;

	UPROPERTY()
	FVector2D UnitXVec = FVector2D(1, 0);

	/**
	 * Observe that the zero-vector default reads as the origin.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.DeclarationDefaults
	 * @Inputs none
	 * @Return true when both components of ZeroVec are 0
	 */
	UFUNCTION()
	bool ZeroVecNominal()
	{
		if (ZeroVec.X != 0.0)
		{
			return false;
		}
		return ZeroVec.Y == 0.0;
	}

	/**
	 * Observe that the one-vector default reads as all ones.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.DeclarationDefaults
	 * @Inputs none
	 * @Return true when both components of OneVec are 1
	 */
	UFUNCTION()
	bool OneVecNominal()
	{
		if (OneVec.X != 1.0)
		{
			return false;
		}
		return OneVec.Y == 1.0;
	}

	/**
	 * Observe that a literal default reads back unchanged.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.DeclarationDefaults
	 * @Inputs none
	 * @Return true when CustomVec reads (5, 10)
	 */
	UFUNCTION()
	bool CustomVecNominal()
	{
		if (CustomVec.X != 5.0)
		{
			return false;
		}
		return CustomVec.Y == 10.0;
	}

	/**
	 * Observe that a property declared without an initialiser is empty.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.DeclarationDefaults
	 * @Inputs none
	 * @Return true when both components of NoDefaultVec are 0
	 * @Boundary no declared default
	 */
	UFUNCTION()
	bool NoDefaultVecEmptyZero()
	{
		if (NoDefaultVec.X != 0.0)
		{
			return false;
		}
		return NoDefaultVec.Y == 0.0;
	}

	/**
	 * Observe that the unit-X default reads as the X axis.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.DeclarationDefaults
	 * @Inputs none
	 * @Return true when UnitXVec reads (1, 0)
	 */
	UFUNCTION()
	bool UnitXVecNominal()
	{
		if (UnitXVec.X != 1.0)
		{
			return false;
		}
		return UnitXVec.Y == 0.0;
	}

	/**
	 * Observe that writing one instance leaves another instance's default untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.DeclarationDefaults
	 * @Inputs a second actor
	 * @Return true when this instance reads 0 and the other still reads 5
	 * @Param Second the other actor, expected to keep its declared default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CustomVecCopyIndependence(ACoverageFVector2DDefaultsActor Second)
	{
		if (Second is null)
		{
			throw("FVector2DDeclarationDefaults setup: required Second is null");
		}
		CustomVec.X = 0.0;

		if (CustomVec.X != 0.0)
		{
			return false;
		}
		return Second.CustomVec.X == 5.0;
	}
}
