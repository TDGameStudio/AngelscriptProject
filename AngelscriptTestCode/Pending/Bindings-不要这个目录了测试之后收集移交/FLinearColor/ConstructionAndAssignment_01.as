/**
 * @version v1
 * @summary Observe FLinearColor assignment and add/subtract/multiply compound operators.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FLinearColor assignment and add/subtract/multiply compound operators.
 * @topic Baseline
 */
// * Scalar; *= Scalar.
// Inputs: (0.2,0.4,0.6,1), Other (0.1,0.1,0.1,0), Scalar 2, Black as zero.
// Expected observations: + adds channels. *= Scalar doubles RGB. Assignment
// copies RGBA. Black add is stable on RGB if A handling is considered.
// Boundary/ownership: Compound operators mutate Color. + returns a new color.

namespace TS_FLinearColor_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FLinearColor Left(0.2, 0.4, 0.6, 1.0);
		FLinearColor Right(0.1, 0.1, 0.1, 0.5);
		Left = Right;
		FLinearColor Sum = Left + Right;
		return Left.R == 0.1 && Sum.R == 0.2;
	}

	bool Observe_AddAssign_Nominal()
	{
		FLinearColor Color(0.2, 0.4, 0.6, 1.0);
		Color += FLinearColor(0.1, 0.1, 0.1, 0.0);
		return Color.R == 0.3 && Color.A == 1.0;
	}

	bool Observe_SubtractAssign_Nominal()
	{
		FLinearColor Color(0.2, 0.4, 0.6, 1.0);
		FLinearColor Difference = Color - FLinearColor(0.1, 0.1, 0.1, 0.0);
		Color -= FLinearColor(0.1, 0.1, 0.1, 0.0);
		return Difference.R == 0.1 && Color.R == 0.1;
	}

	bool Observe_MultiplyAssign_Nominal()
	{
		FLinearColor Color(0.2, 0.4, 0.6, 1.0);
		FLinearColor ByColor = Color * FLinearColor(0.5, 1.0, 1.0, 1.0);
		Color *= FLinearColor(0.5, 1.0, 1.0, 1.0);
		FLinearColor ByScalar = FLinearColor(0.2, 0.4, 0.6, 1.0) * 2.0;
		FLinearColor Scaled = FLinearColor(0.2, 0.4, 0.6, 1.0);
		Scaled *= 2.0;
		return ByColor.R == 0.1 && Color.R == 0.1 && ByScalar.R == 0.4 && Scaled.G == 0.8;
	}
}
/** @end */
