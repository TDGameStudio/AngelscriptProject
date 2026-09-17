/**
 * @version v1
 * @summary FLinearColor mix, luminance, out, clamp, and packed convert. MixColors of Red and Blue has R>0.4 and B>0.4. White luminance is >0.9. WriteOut writes Yellow. Clamp of (-0.25,0.5,1.5,2) is (0,0.5,1,1). MixColors of Black.
 * @topic Definitions
 */
/**
 * @version root
 * @summary FLinearColor mix, luminance, out, clamp, and packed convert. MixColors of Red and Blue has R>0.4 and B>0.4. White luminance is >0.9. WriteOut writes Yellow. Clamp of (-0.25,0.5,1.5,2) is (0,0.5,1,1). MixColors of Black.
 * @topic Baseline
 */
UCLASS()
class ACoverageFLinearColorFunctionActor : AActor
{
	/**
	 * Mix two colors at 0.5 each.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param a First color
	 * @Param b Second color
	 * @Inputs a and b
	 * @Return a * 0.5 + b * 0.5
	 */
	UFUNCTION()
	FLinearColor MixColors(FLinearColor a, FLinearColor b)
	{
		return a * 0.5 + b * 0.5;
	}

	/**
	 * Read luminance of a color.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param c Color whose luminance is read
	 * @Inputs c
	 * @Return c.GetLuminance()
	 */
	UFUNCTION()
	float GetColorLuminance(FLinearColor c)
	{
		return c.GetLuminance();
	}

	/**
	 * Write Yellow to an out color.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param result Destination received as FLinearColor&out
	 * @Inputs an empty out color
	 * @Return void; result becomes Yellow
	 */
	UFUNCTION()
	void WriteOut(FLinearColor&out result)
	{
		result = FLinearColor::Yellow;
	}

	/**
	 * Clamp a color to 0..1.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param color Color to clamp
	 * @Inputs color
	 * @Return color.GetClamped(0.0, 1.0)
	 */
	UFUNCTION()
	FLinearColor ClampInput(FLinearColor color)
	{
		FLinearColor MutableColor = color;
		return MutableColor.GetClamped(0.0, 1.0);
	}

	/**
	 * Convert a packed FColor to FLinearColor.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param color Packed color
	 * @Inputs color
	 * @Return FLinearColor(color)
	 */
	UFUNCTION()
	FLinearColor ConvertPacked(FColor color)
	{
		return FLinearColor(color);
	}

	/**
	 * Observe MixColors of Red and Blue.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs MixColors(Red, Blue)
	 * @Return true when R>0.4 and B>0.4
	 */
	UFUNCTION()
	bool MixRedBlue()
	{
		FLinearColor Mixed = MixColors(FLinearColor::Red, FLinearColor::Blue);
		if (Mixed.R <= 0.4)
		{
			return false;
		}
		return Mixed.B > 0.4;
	}

	/**
	 * Observe MixColors of Black as the empty mix.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs MixColors(Black, Black)
	 * @Return true when the mix equals Black
	 * @Boundary black
	 */
	UFUNCTION()
	bool MixBlackEmpty()
	{
		FLinearColor Mixed = MixColors(FLinearColor::Black, FLinearColor::Black);
		return Mixed.Equals(FLinearColor::Black, 0.001);
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ACoverageFLinearColorFunctionActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageFLinearColorFunctionActor Actor = nullptr;
		return Actor == nullptr;
	}

	/**
	 * Observe WriteOut, ClampInput, ConvertPacked, and White luminance.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs WriteOut, ClampInput of (-0.25,0.5,1.5,2), ConvertPacked red, White luminance
	 * @Return true when Yellow, clamped (0,0.5,1,1), packed red, and luminance >0.9 hold
	 */
	UFUNCTION()
	bool ClampAndOutBoundary()
	{
		FLinearColor OutValue = FLinearColor::Black;
		WriteOut(OutValue);
		FLinearColor Clamped = ClampInput(FLinearColor(-0.25, 0.5, 1.5, 2.0));
		FLinearColor Packed = ConvertPacked(FColor(255, 0, 0, 255));
		if (!OutValue.Equals(FLinearColor::Yellow, 0.001))
		{
			return false;
		}
		if (!Clamped.Equals(FLinearColor(0.0, 0.5, 1.0, 1.0), 0.001))
		{
			return false;
		}
		if (Packed.R <= 0.99)
		{
			return false;
		}
		if (Packed.G >= 0.01)
		{
			return false;
		}
		if (Packed.B >= 0.01)
		{
			return false;
		}
		if (Packed.A <= 0.99)
		{
			return false;
		}
		return GetColorLuminance(FLinearColor::White) > 0.9;
	}
}
/** @end */
