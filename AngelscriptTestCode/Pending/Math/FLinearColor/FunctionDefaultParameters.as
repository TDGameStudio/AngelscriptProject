/**
 * @version v1
 * @summary A defaulted FLinearColor parameter, exercised both with and without the caller supplying it. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim.
 * @topic Math
 */
/**
 * @version root
 * @summary A defaulted FLinearColor parameter, exercised both with and without the caller supplying it. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim.
 * @topic Baseline
 */
namespace FLinearColorTest
{
	/**
	 * Blend two colors, where the second defaults to black.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionDefaultParameters
	 * @Inputs a color and an optional second color
	 * @Return the 50/50 blend of the two
	 * @Param a the first color
	 * @Param b the second color, defaulting to black
	 */
	UFUNCTION()
	FLinearColor BlendWithDefault(FLinearColor a, FLinearColor b = FLinearColor::Black)
	{
		return a * 0.5 + b * 0.5;
	}

	/**
	 * Blend a color relying on the parameter default.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionDefaultParameters
	 * @Inputs a color
	 * @Return the color blended with black
	 * @Param a the color to blend
	 */
	UFUNCTION()
	FLinearColor BlendWithImplicitDefault(FLinearColor a)
	{
		return BlendWithDefault(a);
	}

	/**
	 * Observe that an explicitly supplied second argument is used.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when the blend keeps both red and blue above 0.4
	 */
	UFUNCTION()
	bool BlendWithDefaultExplicit()
	{
		FLinearColor Result = BlendWithDefault(FLinearColor::Red, FLinearColor::Blue);

		if (Result.R <= 0.4)
		{
			return false;
		}
		return Result.B > 0.4;
	}

	/**
	 * Observe that the parameter default is applied when the caller omits it.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when white blended with black lands in (0.4, 0.6) on R
	 */
	UFUNCTION()
	bool BlendWithImplicitDefaultWhite()
	{
		FLinearColor Result = BlendWithImplicitDefault(FLinearColor::White);

		if (Result.R <= 0.4)
		{
			return false;
		}
		return Result.R < 0.6;
	}

	/**
	 * Observe that blending a default color with the black default stays at black with
	 * alpha 1.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionDefaultParameters
	 * @Inputs a default-constructed color
	 * @Return true when the blend equals (0, 0, 0, 1)
	 * @Boundary default value
	 */
	UFUNCTION()
	bool BlendWithDefaultDefaultEmpty()
	{
		FLinearColor Result = BlendWithDefault(FLinearColor());
		return Result.Equals(FLinearColor(0.0, 0.0, 0.0, 1.0), 0.001);
	}

	/**
	 * Observe that mutating the returned blend leaves the caller's argument alone.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionDefaultParameters
	 * @Inputs a color and the mutated blend built from it
	 * @Return true when the argument still reads white
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool BlendWithImplicitDefaultCopyIndependence()
	{
		FLinearColor Input = FLinearColor::White;
		FLinearColor Result = BlendWithImplicitDefault(Input);
		Result.R = 0.0;
		return Input.Equals(FLinearColor::White);
	}
}
/** @end */
