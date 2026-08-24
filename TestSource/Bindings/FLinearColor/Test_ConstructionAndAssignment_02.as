// Purpose: Observe FLinearColor divide compound operators and formatter
// interpolation.
// AS-facing API: Color / ColorB; /= ColorB; Color / Scalar; /= Scalar;
// FString Text = f"{Color}";
// Inputs: (0.4,0.4,0.4,1) divided by (2,2,2,1) and by scalar 2, plus Black.
// Expected observations: / 2 halves RGB. f"{Color}" is non-empty.
// Boundary/ownership: Divide-by-zero is a diagnostic boundary and is not
// invoked in the nominal path.

namespace TS_FLinearColor_ConstructionAndAssignment_02
{
	bool Observe_DivideAssign_Nominal()
	{
		FLinearColor Color(0.4, 0.4, 0.4, 1.0);
		FLinearColor ByColor = Color / FLinearColor(2.0, 2.0, 2.0, 1.0);
		Color /= FLinearColor(2.0, 2.0, 2.0, 1.0);
		FLinearColor ByScalar = FLinearColor(0.4, 0.4, 0.4, 1.0) / 2.0;
		FLinearColor Scaled(0.4, 0.4, 0.4, 1.0);
		Scaled /= 2.0;
		return ByColor.R == 0.2 && Color.R == 0.2 && ByScalar.R == 0.2 && Scaled.R == 0.2;
	}

	bool Observe_Assignment_Nominal()
	{
		FLinearColor Color(0.2, 0.4, 0.6, 1.0);
		FString Text = f"{Color}";
		FString BlackText = f"{FLinearColor::Black}";
		return Text.Len() > 0 && BlackText.Len() > 0;
	}
}
