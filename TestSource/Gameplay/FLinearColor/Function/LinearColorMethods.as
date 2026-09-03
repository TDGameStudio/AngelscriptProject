/**
 * The FLinearColor conversion, luminance and HSV lerp methods. C++ executes each
 * entrypoint and compares the result with the native equivalent, so those names are part
 * of the contract and are kept verbatim. The observers cover default black luminance and
 * the independence of the lerp inputs.
 *
 * @Theme Gameplay.FLinearColor
 * @Subject FLinearColor.Methods
 * @Harness Function
 * @Tag Gameplay.FLinearColor.LinearColorMethods
 * @Namespace FLinearColorTest
 * @Provenance Theme: Gameplay.FLinearColor. Positive ToFColor / luminance / HSV lerp oracles.
 * @Provenance C++: AngelscriptCoverageFLinearColorExpressionTests.cpp::LinearColorMethods
 * @Provenance Oracle: ToFColor(true) White RGBA 255; ToFColor(false) R 255; GetLuminance White > 0.9;
 * @Provenance LerpUsingHSV(Black, White, 0.5) R in (0,1).
 * @Provenance Extra: default Black luminance 0; lerp inputs copy-independent. DefaultSafe.
 */

namespace FLinearColorTest
{
	/**
	 * Convert white to an sRGB FColor.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Methods
	 * @Inputs none
	 * @Return FColor(255, 255, 255, 255)
	 */
	UFUNCTION()
	FColor ToFColorSRGB()
	{
		FLinearColor c = FLinearColor::White;
		return c.ToFColor(true);
	}

	/**
	 * Convert a linear color to an FColor without sRGB conversion.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Methods
	 * @Inputs none
	 * @Return an FColor whose R component is 255
	 */
	UFUNCTION()
	FColor ToFColorLinear()
	{
		FLinearColor c = FLinearColor(1.0, 0.5, 0.0, 1.0);
		return c.ToFColor(false);
	}

	/**
	 * Measure the luminance of white.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Methods
	 * @Inputs none
	 * @Return a luminance greater than 0.9
	 */
	UFUNCTION()
	float GetLuminance()
	{
		FLinearColor c = FLinearColor::White;
		return c.GetLuminance();
	}

	/**
	 * Interpolate from black to white in HSV space.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Methods
	 * @Inputs none
	 * @Return a color whose R lies strictly between 0 and 1
	 */
	UFUNCTION()
	FLinearColor LerpColors()
	{
		FLinearColor a = FLinearColor::Black;
		FLinearColor b = FLinearColor::White;
		return FLinearColor::LerpUsingHSV(a, b, 0.5);
	}

	/**
	 * Observe that sRGB conversion of white is opaque white.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Methods
	 * @Inputs none
	 * @Return true when every FColor channel is 255
	 */
	UFUNCTION()
	bool ToFColorSRGBNominal()
	{
		FColor Result = ToFColorSRGB();

		if (Result.R != 255)
		{
			return false;
		}
		if (Result.G != 255)
		{
			return false;
		}
		if (Result.B != 255)
		{
			return false;
		}
		return Result.A == 255;
	}

	/**
	 * Observe that the linear conversion keeps R at 255.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Methods
	 * @Inputs none
	 * @Return true when R is 255
	 */
	UFUNCTION()
	bool ToFColorLinearR()
	{
		FColor Result = ToFColorLinear();
		return Result.R == 255;
	}

	/**
	 * Observe that white measures as a high luminance.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Methods
	 * @Inputs none
	 * @Return true when the luminance is greater than 0.9
	 */
	UFUNCTION()
	bool GetLuminanceWhite()
	{
		return GetLuminance() > 0.9;
	}

	/**
	 * Observe that HSV lerp lands strictly between black and white.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Methods
	 * @Inputs none
	 * @Return true when R is greater than 0 and less than 1
	 */
	UFUNCTION()
	bool LerpColorsIntermediate()
	{
		FLinearColor Result = LerpColors();

		if (Result.R <= 0.0)
		{
			return false;
		}
		return Result.R < 1.0;
	}

	/**
	 * Observe that a default color measures zero luminance.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Methods
	 * @Inputs a default-constructed color
	 * @Return true when the luminance is 0
	 * @Boundary default black
	 */
	UFUNCTION()
	bool GetLuminanceDefaultBlack()
	{
		FLinearColor Empty = FLinearColor();
		return Empty.GetLuminance() == 0.0;
	}

	/**
	 * Observe that HSV lerp takes copies, leaving the inputs alone.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Methods
	 * @Inputs black, white and a mutated midpoint
	 * @Return true when both inputs still read black and white
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool LerpColorsCopyIndependence()
	{
		FLinearColor A = FLinearColor::Black;
		FLinearColor B = FLinearColor::White;
		FLinearColor Mid = FLinearColor::LerpUsingHSV(A, B, 0.5);
		Mid.R = 0.0;

		if (!A.Equals(FLinearColor::Black))
		{
			return false;
		}
		return B.Equals(FLinearColor::White);
	}
}
