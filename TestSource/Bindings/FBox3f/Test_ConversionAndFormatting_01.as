// Purpose: Observe FBox3f.ToString for filled and degenerate boxes.
// The bool return is the runner-readable oracle.
// AS-facing API: FString FBox3f.ToString() const;
// Inputs: (0,0,0)-(1,1,1) and a zero-volume box at the origin.
// Expected observations: ToString is non-empty for both. The source box is
// unchanged.
// Boundary/ownership: ToString returns a new FString.

namespace TS_FBox3f_ConversionAndFormatting_01
{
	bool Observe_ToString_Nominal()
	{
		FBox3f Box(FVector3f(0, 0, 0), FVector3f(1, 1, 1));
		FString Text = Box.ToString();
		FBox3f Degenerate(FVector3f(0, 0, 0), FVector3f(0, 0, 0));
		FString DegenerateText = Degenerate.ToString();
		return Text.Len() > 0 && DegenerateText.Len() > 0 && Box.Max.X == 1.0;
	}
}
