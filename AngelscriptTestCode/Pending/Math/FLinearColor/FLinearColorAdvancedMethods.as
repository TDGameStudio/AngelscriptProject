/**
 * @version v1
 * @summary The advanced FLinearColor methods: clamp, tolerant equality, almost-black, min and max components, HSV round-trip, hex construction, construction from FColor, and ReinterpretAsLinear. C++ executes each entrypoint and.
 * @topic Math
 */
/**
 * @version root
 * @summary The advanced FLinearColor methods: clamp, tolerant equality, almost-black, min and max components, HSV round-trip, hex construction, construction from FColor, and ReinterpretAsLinear. C++ executes each entrypoint and.
 * @topic Baseline
 */
namespace FLinearColorTest
{
	/**
	 * Clamp a color into the unit range.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return FLinearColor(0.0, 0.25, 1.0, 1.0)
	 */
	UFUNCTION()
	FLinearColor ClampColor()
	{
		FLinearColor c = FLinearColor(-0.5, 0.25, 1.5, 2.0);
		return c.GetClamped(0.0, 1.0);
	}

	/**
	 * Compare two nearby colors with a 0.01 tolerance.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool EqualsWithinTolerance()
	{
		FLinearColor a = FLinearColor(0.2, 0.4, 0.6, 1.0);
		FLinearColor b = FLinearColor(0.201, 0.399, 0.6, 1.0);
		return a.Equals(b, 0.01);
	}

	/**
	 * Ask whether a black color with alpha 1 is almost black.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return true
	 */
	UFUNCTION()
	bool AlmostBlack()
	{
		FLinearColor c = FLinearColor(0.0, 0.0, 0.0, 1.0);
		return c.IsAlmostBlack();
	}

	/**
	 * Read the smallest RGB component.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return 0.2
	 */
	UFUNCTION()
	float MinComponent()
	{
		FLinearColor c = FLinearColor(0.6, 0.2, 0.9, 0.4);
		return c.GetMin();
	}

	/**
	 * Read the largest RGB component.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return 0.9
	 */
	UFUNCTION()
	float MaxComponent()
	{
		FLinearColor c = FLinearColor(0.6, 0.2, 0.9, 0.4);
		return c.GetMax();
	}

	/**
	 * Convert a color to HSV and back.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return FLinearColor(0.25, 0.5, 0.75, 1.0)
	 */
	UFUNCTION()
	FLinearColor RoundTripHSV()
	{
		FLinearColor c = FLinearColor(0.25, 0.5, 0.75, 1.0);
		return c.LinearRGBToHSV().HSVToLinearRGB();
	}

	/**
	 * Build an opaque white from an sRGB hex value.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return an opaque white color
	 */
	UFUNCTION()
	FLinearColor MakeHexSRGB()
	{
		return FLinearColor::MakeFromHex(0xFFFFFFFF, true);
	}

	/**
	 * Build an opaque white from a linear hex value.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return an opaque white color
	 */
	UFUNCTION()
	FLinearColor MakeHexLinear()
	{
		return FLinearColor::MakeFromHex(0xFFFFFFFF, false);
	}

	/**
	 * Construct a linear color from an opaque red FColor.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return an opaque red linear color
	 */
	UFUNCTION()
	FLinearColor ConstructFromFColor()
	{
		FColor c = FColor(255, 0, 0, 255);
		return FLinearColor(c);
	}

	/**
	 * Reinterpret an opaque green FColor as linear.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return an opaque green linear color
	 */
	UFUNCTION()
	FLinearColor ReinterpretFromFColor()
	{
		FColor c = FColor(0, 255, 0, 255);
		return c.ReinterpretAsLinear();
	}

	/**
	 * Observe that clamp lands every component in [0, 1].
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return true when the result equals (0, 0.25, 1, 1)
	 */
	UFUNCTION()
	bool ClampColorNominal()
	{
		return ClampColor().Equals(FLinearColor(0.0, 0.25, 1.0, 1.0));
	}

