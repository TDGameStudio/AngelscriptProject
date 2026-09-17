/**
 * @version v1
 * @summary The FLinearColor construction paths: the default constructor, the four-parameter constructor, the three-parameter constructor, and the named color constants. C++ executes each entrypoint and compares the result with the.
 * @topic Math
 */
/**
 * @version root
 * @summary The FLinearColor construction paths: the default constructor, the four-parameter constructor, the three-parameter constructor, and the named color constants. C++ executes each entrypoint and compares the result with the.
 * @topic Baseline
 */
namespace FLinearColorTest
{
	/**
	 * Construct a color with no arguments.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Construction
	 * @Inputs none
	 * @Return FLinearColor(), which should be (0, 0, 0, 1)
	 * @Boundary default constructor
	 */
	UFUNCTION()
	FLinearColor ConstructDefault()
	{
		return FLinearColor();
	}

	/**
	 * Construct a color from four components.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Construction
	 * @Inputs none
	 * @Return FLinearColor(0.5, 0.6, 0.7, 0.8)
	 */
	UFUNCTION()
	FLinearColor ConstructFourParams()
	{
		return FLinearColor(0.5, 0.6, 0.7, 0.8);
	}

	/**
	 * Construct a color from three components, leaving alpha at 1.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Construction
	 * @Inputs none
	 * @Return FLinearColor(0.2, 0.4, 0.6)
	 */
	UFUNCTION()
	FLinearColor ConstructThreeParams()
	{
		return FLinearColor(0.2, 0.4, 0.6);
	}

	/**
	 * Read the white constant.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Construction
	 * @Inputs none
	 * @Return FLinearColor::White
	 */
	UFUNCTION()
	FLinearColor ConstructWhite()
	{
		return FLinearColor::White;
	}

	/**
	 * Read the black constant.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Construction
	 * @Inputs none
	 * @Return FLinearColor::Black
	 */
	UFUNCTION()
	FLinearColor ConstructBlack()
	{
		return FLinearColor::Black;
	}

	/**
	 * Read the red constant.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Construction
	 * @Inputs none
	 * @Return FLinearColor::Red
	 */
	UFUNCTION()
	FLinearColor ConstructRed()
	{
		return FLinearColor::Red;
	}

	/**
	 * Read the green constant.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Construction
	 * @Inputs none
	 * @Return FLinearColor::Green
	 */
	UFUNCTION()
	FLinearColor ConstructGreen()
	{
		return FLinearColor::Green;
	}

	/**
	 * Read the blue constant.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Construction
	 * @Inputs none
	 * @Return FLinearColor::Blue
	 */
	UFUNCTION()
	FLinearColor ConstructBlue()
	{
		return FLinearColor::Blue;
	}

	/**
	 * Read the yellow constant.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Construction
	 * @Inputs none
	 * @Return FLinearColor::Yellow
	 */
	UFUNCTION()
	FLinearColor ConstructYellow()
	{
		return FLinearColor::Yellow;
	}

	/**
	 * Observe that the default constructor yields (0, 0, 0, 1).
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Construction
	 * @Inputs none
	 * @Return true when the result equals (0, 0, 0, 1)
	 */
	UFUNCTION()
	bool ConstructDefaultNominal()
	{
		return ConstructDefault().Equals(FLinearColor(0.0, 0.0, 0.0, 1.0));
	}

	/**
	 * Observe that the four-parameter constructor keeps its components.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Construction
	 * @Inputs none
	 * @Return true when the result equals (0.5, 0.6, 0.7, 0.8)
	 */
	UFUNCTION()
	bool ConstructFourParamsNominal()
	{
		return ConstructFourParams().Equals(FLinearColor(0.5, 0.6, 0.7, 0.8));
	}

	/**
	 * Observe that the three-parameter constructor fills alpha with 1.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Construction
	 * @Inputs none
	 * @Return true when the result equals (0.2, 0.4, 0.6, 1.0)
	 */
	UFUNCTION()
	bool ConstructThreeParamsNominal()
	{
		return ConstructThreeParams().Equals(FLinearColor(0.2, 0.4, 0.6, 1.0));
	}

	/**
	 * Observe that each named constant matches itself.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Construction
	 * @Inputs none
	 * @Return true when white, black, red, green, blue and yellow all match
	 */
	UFUNCTION()
	bool ConstructNamedColors()
	{
		if (!ConstructWhite().Equals(FLinearColor::White))
		{
			return false;
		}
		if (!ConstructBlack().Equals(FLinearColor::Black))
		{
			return false;
		}
		if (!ConstructRed().Equals(FLinearColor::Red))
		{
			return false;
		}
		if (!ConstructGreen().Equals(FLinearColor::Green))
		{
			return false;
		}
		if (!ConstructBlue().Equals(FLinearColor::Blue))
		{
			return false;
		}
		return ConstructYellow().Equals(FLinearColor::Yellow);
	}

	/**
	 * Observe that mutating a copy leaves the four-parameter result untouched.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.Construction
	 * @Inputs the four-parameter result and a mutated copy of it
	 * @Return true when the original still equals (0.5, 0.6, 0.7, 0.8) and the copy reads 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ConstructFourParamsCopyIndependence()
	{
		FLinearColor Original = ConstructFourParams();
		FLinearColor Copy = Original;
		Copy.R = 0.0;

		if (!Original.Equals(FLinearColor(0.5, 0.6, 0.7, 0.8)))
		{
			return false;
		}
		return Copy.R == 0.0;
	}
}
/** @end */
