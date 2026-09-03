/**
 * Writing a FLinearColor UPROPERTY and reading it back across a populated value, zero and
 * full white. C++ sets and verifies the value by path, so the UPROPERTY name is part of
 * the contract and is kept verbatim. The observers cover the empty default and the
 * independence of two instances.
 *
 * @Theme Math.FLinearColor
 * @Subject FLinearColor.WriteRoundTrip
 * @Harness UClass
 * @Tag Math.FLinearColor.FLinearColorWriteRoundTrip
 * @Provenance Theme: Gameplay.FLinearColor. WorldStory write round-trip via ColorValue.
 * @Provenance C++: AngelscriptCoverageFLinearColorPropertyTests.cpp::FLinearColorWriteRoundTrip
 * @Provenance Oracle VerifyByPath after SetByPath: ColorValue 0.8,0.6,0.4,0.9 then zero then full 1.
 * @Provenance Extra: default ColorValue (0,0,0,1) before write. FixtureIsolated. Keep UPROPERTY names.
 */

UCLASS()
class ACoverageFLinearColorWriteActor : AActor
{
	UPROPERTY()
	FLinearColor ColorValue;

	/**
	 * Observe that an untouched property is black with alpha 1.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.WriteRoundTrip
	 * @Inputs none
	 * @Return true when ColorValue reads (0, 0, 0, 1)
	 * @Boundary default empty
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ColorValue.R != 0.0)
		{
			return false;
		}
		if (ColorValue.G != 0.0)
		{
			return false;
		}
		if (ColorValue.B != 0.0)
		{
			return false;
		}
		return ColorValue.A == 1.0;
	}

	/**
	 * Observe that a populated write reads back unchanged.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.WriteRoundTrip
	 * @Inputs none
	 * @Return true when ColorValue reads (0.8, 0.6, 0.4, 0.9)
	 */
	UFUNCTION()
	bool WriteRoundTrip()
	{
		ColorValue.R = 0.8;
		ColorValue.G = 0.6;
		ColorValue.B = 0.4;
		ColorValue.A = 0.9;

		if (ColorValue.R != 0.8)
		{
			return false;
		}
		if (ColorValue.G != 0.6)
		{
			return false;
		}
		if (ColorValue.B != 0.4)
		{
			return false;
		}
		return ColorValue.A == 0.9;
	}

	/**
	 * Observe that writing every component to zero lands at zero.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.WriteRoundTrip
	 * @Inputs none
	 * @Return true when R and A read 0
	 * @Boundary zero overwrite
	 */
	UFUNCTION()
	bool WriteZeroBoundary()
	{
		ColorValue.R = 0.0;
		ColorValue.G = 0.0;
		ColorValue.B = 0.0;
		ColorValue.A = 0.0;

		if (ColorValue.R != 0.0)
		{
			return false;
		}
		return ColorValue.A == 0.0;
	}

	/**
	 * Observe that writing every component to one lands R at one.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.WriteRoundTrip
	 * @Inputs none
	 * @Return true when R reads 1
	 */
	UFUNCTION()
	bool WriteFull()
	{
		ColorValue.R = 1.0;
		ColorValue.G = 1.0;
		ColorValue.B = 1.0;
		ColorValue.A = 1.0;
		return ColorValue.R == 1.0;
	}

	/**
	 * Observe that writing one instance leaves another instance empty.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.WriteRoundTrip
	 * @Inputs a second actor
	 * @Return true when this instance reads 0.8 and the other still reads 0
	 * @Param Second the other actor, expected to stay empty
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(ACoverageFLinearColorWriteActor Second)
	{
		if (Second is null)
		{
			throw("FLinearColorWriteRoundTrip setup: required Second is null");
		}
		ColorValue.R = 0.8;

		if (ColorValue.R != 0.8)
		{
			return false;
		}
		return Second.ColorValue.R == 0.0;
	}
}