	/**
	 * Observe that nearby colors compare equal within 0.01.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return true when the entrypoint returned true
	 */
	UFUNCTION()
	bool EqualsWithinToleranceNominal()
	{
		return EqualsWithinTolerance();
	}

	/**
	 * Observe that black with alpha 1 reports itself as almost black.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return true when the flag is set
	 */
	UFUNCTION()
	bool AlmostBlackNominal()
	{
		return AlmostBlack();
	}

	/**
	 * Observe that the smallest component is 0.2.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return true when the min is 0.2
	 */
	UFUNCTION()
	bool MinComponentNominal()
	{
		return MinComponent() == 0.2;
	}

	/**
	 * Observe that the largest component is 0.9.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return true when the max is 0.9
	 */
	UFUNCTION()
	bool MaxComponentNominal()
	{
		return MaxComponent() == 0.9;
	}

	/**
	 * Observe that HSV conversion round-trips within 0.01.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return true when the result equals (0.25, 0.5, 0.75, 1.0)
	 */
	UFUNCTION()
	bool RoundTripHSVNominal()
	{
		return RoundTripHSV().Equals(FLinearColor(0.25, 0.5, 0.75, 1.0), 0.01);
	}

	/**
	 * Observe that sRGB hex 0xFFFFFFFF is opaque white.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return true when every component is greater than 0.99
	 */
	UFUNCTION()
	bool MakeHexSRGBOpaqueWhite()
	{
		FLinearColor Result = MakeHexSRGB();

		if (Result.R <= 0.99)
		{
			return false;
		}
		if (Result.G <= 0.99)
		{
			return false;
		}
		if (Result.B <= 0.99)
		{
			return false;
		}
		return Result.A > 0.99;
	}

	/**
	 * Observe that linear hex 0xFFFFFFFF is opaque white.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return true when every component is greater than 0.99
	 */
	UFUNCTION()
	bool MakeHexLinearOpaqueWhite()
	{
		FLinearColor Result = MakeHexLinear();

		if (Result.R <= 0.99)
		{
			return false;
		}
		if (Result.G <= 0.99)
		{
			return false;
		}
		if (Result.B <= 0.99)
		{
			return false;
		}
		return Result.A > 0.99;
	}

	/**
	 * Observe that an opaque red FColor becomes an opaque red linear color.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return true when R and A are above 0.99 and G and B are below 0.01
	 */
	UFUNCTION()
	bool ConstructFromFColorOpaqueRed()
	{
		FLinearColor Result = ConstructFromFColor();

		if (Result.R <= 0.99)
		{
			return false;
		}
		if (Result.G >= 0.01)
		{
			return false;
		}
		if (Result.B >= 0.01)
		{
			return false;
		}
		return Result.A > 0.99;
	}

	/**
	 * Observe that reinterpreting opaque green keeps G high and R/B low.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs none
	 * @Return true when G and A are above 0.99 and R and B are below 0.01
	 */
	UFUNCTION()
	bool ReinterpretFromFColorOpaqueGreen()
	{
		FLinearColor Result = ReinterpretFromFColor();

		if (Result.G <= 0.99)
		{
			return false;
		}
		if (Result.R >= 0.01)
		{
			return false;
		}
		if (Result.B >= 0.01)
		{
			return false;
		}
		return Result.A > 0.99;
	}

	/**
	 * Observe that a default color reports itself as almost black.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs a default-constructed color
	 * @Return true when the flag is set
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AlmostBlackDefaultEmpty()
	{
		return FLinearColor().IsAlmostBlack();
	}

	/**
	 * Observe that clamping takes a copy, leaving the source color alone.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.AdvancedMethods
	 * @Inputs a color and its mutated clamped copy
	 * @Return true when the source still reads R -0.5 and A 2.0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ClampColorCopyIndependence()
	{
		FLinearColor Source = FLinearColor(-0.5, 0.25, 1.5, 2.0);
		FLinearColor Clamped = Source.GetClamped(0.0, 1.0);
		Clamped.R = 1.0;

		if (Source.R != -0.5)
		{
			return false;
		}
		return Source.A == 2.0;
	}
}
/** @end */
