/**
 * FLinearColor UPROPERTY declaration defaults read off a spawned actor. C++ verifies each
 * color by path, so the UPROPERTY names are part of the contract and are kept verbatim.
 * The observers cover every declared color and the independence of two instances.
 *
 * @Theme Gameplay.FLinearColor
 * @Subject FLinearColor.DeclarationDefaults
 * @Harness UClass
 * @Tag Gameplay.FLinearColor.FLinearColorDeclarationDefaults
 * @Provenance Theme: Gameplay.FLinearColor. WorldStory UPROPERTY declaration defaults.
 * @Provenance C++: AngelscriptCoverageFLinearColorPropertyTests.cpp::FLinearColorDeclarationDefaults
 * @Provenance Oracle VerifyByPath: White 1,1,1,1; Red 1,0,0; Black 0,0,0; Custom 0.5,0.25,0.75,1;
 * @Provenance NoDefault R 0 A 1; Blue B 1.
 * @Provenance Extra: default NoDefault G/B 0. FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class ACoverageFLinearColorDefaultsActor : AActor
{
	UPROPERTY()
	FLinearColor WhiteColor = FLinearColor::White;

	UPROPERTY()
	FLinearColor RedColor = FLinearColor::Red;

	UPROPERTY()
	FLinearColor BlackColor = FLinearColor::Black;

	UPROPERTY()
	FLinearColor CustomColor = FLinearColor(0.5, 0.25, 0.75, 1.0);

	UPROPERTY()
	FLinearColor NoDefaultColor;

	UPROPERTY()
	FLinearColor BlueColor = FLinearColor::Blue;

	/**
	 * Observe that the white default reads as opaque white.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.DeclarationDefaults
	 * @Inputs none
	 * @Return true when WhiteColor reads (1, 1, 1, 1)
	 */
	UFUNCTION()
	bool WhiteColorNominal()
	{
		if (WhiteColor.R != 1.0)
		{
			return false;
		}
		if (WhiteColor.G != 1.0)
		{
			return false;
		}
		if (WhiteColor.B != 1.0)
		{
			return false;
		}
		return WhiteColor.A == 1.0;
	}

	/**
	 * Observe that the red default reads as opaque red.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.DeclarationDefaults
	 * @Inputs none
	 * @Return true when RedColor reads (1, 0, 0)
	 */
	UFUNCTION()
	bool RedColorNominal()
	{
		if (RedColor.R != 1.0)
		{
			return false;
		}
		if (RedColor.G != 0.0)
		{
			return false;
		}
		return RedColor.B == 0.0;
	}

	/**
	 * Observe that the black default reads as black.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.DeclarationDefaults
	 * @Inputs none
	 * @Return true when BlackColor reads (0, 0, 0)
	 */
	UFUNCTION()
	bool BlackColorNominal()
	{
		if (BlackColor.R != 0.0)
		{
			return false;
		}
		if (BlackColor.G != 0.0)
		{
			return false;
		}
		return BlackColor.B == 0.0;
	}

	/**
	 * Observe that a literal default reads back unchanged.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.DeclarationDefaults
	 * @Inputs none
	 * @Return true when CustomColor reads (0.5, 0.25, 0.75, 1)
	 */
	UFUNCTION()
	bool CustomColorNominal()
	{
		if (CustomColor.R != 0.5)
		{
			return false;
		}
		if (CustomColor.G != 0.25)
		{
			return false;
		}
		if (CustomColor.B != 0.75)
		{
			return false;
		}
		return CustomColor.A == 1.0;
	}

	/**
	 * Observe that a property declared without an initialiser is black with alpha 1.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.DeclarationDefaults
	 * @Inputs none
	 * @Return true when R is 0 and A is 1
	 * @Boundary no declared default
	 */
	UFUNCTION()
	bool NoDefaultColorEmpty()
	{
		if (NoDefaultColor.R != 0.0)
		{
			return false;
		}
		return NoDefaultColor.A == 1.0;
	}

	/**
	 * Observe that the blue default reads as blue.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.DeclarationDefaults
	 * @Inputs none
	 * @Return true when B is 1
	 */
	UFUNCTION()
	bool BlueColorNominal()
	{
		return BlueColor.B == 1.0;
	}

	/**
	 * Observe that a property declared without an initialiser has empty G and B.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.DeclarationDefaults
	 * @Inputs none
	 * @Return true when G and B are 0
	 * @Boundary no declared default
	 */
	UFUNCTION()
	bool NoDefaultColorEmptyGB()
	{
		if (NoDefaultColor.G != 0.0)
		{
			return false;
		}
		return NoDefaultColor.B == 0.0;
	}

	/**
	 * Observe that writing one instance leaves another instance's default untouched.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.DeclarationDefaults
	 * @Inputs a second actor
	 * @Return true when this instance reads 0 and the other still reads 0.5
	 * @Param Second the other actor, expected to keep its declared default
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CustomColorCopyIndependence(ACoverageFLinearColorDefaultsActor Second)
	{
		if (Second is null)
		{
			throw("FLinearColorDeclarationDefaults setup: required Second is null");
		}
		CustomColor.R = 0.0;

		if (CustomColor.R != 0.0)
		{
			return false;
		}
		return Second.CustomColor.R == 0.5;
	}
}
