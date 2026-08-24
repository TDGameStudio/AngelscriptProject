// Purpose: Observe FIntVector.ToString for nonzero and zero vectors.
// AS-facing API: FString FIntVector.ToString() const;
// Inputs: (1,2,3) and (0,0,0).
// Expected observations: Both ToString results are non-empty. The source
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
