// Purpose: Observe FVector2D.ToString for nonzero and zero vectors.
// AS-facing API: FString FVector2D.ToString() const;
// Inputs: (1,2) and (0,0).
// Expected observations: Both ToString results are non-empty. The source
// vector is unchanged.
// Boundary/ownership: ToString returns a new FString.

namespace TS_FVector2D_ConversionAndFormatting_01
{
	bool Observe_ToString_Nominal()
	{
		FVector2D Vector(1, 2);
		FString Text = Vector.ToString();
		FString ZeroText = FVector2D(0, 0).ToString();
		return Text.Len() > 0 && ZeroText.Len() > 0 && Vector.X == 1.0;
	}
}
