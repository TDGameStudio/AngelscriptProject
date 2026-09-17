/**
 * @version v1
 * @summary Observe FVector4f.ToString for nonzero and zero vectors.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector4f.ToString for nonzero and zero vectors.
 * @topic Baseline
 */
// vector is unchanged.
// Boundary/ownership: ToString returns a new FString.

namespace TS_FVector4f_ConversionAndFormatting_01
{
	bool Observe_ToString_Nominal()
	{
		FVector4f Vector(1.0f, 2.0f, 3.0f, 4.0f);
		FString Text = Vector.ToString();
		FVector4f Zero;
		FString ZeroText = Zero.ToString();
		return Text.Len() > 0 && ZeroText.Len() > 0 && Vector.W == 4.0f;
	}
}
/** @end */
