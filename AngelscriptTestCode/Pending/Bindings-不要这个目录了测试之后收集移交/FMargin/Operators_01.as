/**
 * @version v1
 * @summary Observe FMargin uniform/component-wise scale, add/subtract, and equality.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FMargin uniform/component-wise scale, add/subtract, and equality.
 * @topic Baseline
 */
// Margin == Other;
// Inputs: Uniform 4, Scale 2, InScale FMargin(2,1,2,1) or FVector? The
// component-wise scale is Margin * InScale where InScale is another margin.
// Zero margin as the empty operand.
// Expected observations: * 2 doubles all sides. + adds sides. Equal copies
// compare true.
// Boundary/ownership: These operators return new margins.

namespace TS_FMargin_Operators_01
{
	// Margin * Scale uniformly doubles FMargin(4) desired width to 16.
	bool Observe_Surface006_Nominal()
	{
		FMargin Margin(4.0);
		FMargin Scaled = Margin * 2.0;
		return Scaled.GetDesiredSize().X == 16.0;
	}

	// Margin * InScale is component-wise: HV(4,2) * HV(2,1) horizontal total is 16.
	bool Observe_Surface007_Nominal()
	{
		FMargin Margin(4.0, 2.0);
		FMargin InScale(2.0, 1.0);
		FMargin Scaled = Margin * InScale;
		return Scaled.GetTotalSpaceAlongHorizontal() == 16.0;
	}

	// Margin + Other of uniform 4 and 1 has desired width 10.
	bool Observe_Addition_Nominal()
	{
		FMargin Margin(4.0);
		FMargin Other(1.0);
		FMargin Sum = Margin + Other;
		return Sum.GetDesiredSize().X == 10.0;
	}

	// Margin - Other of uniform 4 and 1 has desired width 6.
	bool Observe_Subtraction_Nominal()
	{
		FMargin Margin(4.0);
		FMargin Other(1.0);
		FMargin Difference = Margin - Other;
		return Difference.GetDesiredSize().X == 6.0;
	}

	// Copies of HV(4,2) compare true; uniform 0 compares false.
	bool Observe_Equality_Nominal()
	{
		FMargin Left(4.0, 2.0);
		FMargin Right(4.0, 2.0);
		FMargin Zero(0.0);
		return (Left == Right) && !(Left == Zero);
	}
}
/** @end */
