/**
 * @version v1
 * @summary Observe FIntVector.ToString for nonzero and zero vectors.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FIntVector.ToString for nonzero and zero vectors.
 * @topic Baseline
 */
// vector is unchanged.
// Boundary/ownership: ToString returns a new FString.

namespace TS_FIntVector_ConversionAndFormatting_01
{
	bool Observe_ToString_Nominal()
	{
		FIntVector Vector(1, 2, 3);
		FString Text = Vector.ToString();
		FString ZeroText = FIntVector(0, 0, 0).ToString();
		return Text.Len() > 0 && ZeroText.Len() > 0 && Vector.X == 1;
	}
}
/** @end */
