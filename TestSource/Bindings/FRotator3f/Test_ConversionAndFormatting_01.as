// Purpose: Observe FRotator3f color-style component formatting.
// AS-facing API: FString Rotator.ToColorString() const;
// Inputs: (10,20,30) and ZeroRotator.
// Expected observations: The string contains P=, Y=, R= and editor color tags.
// Zero ToColorString is non-empty. The rotator is unchanged.
// Boundary/ownership: ToColorString returns a new string.

namespace TS_FRotator3f_ConversionAndFormatting_01
{
	bool Observe_ToColorString_Nominal()
	{
		FRotator3f Rotator(10.0, 20.0, 30.0);
		FString ColorText = Rotator.ToColorString();
		FString ZeroText = FRotator3f::ZeroRotator.ToColorString();
		return ColorText.Contains("P=") && ColorText.Contains("Y=") && ColorText.Contains("R=") && ColorText.Contains("<Green>") && ColorText.Contains("<Blue>") && ColorText.Contains("<Red>") && ZeroText.Len() > 0 && Rotator.Pitch == 10.0;
	}
}
