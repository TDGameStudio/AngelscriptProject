// Purpose: Observe editor color-coded and engine FRotator string forms.
// AS-facing API: FString FRotator.ToColorString() const;
// FString FRotator.ToString() const;
// Inputs: (10,20,30) and ZeroRotator.
// Expected observations: Both strings are non-empty and contain P=, Y=, and
// R=. ToColorString includes editor color tags. Zero ToString is non-empty.
// The rotator is unchanged.
// Boundary/ownership: Both methods return new strings.

namespace TS_FRotator_ConversionAndFormatting_01
{
	bool Observe_ToColorString_Nominal()
	{
		FRotator Rotator(10.0, 20.0, 30.0);
		FString ColorText = Rotator.ToColorString();
		FString ZeroText = FRotator::ZeroRotator.ToColorString();
		bool bHasComponents = ColorText.Contains("P=") && ColorText.Contains("Y=") && ColorText.Contains("R=");
		bool bHasColorTags = ColorText.Contains("<Green>") && ColorText.Contains("<Blue>") && ColorText.Contains("<Red>");
		return bHasComponents && bHasColorTags && ZeroText.Len() > 0 && Rotator.Pitch == 10.0;
	}

	bool Observe_ToString_Nominal()
	{
		FRotator Rotator(10.0, 20.0, 30.0);
		FString Text = Rotator.ToString();
		FString ZeroText = FRotator::ZeroRotator.ToString();
		return Text.Contains("P=") && Text.Contains("Y=") && Text.Contains("R=") && ZeroText.Len() > 0 && Rotator.Yaw == 20.0;
	}
}
