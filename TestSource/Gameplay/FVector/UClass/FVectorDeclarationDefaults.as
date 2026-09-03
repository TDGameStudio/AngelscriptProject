/**
 * FVector UPROPERTY declaration defaults read off a spawned actor. C++ verifies each
 * vector by path, so the UPROPERTY names are part of the contract and are kept verbatim.
 * The observers cover every declared vector and the independence of two instances.
 *
 * @Theme Gameplay.FVector
 * @Subject FVector.DeclarationDefaults
 * @Harness UClass
 * @Tag Gameplay.FVector.FVectorDeclarationDefaults
 * @Provenance Theme: Gameplay.FVector. WorldStory declaration defaults after spawn.
 * @Provenance C++: AngelscriptCoverageFVectorPropertyTests.cpp::FVectorDeclarationDefaults
 * @Provenance Oracle VerifyByPath: ZeroVec (0,0,0); OneVec (1,1,1); CustomVec (1,2,3);
 * @Provenance NoDefaultVec.X 0; UpVec (0,0,1). Extra: NoDefaultVec empty zero.
 * @Provenance FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class ACoverageFVectorDefaultsActor : AActor
{
	UPROPERTY()
	FVector ZeroVec = FVector::ZeroVector;

	UPROPERTY()
	FVector OneVec = FVector::OneVector;

	UPROPERTY()
	FVector CustomVec = FVector(1, 2, 3);

	UPROPERTY()
	FVector NoDefaultVec;

	UPROPERTY()
	FVector UpVec = FVector::UpVector;

	/**
	 * Observe that the zero-vector default reads as the origin.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationDefaults
	 * @Inputs none
	 * @Return true when all three components of ZeroVec are 0
	 */
	UFUNCTION()
	bool ZeroVecNominal()
	{
		if (ZeroVec.X != 0.0)
		{
			return false;
		}
		if (ZeroVec.Y != 0.0)
		{
			return false;
		}
		return ZeroVec.Z == 0.0;
	}

	/**
	 * Observe that the one-vector default reads as all ones.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationDefaults
	 * @Inputs none
	 * @Return true when all three components of OneVec are 1
	 */
	UFUNCTION()
	bool OneVecNominal()
	{
		if (OneVec.X != 1.0)
		{
			return false;
		}
		if (OneVec.Y != 1.0)
		{
			return false;
		}
		return OneVec.Z == 1.0;
	}

	/**
	 * Observe that a literal default reads back unchanged.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationDefaults
	 * @Inputs none
	 * @Return true when CustomVec reads (1, 2, 3)
	 */
	UFUNCTION()
	bool CustomVecNominal()
	{
		if (CustomVec.X != 1.0)
		{
			return false;
		}
		if (CustomVec.Y != 2.0)
		{
			return false;
		}
		return CustomVec.Z == 3.0;
	}

	/**
	 * Observe that a property declared without an initialiser is empty.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationDefaults
	 * @Inputs none
	 * @Return true when the X component of NoDefaultVec is 0
	 * @Boundary no declared default
	 */
	UFUNCTION()
	bool NoDefaultVecEmptyZero()
	{
		return NoDefaultVec.X == 0.0;
	}

	/**
	 * Observe that the up-vector default reads as the up axis.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationDefaults
	 * @Inputs none
	 * @Return true when UpVec reads (0, 0, 1)
	 */
	UFUNCTION()
	bool UpVecNominal()
	{
		if (UpVec.X != 0.0)
		{
			return false;
		}
		if (UpVec.Y != 0.0)
		{
			return false;
		}
		return UpVec.Z == 1.0;
	}

	/**
	 * Observe that writing one instance leaves another instance's default untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector.DeclarationDefaults
	 * @Inputs a second actor
	 * @Return true when this instance reads 0 and the other still reads 1
	 * @Param Second the other actor, expected to keep its declared default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CustomVecCopyIndependence(ACoverageFVectorDefaultsActor Second)
	{
		if (Second is null)
		{
			throw("FVectorDeclarationDefaults setup: required Second is null");
		}
		CustomVec.X = 0.0;

		if (CustomVec.X != 0.0)
		{
			return false;
		}
		return Second.CustomVec.X == 1.0;
	}
}
