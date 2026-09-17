/**
 * @version v1
 * @summary FMargin host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FMargin
 *
 * margin
 * inputs-uniform-4-scale
 * margin-inscale-component
 * addition
 * subtraction
 * equality
 * get-top-left
 * get-desired-size
 * get-total-space-along-horizontal
 * get-total-space-along-vertical
 */
/**
 * @begin margin
 * @summary Expected observations: Uniform desired
 * @topic Unreal
 */
/**
 * @function ObserveMarginNominal
 * @summary Expected observations: Uniform desired
 * @covers FMargin.margin
 * @inputs FMargin values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Uniform desired

 size is (8,8). HV horizontal total
// is 4. LTRB top-left is (1,2). Vector constructors match the matching HV/LTRB
// forms.
// Boundary/ownership: FVector2D is (Horizontal, Vertical). FVector4 is
// (Left, Top, Right, Bottom).
bool ObserveMarginNominal()
{
	FMargin Uniform(4.0);
	FMargin HV(2.0, 3.0);
	FMargin FromVector2D(FVector2D(2.0, 3.0));
	FMargin LTRB(1.0, 2.0, 3.0, 4.0);
	FMargin FromVector4(FVector4(1.0, 2.0, 3.0, 4.0));
	FMargin Zero(0.0);
	return Uniform.GetDesiredSize().X == 8.0 &&
		HV == FromVector2D &&
		HV.GetTotalSpaceAlongHorizontal() == 4.0 &&
		LTRB.GetTopLeft().X == 1.0 &&
		LTRB == FromVector4 &&
		Zero.GetDesiredSize().X == 0.0;
}
/** @end */
/**
 * @begin inputs-uniform-4-scale
 * @summary Inputs: Uniform 4, Scale 2,
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary Inputs: Uniform 4, Scale 2,
 * @covers FMargin.inputs-uniform-4-scale
 * @inputs FMargin values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Uniform 4, Scale 2,

 InScale FMargin(2,1,2,1) or FVector? The
// component-wise scale is Margin * InScale where InScale is another margin.
// Zero margin as the empty operand.
// Expected observations: * 2 doubles all sides. + adds sides. Equal copies
// compare true.
// Boundary/ownership: These operators return new margins.
// Margin * Scale uniformly doubles FMargin(4) desired width to 16.
bool ObserveSurface006Nominal()
{
	FMargin Margin(4.0);
	FMargin Scaled = Margin * 2.0;
	return Scaled.GetDesiredSize().X == 16.0;
}
/** @end */
/**
 * @begin margin-inscale-component
 * @summary Margin * InScale is component-
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary Margin * InScale is component-
 * @covers FMargin.margin-inscale-component
 * @inputs FMargin values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Uniform 4, Scale 2,

wise: HV(4,2) * HV(2,1) horizontal total is 16.
bool ObserveSurface007Nominal()
{
	FMargin Margin(4.0, 2.0);
	FMargin InScale(2.0, 1.0);
	FMargin Scaled = Margin * InScale;
	return Scaled.GetTotalSpaceAlongHorizontal() == 16.0;
}
/** @end */
/**
 * @begin addition
 * @summary Margin + Other of uniform 4 and 1 has desired width 10.
 * @topic Unreal
 */
/**
 * @function ObserveAdditionNominal
 * @summary Margin + Other of uniform 4 and 1 has desired width 10.
 * @covers FMargin.addition
 * @inputs FMargin values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Uniform 4, Scale 2,

bool ObserveAdditionNominal()
{
	FMargin Margin(4.0);
	FMargin Other(1.0);
	FMargin Sum = Margin + Other;
	return Sum.GetDesiredSize().X == 10.0;
}
/** @end */
/**
 * @begin subtraction
 * @summary Margin - Other of uniform 4 and 1 has desired width 6.
 * @topic Unreal
 */
/**
 * @function ObserveSubtractionNominal
 * @summary Margin - Other of uniform 4 and 1 has desired width 6.
 * @covers FMargin.subtraction
 * @inputs FMargin values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Uniform 4, Scale 2,

bool ObserveSubtractionNominal()
{
	FMargin Margin(4.0);
	FMargin Other(1.0);
	FMargin Difference = Margin - Other;
	return Difference.GetDesiredSize().X == 6.0;
}
/** @end */
/**
 * @begin equality
 * @summary Copies
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary Copies
 * @covers FMargin.equality
 * @inputs FMargin values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Uniform 4, Scale 2,

 of HV(4,2) compare true; uniform 0 compares false.
bool ObserveEqualityNominal()
{
	FMargin Left(4.0, 2.0);
	FMargin Right(4.0, 2.0);
	FMargin Zero(0.0);
	return (Left == Right) && !(Left == Zero);
}
/** @end */
/**
 * @begin get-top-left
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveGetTopLeftNominal
 * @summary Observe the container API.
 * @covers FMargin.get-top-left
 * @inputs FMargin values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: LTRB (1,2,3,4), uniform 0, uniform 5.
// Expected observations: TopLeft is (1,2). Desired size is (4,6). Horizontal
// total is 4. Vertical total is 6. Zero margin totals are 0.
// Boundary/ownership: Queries do not mutate the margin.
bool ObserveGetTopLeftNominal()
{
	FMargin Margin(1.0, 2.0, 3.0, 4.0);
	FVector2D TopLeft = Margin.GetTopLeft();
	return TopLeft.X == 1.0 && TopLeft.Y == 2.0;
}
/** @end */
/**
 * @begin get-desired-size
 * @summary Boundary/ownership: Queries do not mutate the margin.
 * @topic Unreal
 */
/**
 * @function ObserveGetDesiredSizeNominal
 * @summary Boundary/ownership: Queries do not mutate the margin.
 * @covers FMargin.get-desired-size
 * @inputs FMargin values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetDesiredSizeNominal()
{
	FMargin Margin(1.0, 2.0, 3.0, 4.0);
	FVector2D Size = Margin.GetDesiredSize();
	FVector2D Zero = FMargin(0.0).GetDesiredSize();
	return Size.X == 4.0 && Size.Y == 6.0 && Zero.X == 0.0;
}
/** @end */
/**
 * @begin get-total-space-along-horizontal
 * @summary Boundary/ownership: Queries do not mutate the margin.
 * @topic Unreal
 */
/**
 * @function ObserveGetTotalSpaceAlongHorizontalNominal
 * @summary Boundary/ownership: Queries do not mutate the margin.
 * @covers FMargin.get-total-space-along-horizontal
 * @inputs FMargin values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetTotalSpaceAlongHorizontalNominal()
{
	FMargin Margin(1.0, 2.0, 3.0, 4.0);
	return Margin.GetTotalSpaceAlongHorizontal() == 4.0;
}
/** @end */
/**
 * @begin get-total-space-along-vertical
 * @summary Boundary/ownership: Queries do not mutate the margin.
 * @topic Unreal
 */
/**
 * @function ObserveGetTotalSpaceAlongVerticalNominal
 * @summary Boundary/ownership: Queries do not mutate the margin.
 * @covers FMargin.get-total-space-along-vertical
 * @inputs FMargin values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetTotalSpaceAlongVerticalNominal()
{
	FMargin Margin(1.0, 2.0, 3.0, 4.0);
	return Margin.GetTotalSpaceAlongVertical() == 6.0;
}
/** @end */
