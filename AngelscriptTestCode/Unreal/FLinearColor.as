/**
 * @version v1
 * @summary FLinearColor host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FLinearColor
 *
 * color
 * surface-004
 * surface-005
 * surface-006
 * surface-007
 * linear-rgb-to-hsv
 * hsv-to-linear-rgb
 * FLinearColor-Behavior_02-color
 * assignment
 * add-assign
 * subtract-assign
 * multiply-assign
 * divide-assign
 * FLinearColor-ConstructionAndAssignment_02-assignment
 * make-random-color
 * make-from-color-temperature
 * make-from-hsv-8
 * lerp-using-hsv
 * make-from-hex
 * container-api
 * flinearcolor-gray-r-strictly
 * FLinearColor-NamespaceAndGlobalFunctions_01-container-api
 * flinearcolor-transparent-has-0
 * flinearcolor-red-has-r
 * flinearcolor-green-g-exceeds
 * flinearcolor-blue-b-exceeds
 * flinearcolor-yellow-has-positive
 * flinearcolor-lucblue-has-positive
 * flinearcolor-dpink-not-black
 * flinearcolor-teal-has-positive
 * flinearcolor-purple-has-positive
 * equality
 * get-clamped
 * equals
 * is-almost-black
 * get-min
 * get-max
 * get-luminance
 * advanced-methods
 * linear-color-arithmetic-operators
 * linear-color-comparison-operators
 * linear-color-construction
 * linear-color-member-access
 * linear-color-methods
 * runtime-curve-linear-color-add-default-key
 * class-member-execution
 * container-properties
 * declaration-defaults
 * write-round-trip
 * function-default-parameters
 * function-parameters-in
 * function-parameters-in-out
 * function-parameters-out
 * function-parameters-value
 * function-return-values

 */
/**
 * @begin color
 * @summary FLinearColor(), RGB with omitted A=1, and copy.
 * @topic Unreal
 */
/**
 * @function ObserveColorNominal
 * @summary FLinearColor(), RGB with omitted A=1, and copy.
 * @covers FLinearColor.color
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveColorNominal()
{
	FLinearColor DefaultColor;
	FLinearColor Rgb(0.2, 0.4, 0.6);
	FLinearColor Copied(Rgb);
	return DefaultColor.R == 0.0 && Rgb.A == 1.0 && Copied.B == 0.6;
}
/** @end */
/**
 * @begin surface-004
 * @summary FLinearColor.
 * @topic Unreal
 */
/**
 * @function ObserveSurface004Nominal
 * @summary FLinearColor.
 * @covers FLinearColor.surface-004
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
R of (0.2,0.4,0.6,1) is 0.2. Query, no fixture.
bool ObserveSurface004Nominal()
{
	return FLinearColor(0.2, 0.4, 0.6, 1.0).R == 0.2;
}
/** @end */
/**
 * @begin surface-005
 * @summary FLinearColor.
 * @topic Unreal
 */
/**
 * @function ObserveSurface005Nominal
 * @summary FLinearColor.
 * @covers FLinearColor.surface-005
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
G of (0.2,0.4,0.6,1) is 0.4. Query, no fixture.
bool ObserveSurface005Nominal()
{
	return FLinearColor(0.2, 0.4, 0.6, 1.0).G == 0.4;
}
/** @end */
/**
 * @begin surface-006
 * @summary FLinearColor.
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary FLinearColor.
 * @covers FLinearColor.surface-006
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
B of (0.2,0.4,0.6,1) is 0.6. Query, no fixture.
bool ObserveSurface006Nominal()
{
	return FLinearColor(0.2, 0.4, 0.6, 1.0).B == 0.6;
}
/** @end */
/**
 * @begin surface-007
 * @summary FLinearColor.
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary FLinearColor.
 * @covers FLinearColor.surface-007
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
A of (0.2,0.4,0.6,0.5) is 0.5. Query, no fixture.
bool ObserveSurface007Nominal()
{
	return FLinearColor(0.2, 0.4, 0.6, 0.5).A == 0.5;
}
/** @end */
/**
 * @begin linear-rgb-to-hsv
 * @summary LinearRGBToHSV of Red has hue 0 with full saturation and value.
 * @topic Unreal
 */
/**
 * @function ObserveLinearRGBToHSVNominal
 * @summary LinearRGBToHSV of Red has hue 0 with full saturation and value.
 * @covers FLinearColor.linear-rgb-to-hsv
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLinearRGBToHSVNominal()
{
	FLinearColor Hsv = FLinearColor::Red.LinearRGBToHSV();
	return Hsv.R == 0.0 && Hsv.G == 1.0 && Hsv.B == 1.0;
}
/** @end */
/**
 * @begin hsv-to-linear-rgb
 * @summary HSVToLinearRGB of Red's HSV recovers a color whose R exceeds G.
 * @topic Unreal
 */
/**
 * @function ObserveHSVToLinearRGBNominal
 * @summary HSVToLinearRGB of Red's HSV recovers a color whose R exceeds G.
 * @covers FLinearColor.hsv-to-linear-rgb
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveHSVToLinearRGBNominal()
{
	FLinearColor Hsv = FLinearColor::Red.LinearRGBToHSV();
	FLinearColor RoundTrip = Hsv.HSVToLinearRGB();
	return RoundTrip.R > RoundTrip.G;
}
/** @end */
/**
 * @begin FLinearColor-Behavior_02-color
 * @summary according to FColor conversion rules.
 * @topic Unreal
 */
/**
 * @function ObserveColorNominal
 * @summary according to FColor conversion rules.
 * @covers FLinearColor.color
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveColorNominal()
{
	FLinearColor FromRed(FColor::Red);
	FLinearColor FromBlack(FColor::Black);
	FLinearColor FromTransparent(FColor::Transparent);
	return FromRed.R > FromRed.G &&
		FromBlack.R == 0.0 &&
		FromBlack.G == 0.0 &&
		FromBlack.B == 0.0 &&
		FromTransparent.A == 0.0;
}
/** @end */
/**
 * @begin assignment
 * @summary Boundary/ownership: Compound operators mutate Color.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Boundary/ownership: Compound operators mutate Color.
 * @covers FLinearColor.assignment
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FLinearColor Left(0.2, 0.4, 0.6, 1.0);
	FLinearColor Right(0.1, 0.1, 0.1, 0.5);
	Left = Right;
	FLinearColor Sum = Left + Right;
	return Left.R == 0.1 && Sum.R == 0.2;
}
/** @end */
/**
 * @begin add-assign
 * @summary Boundary/ownership: Compound operators mutate Color.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary Boundary/ownership: Compound operators mutate Color.
 * @covers FLinearColor.add-assign
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal()
{
	FLinearColor Color(0.2, 0.4, 0.6, 1.0);
	Color += FLinearColor(0.1, 0.1, 0.1, 0.0);
	return Color.R == 0.3 && Color.A == 1.0;
}
/** @end */
/**
 * @begin subtract-assign
 * @summary Boundary/ownership: Compound operators mutate Color.
 * @topic Unreal
 */
/**
 * @function ObserveSubtractAssignNominal
 * @summary Boundary/ownership: Compound operators mutate Color.
 * @covers FLinearColor.subtract-assign
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSubtractAssignNominal()
{
	FLinearColor Color(0.2, 0.4, 0.6, 1.0);
	FLinearColor Difference = Color - FLinearColor(0.1, 0.1, 0.1, 0.0);
	Color -= FLinearColor(0.1, 0.1, 0.1, 0.0);
	return Difference.R == 0.1 && Color.R == 0.1;
}
/** @end */
/**
 * @begin multiply-assign
 * @summary Boundary/ownership: Compound operators mutate Color.
 * @topic Unreal
 */
/**
 * @function ObserveMultiplyAssignNominal
 * @summary Boundary/ownership: Compound operators mutate Color.
 * @covers FLinearColor.multiply-assign
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMultiplyAssignNominal()
{
	FLinearColor Color(0.2, 0.4, 0.6, 1.0);
	FLinearColor ByColor = Color * FLinearColor(0.5, 1.0, 1.0, 1.0);
	Color *= FLinearColor(0.5, 1.0, 1.0, 1.0);
	FLinearColor ByScalar = FLinearColor(0.2, 0.4, 0.6, 1.0) * 2.0;
	FLinearColor Scaled = FLinearColor(0.2, 0.4, 0.6, 1.0);
	Scaled *= 2.0;
	return ByColor.R == 0.1 && Color.R == 0.1 && ByScalar.R == 0.4 && Scaled.G == 0.8;
}
/** @end */
/**
 * @begin divide-assign
 * @summary invoked in the nominal path.
 * @topic Unreal
 */
/**
 * @function ObserveDivideAssignNominal
 * @summary invoked in the nominal path.
 * @covers FLinearColor.divide-assign
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: (0.4,0.4,0.4,1)

bool ObserveDivideAssignNominal()
{
	FLinearColor Color(0.4, 0.4, 0.4, 1.0);
	FLinearColor ByColor = Color / FLinearColor(2.0, 2.0, 2.0, 1.0);
	Color /= FLinearColor(2.0, 2.0, 2.0, 1.0);
	FLinearColor ByScalar = FLinearColor(0.4, 0.4, 0.4, 1.0) / 2.0;
	FLinearColor Scaled(0.4, 0.4, 0.4, 1.0);
	Scaled /= 2.0;
	return ByColor.R == 0.2 && Color.R == 0.2 && ByScalar.R == 0.2 && Scaled.R == 0.2;
}
/** @end */
/**
 * @begin FLinearColor-ConstructionAndAssignment_02-assignment
 * @summary invoked in the nominal path.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary invoked in the nominal path.
 * @covers FLinearColor.assignment
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: (0.4,0.4,0.4,1)

bool ObserveAssignmentNominal()
{
	FLinearColor Color(0.2, 0.4, 0.6, 1.0);
	FString Text = f"{Color}";
	FString BlackText = f"{FLinearColor::Black}";
	return Text.Len() > 0 && BlackText.Len() > 0;
}
/** @end */
/**
 * @begin make-random-color
 * @summary FLinearColor::MakeRandomColor is opaque with RGB in [0,1].
 * @topic Unreal
 */
/**
 * @function ObserveMakeRandomColorNominal
 * @summary FLinearColor::MakeRandomColor is opaque with RGB in [0,1].
 * @covers FLinearColor.make-random-color
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMakeRandomColorNominal()
{
	FLinearColor Random = FLinearColor::MakeRandomColor();
	return Random.A == 1.0 &&
		Random.R >= 0.0 && Random.R <= 1.0 &&
		Random.G >= 0.0 && Random.G <= 1.0 &&
		Random.B >= 0.0 && Random.B <= 1.0;
}
/** @end */
/**
 * @begin make-from-color-temperature
 * @summary MakeFromColorTemperature(6500) and (2000) stay opaque with non-negative red.
 * @topic Unreal
 */
/**
 * @function ObserveMakeFromColorTemperatureNominal
 * @summary MakeFromColorTemperature(6500) and (2000) stay opaque with non-negative red.
 * @covers FLinearColor.make-from-color-temperature
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMakeFromColorTemperatureNominal()
{
	FLinearColor Daylight = FLinearColor::MakeFromColorTemperature(6500.0);
	FLinearColor Warm = FLinearColor::MakeFromColorTemperature(2000.0);
	return Daylight.A == 1.0 && Warm.R >= 0.0 && Warm.A == 1.0;
}
/** @end */
/**
 * @begin make-from-hsv-8
 * @summary MakeFromHSV8(0,255,255) is red-dominant.
 * @topic Unreal
 */
/**
 * @function ObserveMakeFromHSV8Nominal
 * @summary MakeFromHSV8(0,255,255) is red-dominant.
 * @covers FLinearColor.make-from-hsv-8
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMakeFromHSV8Nominal()
{
	FLinearColor Red = FLinearColor::MakeFromHSV8(0, 255, 255);
	FLinearColor Black = FLinearColor::MakeFromHSV8(0, 0, 0);
	return Red.R > Red.G && Black.IsAlmostBlack();
}
/** @end */
/**
 * @begin lerp-using-hsv
 * @summary LerpUsingHSV at 0 matches From, at 1 matches To, midpoint G is non-negative.
 * @topic Unreal
 */
/**
 * @function ObserveLerpUsingHSVNominal
 * @summary LerpUsingHSV at 0 matches From, at 1 matches To, midpoint G is non-negative.
 * @covers FLinearColor.lerp-using-hsv
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLerpUsingHSVNominal()
{
	FLinearColor From = FLinearColor::Red;
	FLinearColor To = FLinearColor::Blue;
	FLinearColor Start = FLinearColor::LerpUsingHSV(From, To, 0.0);
	FLinearColor Mid = FLinearColor::LerpUsingHSV(From, To, 0.5);
	FLinearColor End = FLinearColor::LerpUsingHSV(From, To, 1.0);
	return Start.Equals(From) && End.Equals(To) && Mid.G >= 0.0;
}
/** @end */
/**
 * @begin make-from-hex
 * @summary MakeFromHex(0xFF0000) has R>0 for sRGB and linear.
 * @topic Unreal
 */
/**
 * @function ObserveMakeFromHexNominal
 * @summary MakeFromHex(0xFF0000) has R>0 for sRGB and linear.
 * @covers FLinearColor.make-from-hex
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMakeFromHexNominal()
{
	FLinearColor Srgb = FLinearColor::MakeFromHex(0xFF0000);
	FLinearColor Linear = FLinearColor::MakeFromHex(0xFF0000, false);
	FLinearColor Zero = FLinearColor::MakeFromHex(0);
	return Srgb.R > 0.0 && Linear.R > 0.0 && Zero.R == 0.0;
}
/** @end */
/**
 * @begin container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface035Nominal
 * @summary Observe the container API.
 * @covers FLinearColor.container-api
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
 FLinearColor::White is (1,1,1,1). Palette constant.
bool ObserveSurface035Nominal()
{
	return FLinearColor::White.R == 1.0 && FLinearColor::White.A == 1.0;
}
/** @end */
/**
 * @begin flinearcolor-gray-r-strictly
 * @summary FLinearColor::Gray R is strictly between 0 and 1.
 * @topic Unreal
 */
/**
 * @function ObserveSurface036Nominal
 * @summary FLinearColor::Gray R is strictly between 0 and 1.
 * @covers FLinearColor.flinearcolor-gray-r-strictly
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface036Nominal()
{
	return FLinearColor::Gray.R > 0.0 && FLinearColor::Gray.R < 1.0;
}
/** @end */
/**
 * @begin FLinearColor-NamespaceAndGlobalFunctions_01-container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface037Nominal
 * @summary Observe the container API.
 * @covers FLinearColor.container-api
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
 FLinearColor::Black is (0,*,*,1). Palette constant.
bool ObserveSurface037Nominal()
{
	return FLinearColor::Black.R == 0.0 && FLinearColor::Black.A == 1.0;
}
/** @end */
/**
 * @begin flinearcolor-transparent-has-0
 * @summary FLinearColor::Transparent has A=0.
 * @topic Unreal
 */
/**
 * @function ObserveSurface038Nominal
 * @summary FLinearColor::Transparent has A=0.
 * @covers FLinearColor.flinearcolor-transparent-has-0
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface038Nominal()
{
	return FLinearColor::Transparent.A == 0.0;
}
/** @end */
/**
 * @begin flinearcolor-red-has-r
 * @summary FLinearColor::Red has R>G and A=1.
 * @topic Unreal
 */
/**
 * @function ObserveSurface039Nominal
 * @summary FLinearColor::Red has R>G and A=1.
 * @covers FLinearColor.flinearcolor-red-has-r
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface039Nominal()
{
	return FLinearColor::Red.R > FLinearColor::Red.G && FLinearColor::Red.A == 1.0;
}
/** @end */
/**
 * @begin flinearcolor-green-g-exceeds
 * @summary FLinearColor::Green G exceeds R.
 * @topic Unreal
 */
/**
 * @function ObserveSurface040Nominal
 * @summary FLinearColor::Green G exceeds R.
 * @covers FLinearColor.flinearcolor-green-g-exceeds
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface040Nominal()
{
	return FLinearColor::Green.G > FLinearColor::Green.R;
}
/** @end */
/**
 * @begin flinearcolor-blue-b-exceeds
 * @summary FLinearColor::Blue B exceeds R.
 * @topic Unreal
 */
/**
 * @function ObserveSurface041Nominal
 * @summary FLinearColor::Blue B exceeds R.
 * @covers FLinearColor.flinearcolor-blue-b-exceeds
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface041Nominal()
{
	return FLinearColor::Blue.B > FLinearColor::Blue.R;
}
/** @end */
/**
 * @begin flinearcolor-yellow-has-positive
 * @summary FLinearColor::Yellow has positive R and G.
 * @topic Unreal
 */
/**
 * @function ObserveSurface042Nominal
 * @summary FLinearColor::Yellow has positive R and G.
 * @covers FLinearColor.flinearcolor-yellow-has-positive
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface042Nominal()
{
	return FLinearColor::Yellow.R > 0.0 && FLinearColor::Yellow.G > 0.0;
}
/** @end */
/**
 * @begin flinearcolor-lucblue-has-positive
 * @summary FLinearColor::LucBlue has positive B and A=1.
 * @topic Unreal
 */
/**
 * @function ObserveSurface043Nominal
 * @summary FLinearColor::LucBlue has positive B and A=1.
 * @covers FLinearColor.flinearcolor-lucblue-has-positive
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface043Nominal()
{
	return FLinearColor::LucBlue.B > 0.0 && FLinearColor::LucBlue.A == 1.0;
}
/** @end */
/**
 * @begin flinearcolor-dpink-not-black
 * @summary FLinearColor::DPink is not Black.
 * @topic Unreal
 */
/**
 * @function ObserveSurface044Nominal
 * @summary FLinearColor::DPink is not Black.
 * @covers FLinearColor.flinearcolor-dpink-not-black
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface044Nominal()
{
	return !(FLinearColor::DPink == FLinearColor::Black);
}
/** @end */
/**
 * @begin flinearcolor-teal-has-positive
 * @summary FLinearColor::Teal has positive G and B.
 * @topic Unreal
 */
/**
 * @function ObserveSurface045Nominal
 * @summary FLinearColor::Teal has positive G and B.
 * @covers FLinearColor.flinearcolor-teal-has-positive
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface045Nominal()
{
	return FLinearColor::Teal.G > 0.0 && FLinearColor::Teal.B > 0.0;
}
/** @end */
/**
 * @begin flinearcolor-purple-has-positive
 * @summary FLinearColor::Purple has positive R and B.
 * @topic Unreal
 */
/**
 * @function ObserveSurface046Nominal
 * @summary FLinearColor::Purple has positive R and B.
 * @covers FLinearColor.flinearcolor-purple-has-positive
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface046Nominal()
{
	return FLinearColor::Purple.R > 0.0 && FLinearColor::Purple.B > 0.0;
}
/** @end */
/**
 * @begin equality
 * @summary with tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary with tolerance.
 * @covers FLinearColor.equality
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FLinearColor Left(0.2, 0.4, 0.6, 1.0);
	FLinearColor Right(0.2, 0.4, 0.6, 1.0);
	FLinearColor Alpha(0.2, 0.4, 0.6, 0.0);
	return (Left == Right) && !(Left == FLinearColor::Black) && !(Left == Alpha);
}
/** @end */
/**
 * @begin get-clamped
 * @summary Boundary/ownership: GetClamped returns a new color.
 * @topic Unreal
 */
/**
 * @function ObserveGetClampedNominal
 * @summary Boundary/ownership: GetClamped returns a new color.
 * @covers FLinearColor.get-clamped
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetClampedNominal()
{
	FLinearColor Color(1.5, -0.2, 0.4, 1.0);
	FLinearColor Clamped = Color.GetClamped();
	FLinearColor Custom = Color.GetClamped(0.0, 0.5);
	return Clamped.R == 1.0 && Clamped.G == 0.0 && Custom.R == 0.5;
}
/** @end */
/**
 * @begin equals
 * @summary Boundary/ownership: GetClamped returns a new color.
 * @topic Unreal
 */
/**
 * @function ObserveEqualsNominal
 * @summary Boundary/ownership: GetClamped returns a new color.
 * @covers FLinearColor.equals
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualsNominal()
{
	FLinearColor Left(0.2, 0.4, 0.6, 1.0);
	FLinearColor Right(0.2, 0.4, 0.6, 1.0);
	FLinearColor Perturbed(0.2 + KINDA_SMALL_NUMBER * 0.5, 0.4, 0.6, 1.0);
	return Left.Equals(Right) && Left.Equals(Perturbed);
}
/** @end */
/**
 * @begin is-almost-black
 * @summary Boundary/ownership: GetClamped returns a new color.
 * @topic Unreal
 */
/**
 * @function ObserveIsAlmostBlackNominal
 * @summary Boundary/ownership: GetClamped returns a new color.
 * @covers FLinearColor.is-almost-black
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsAlmostBlackNominal()
{
	return FLinearColor::Black.IsAlmostBlack() && !FLinearColor::White.IsAlmostBlack();
}
/** @end */
/**
 * @begin get-min
 * @summary Boundary/ownership: GetClamped returns a new color.
 * @topic Unreal
 */
/**
 * @function ObserveGetMinNominal
 * @summary Boundary/ownership: GetClamped returns a new color.
 * @covers FLinearColor.get-min
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetMinNominal()
{
	FLinearColor Color(0.2, 0.4, 0.1, 1.0);
	return Color.GetMin() == 0.1;
}
/** @end */
/**
 * @begin get-max
 * @summary Boundary/ownership: GetClamped returns a new color.
 * @topic Unreal
 */
/**
 * @function ObserveGetMaxNominal
 * @summary Boundary/ownership: GetClamped returns a new color.
 * @covers FLinearColor.get-max
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetMaxNominal()
{
	FLinearColor Color(0.2, 0.4, 0.1, 1.0);
	return Color.GetMax() == 0.4;
}
/** @end */
/**
 * @begin get-luminance
 * @summary Boundary/ownership: GetClamped returns a new color.
 * @topic Unreal
 */
/**
 * @function ObserveGetLuminanceNominal
 * @summary Boundary/ownership: GetClamped returns a new color.
 * @covers FLinearColor.get-luminance
 * @inputs FLinearColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetLuminanceNominal()
{
	float32 WhiteLum = FLinearColor::White.GetLuminance();
	float32 BlackLum = FLinearColor::Black.GetLuminance();
	return WhiteLum > BlackLum && BlackLum == 0.0;
}
/** @end */
/**
 * @begin advanced-methods
 * @summary Compare two nearby colors with a 0.01 tolerance.
 * @topic Unreal
 */
/**
 * @function EqualsWithinTolerance
 * @summary Compare two nearby colors with a 0.01 tolerance.
 * @covers FLinearColor.AdvancedMethods
 * @inputs none
 * @return true
 */
bool EqualsWithinTolerance()
{
	FLinearColor a = FLinearColor(0.2, 0.4, 0.6, 1.0);
	FLinearColor b = FLinearColor(0.201, 0.399, 0.6, 1.0);
	return a.Equals(b, 0.01);
}
/** @end */
/**
 * @begin linear-color-arithmetic-operators
 * @summary Scale a color in place.
 * @topic Unreal
 */
/**
 * @function OpAddNominal
 * @summary Scale a color in place.
 * @covers FLinearColor.ArithmeticOperators
 * @inputs none
 * @return FLinearColor(1.0, 0.8, 0.6, 0.4)
 */
 result equals (0.6, 0.6, 0.6, 0.6)
 */
UFUNCTION()
bool OpAddNominal()
{
	return OpAdd().Equals(FLinearColor(0.6, 0.6, 0.6, 0.6));
}
/** @end */
/**
 * @begin linear-color-comparison-operators
 * @summary Compare two identical colors for equality.
 * @topic Unreal
 */
/**
 * @function OpEquals_True
 * @summary Compare two identical colors for equality.
 * @covers FLinearColor.ComparisonOperators
 * @inputs none
 * @return true
 */
bool OpEquals_True()
{
	FLinearColor a = FLinearColor(0.5, 0.6, 0.7, 0.8);
	FLinearColor b = FLinearColor(0.5, 0.6, 0.7, 0.8);
	return a == b;
}
/** @end */
/**
 * @begin linear-color-construction
 * @summary Read the yellow constant.
 * @topic Unreal
 */
/**
 * @function ConstructDefaultNominal
 * @summary Read the yellow constant.
 * @covers FLinearColor.Construction
 * @inputs none
 * @return FLinearColor::Yellow
 */
 constructor yields (0, 0, 0, 1).
 *
 * @Kind Observe
 * @Covers FLinearColor.Construction
 * @Inputs none
 * @Return true when the result equals (0, 0, 0, 1)
 */
UFUNCTION()
bool ConstructDefaultNominal()
{
	return ConstructDefault().Equals(FLinearColor(0.0, 0.0, 0.0, 1.0));
}
/** @end */
/**
 * @begin linear-color-member-access
 * @summary Observe that reading every component yields the expected values.
 * @topic Unreal
 */
/**
 * @function GettersNominal
 * @summary Observe that reading every component yields the expected values.
 * @covers FLinearColor.MemberAccess
 * @inputs none
 * @return true when R, G, B and A read 0.1, 0.2, 0.3 and 0.4
 */
bool GettersNominal()
{
	if (GetR() != 0.1)
	{
		return false;
	}
	if (GetG() != 0.2)
	{
		return false;
	}
	if (GetB() != 0.3)
	{
		return false;
	}
	return GetA() == 0.4;
}
/** @end */
/**
 * @begin linear-color-methods
 * @summary Observe that sRGB conversion of white is opaque white.
 * @topic Unreal
 */
/**
 * @function ToFColorSRGBNominal
 * @summary Observe that sRGB conversion of white is opaque white.
 * @covers FLinearColor.Methods
 * @inputs none
 * @return true when every FColor channel is 255
 */
bool ToFColorSRGBNominal()
{
	FColor Result = ToFColorSRGB();

	if (Result.R != 255)
	{
		return false;
	}
	if (Result.G != 255)
	{
		return false;
	}
	if (Result.B != 255)
	{
		return false;
	}
	return Result.A == 255;
}
/** @end */
/**
 * @begin runtime-curve-linear-color-add-default-key
 * @summary Write two default keys onto a runtime color curve.
 * @topic Unreal
 */
/**
 * @function PopulateCurve
 * @summary Write two default keys onto a runtime color curve.
 * @covers FLinearColor.RuntimeCurveLinearColorAddDefaultKey
 * @inputs a runtime color curve
 * @return 1 after both keys are added
 */
int PopulateCurve(FRuntimeCurveLinearColor&inout Curve)
{
	Curve.AddDefaultKey(0.0f, FLinearColor(1.0f, 0.0f, 0.0f, 0.25f));
	Curve.AddDefaultKey(2.5f, FLinearColor(0.125f, 0.5f, 0.75f, 1.0f));
	return 1;
}
/** @end */
/**
 * @begin class-member-execution
 * @summary WorldStory: BeginPlay clamps the runtime tint against the editable color and records three history entries.
 * @topic Unreal
 */
/**
 * @function BeginPlay
 * @summary WorldStory: BeginPlay clamps the runtime tint against the editable color and records three history entries.
 * @covers FLinearColor.ClassMemberExecution
 * @inputs none
 * @return three history entries and a clamped runtime tint
 */
UCLASS()
class ACoverageFLinearColorClassMemberActor : AActor
{
	UPROPERTY()
	FLinearColor EditableColor = FLinearColor(0.2, 0.4, 0.6, 0.8);

	UPROPERTY()
	TArray<FLinearColor> ColorHistory;

	FLinearColor RuntimeTint = FLinearColor::LucBlue;

	/**
	 * WorldStory: BeginPlay clamps the runtime tint against the editable color and records
	 * three history entries.
	 *
	 * @Kind WorldStory
	 * @Covers FLinearColor.ClassMemberExecution
	 * @Inputs none
	 * @Return three history entries and a clamped runtime tint
	 */
	UFUNCTION(BlueprintOverride)

	void BeginPlay()
	{
		FLinearColor LocalTint = EditableColor + RuntimeTint.GetClamped(0.0, 1.0);
		RuntimeTint = LocalTint.GetClamped(0.0, 1.0);
		ColorHistory.Add(EditableColor);
		ColorHistory.Add(ReadConstTint());
		ColorHistory.Add(FLinearColor::MakeFromHex(0xFFFFFFFF, false));
	}
/** @end */
/**
 * @begin container-properties
 * @summary WorldStory: BeginPlay fills the array with red, green and blue and the map with white, black and yellow.
 * @topic Unreal
 */
/**
 * @function BeginPlay
 * @summary WorldStory: BeginPlay fills the array with red, green and blue and the map with white, black and yellow.
 * @covers FLinearColor.ContainerProperties
 * @inputs none
 * @return three entries in each container
 */
UCLASS()
class ACoverageFLinearColorContainerActor : AActor
{
	UPROPERTY()
	TArray<FLinearColor> ColorArray;

	UPROPERTY()
	TMap<int, FLinearColor> IntToColorMap;

	/**
	 * WorldStory: BeginPlay fills the array with red, green and blue and the map with
	 * white, black and yellow.
	 *
	 * @Kind WorldStory
	 * @Covers FLinearColor.ContainerProperties
	 * @Inputs none
	 * @Return three entries in each container
	 */
	UFUNCTION(BlueprintOverride)

	void BeginPlay()
	{
		ColorArray.Add(FLinearColor::Red);
		ColorArray.Add(FLinearColor::Green);
		ColorArray.Add(FLinearColor::Blue);

		IntToColorMap.Add(1, FLinearColor::White);
		IntToColorMap.Add(2, FLinearColor::Black);
		IntToColorMap.Add(3, FLinearColor::Yellow);
	}
/** @end */
/**
 * @begin declaration-defaults
 * @summary FLinearColor UPROPERTY declaration defaults read off a spawned actor.
 * @topic Unreal
 */
/**
 * @function WhiteColorNominal
 * @summary FLinearColor UPROPERTY declaration defaults read off a spawned actor.
 * @covers FLinearColor.declaration-defaults
 * @inputs FLinearColor values for this case
 * @return true when the observe comparison holds
 */
UCLASS()
class ACoverageFLinearColorDefaultsActor : AActor
{
	UPROPERTY()
	FLinearColor WhiteColor = FLinearColor::White;

	UPROPERTY()
	FLinearColor RedColor = FLinearColor::Red;

	UPROPERTY()
	FLinearColor BlackColor = FLinearColor::Black;

	UPROPERTY()
	FLinearColor CustomColor = FLinearColor(0.5, 0.25, 0.75, 1.0);

	UPROPERTY()
	FLinearColor NoDefaultColor;

	UPROPERTY()
	FLinearColor BlueColor = FLinearColor::Blue;

	/**
	 * Observe that the white default reads as opaque white.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.DeclarationDefaults
	 * @Inputs none
	 * @Return true when

 WhiteColor reads (1, 1, 1, 1)
	 */
	UFUNCTION()
	bool WhiteColorNominal()
	{
		if (WhiteColor.R != 1.0)
		{
			return false;
		}
		if (WhiteColor.G != 1.0)
		{
			return false;
		}
		if (WhiteColor.B != 1.0)
		{
			return false;
		}
		return WhiteColor.A == 1.0;
	}
/** @end */
/**
 * @begin write-round-trip
 * @summary Writing a FLinearColor UPROPERTY and reading it back across a populated value, zero and full white.
 * @topic Unreal
 */
/**
 * @function DefaultEmpty
 * @summary Writing a FLinearColor UPROPERTY and reading it back across a populated value, zero and full white.
 * @covers FLinearColor.write-round-trip
 * @inputs FLinearColor values for this case
 * @return true when the observe comparison holds
 */
UCLASS()
class ACoverageFLinearColorWriteActor : AActor
{
	UPROPERTY()
	FLinearColor ColorValue;

	/**
	 * Observe that an untouched property is black with alpha 1.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.WriteRoundTrip
	 * @Inputs none
	 * @Return true when

 ColorValue reads (0, 0, 0, 1)
	 * @Boundary default empty
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (ColorValue.R != 0.0)
		{
			return false;
		}
		if (ColorValue.G != 0.0)
		{
			return false;
		}
		if (ColorValue.B != 0.0)
		{
			return false;
		}
		return ColorValue.A == 1.0;
	}
/** @end */
/**
 * @begin function-default-parameters
 * @summary A defaulted FLinearColor parameter, exercised both with and without the caller supplying it. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim.
 * @topic Unreal
 */
namespace FLinearColorTest
{
	/**
	 * Blend two colors, where the second defaults to black.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionDefaultParameters
	 * @Inputs a color and an optional second color
	 * @Return the 50/50 blend of the two
	 * @Param a the first color
	 * @Param b the second color, defaulting to black
	 */
	UFUNCTION()
	FLinearColor BlendWithDefault(FLinearColor a, FLinearColor b = FLinearColor::Black)
	{
		return a * 0.5 + b * 0.5;
	}

	/**
	 * Blend a color relying on the parameter default.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionDefaultParameters
	 * @Inputs a color
	 * @Return the color blended with black
	 * @Param a the color to blend
	 */
	UFUNCTION()
	FLinearColor BlendWithImplicitDefault(FLinearColor a)
	{
		return BlendWithDefault(a);
	}

	/**
	 * Observe that an explicitly supplied second argument is used.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when the blend keeps both red and blue above 0.4
	 */
	UFUNCTION()
	bool BlendWithDefaultExplicit()
	{
		FLinearColor Result = BlendWithDefault(FLinearColor::Red, FLinearColor::Blue);

		if (Result.R <= 0.4)
		{
			return false;
		}
		return Result.B > 0.4;
	}

	/**
	 * Observe that the parameter default is applied when the caller omits it.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when white blended with black lands in (0.4, 0.6) on R
	 */
	UFUNCTION()
	bool BlendWithImplicitDefaultWhite()
	{
		FLinearColor Result = BlendWithImplicitDefault(FLinearColor::White);

		if (Result.R <= 0.4)
		{
			return false;
		}
		return Result.R < 0.6;
	}

	/**
	 * Observe that blending a default color with the black default stays at black with
	 * alpha 1.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionDefaultParameters
	 * @Inputs a default-constructed color
	 * @Return true when the blend equals (0, 0, 0, 1)
	 * @Boundary default value
	 */
	UFUNCTION()
	bool BlendWithDefaultDefaultEmpty()
	{
		FLinearColor Result = BlendWithDefault(FLinearColor());
		return Result.Equals(FLinearColor(0.0, 0.0, 0.0, 1.0), 0.001);
	}

	/**
	 * Observe that mutating the returned blend leaves the caller's argument alone.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionDefaultParameters
	 * @Inputs a color and the mutated blend built from it
	 * @Return true when the argument still reads white
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool BlendWithImplicitDefaultCopyIndependence()
	{
		FLinearColor Input = FLinearColor::White;
		FLinearColor Result = BlendWithImplicitDefault(Input);
		Result.R = 0.0;
		return Input.Equals(FLinearColor::White);
	}
}
/** @end */
/**
 * @begin function-parameters-in
 * @summary A FLinearColor passed by read-only reference, where the callee reads through the caller's value without taking a copy. C++ executes the entrypoint and checks the value it produces, so the name is part of the contract and.
 * @topic Unreal
 */
namespace FLinearColorTest
{
	/**
	 * Measure the luminance of a color passed by read-only reference.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersIn
	 * @Inputs a color
	 * @Return the luminance of the color
	 * @Param c the color to measure
	 */
	UFUNCTION()
	float AcceptColorIn(FLinearColor&in c)
	{
		return c.GetLuminance();
	}

	/**
	 * Observe that white measures as a high luminance.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersIn
	 * @Inputs none
	 * @Return true when the luminance is greater than 0.9
	 */
	UFUNCTION()
	bool AcceptColorInWhite()
	{
		FLinearColor Input = FLinearColor::White;
		return AcceptColorIn(Input) > 0.9;
	}

	/**
	 * Observe that an empty argument measures zero.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersIn
	 * @Inputs a default-constructed color
	 * @Return true when the luminance is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptColorInDefaultEmpty()
	{
		FLinearColor Empty = FLinearColor();
		return AcceptColorIn(Empty) == 0.0;
	}

	/**
	 * Observe that black measures zero.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersIn
	 * @Inputs black
	 * @Return true when the luminance is 0
	 * @Boundary black
	 */
	UFUNCTION()
	bool AcceptColorInBlackBoundary()
	{
		FLinearColor Input = FLinearColor::Black;
		return AcceptColorIn(Input) == 0.0;
	}
}
/** @end */
/**
 * @begin function-parameters-in-out
 * @summary A FLinearColor passed by mutable reference and scaled in place. C++ executes the entrypoint and checks the value written back, so the name is part of the contract and is kept verbatim. The observers cover a zero scale.
 * @topic Unreal
 */
namespace FLinearColorTest
{
	/**
	 * Scale a color in place through a mutable reference.
	 *
	 * @Kind Action
	 * @Covers FLinearColor.FunctionParametersInOut
	 * @Inputs a color and a scale factor
	 * @Return the color scaled in place
	 * @Param c the color to scale
	 * @Param amount the factor to scale by
	 */
	UFUNCTION()
	void BrightenColor(FLinearColor&inout c, float amount)
	{
		c = c * amount;
	}

	/**
	 * Observe that the caller's color is scaled in place.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersInOut
	 * @Inputs none
	 * @Return true when the value reads (1, 1, 1, 2)
	 */
	UFUNCTION()
	bool BrightenColorNominal()
	{
		FLinearColor Value = FLinearColor(0.5, 0.5, 0.5, 1.0);
		BrightenColor(Value, 2.0);
		return Value.Equals(FLinearColor(1.0, 1.0, 1.0, 2.0), 0.001);
	}

	/**
	 * Observe that a zero scale lands every component at zero.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersInOut
	 * @Inputs a color scaled by 0
	 * @Return true when the value reads (0, 0, 0, 0)
	 * @Boundary zero amount
	 */
	UFUNCTION()
	bool BrightenColorZeroAmount()
	{
		FLinearColor Value = FLinearColor(0.5, 0.5, 0.5, 1.0);
		BrightenColor(Value, 0.0);
		return Value.Equals(FLinearColor(0.0, 0.0, 0.0, 0.0), 0.001);
	}

	/**
	 * Observe that scaling an empty color doubles only the default alpha.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersInOut
	 * @Inputs a default-constructed color
	 * @Return true when the value reads (0, 0, 0, 2)
	 * @Boundary default value
	 */
	UFUNCTION()
	bool BrightenColorDefaultEmpty()
	{
		FLinearColor Value = FLinearColor();
		BrightenColor(Value, 2.0);
		return Value.Equals(FLinearColor(0.0, 0.0, 0.0, 2.0), 0.001);
	}
}
/** @end */
/**
 * @begin function-parameters-out
 * @summary FLinearColors written through out parameters, where the callee fills in the caller's variable. C++ executes each entrypoint and checks the values written, so those names are part of the contract and are kept verbatim.
 * @topic Unreal
 */
namespace FLinearColorTest
{
	/**
	 * Write a fixed color into an out parameter.
	 *
	 * @Kind Action
	 * @Covers FLinearColor.FunctionParametersOut
	 * @Inputs none
	 * @Return the out parameter filled with (0.25, 0.5, 0.75, 1.0)
	 * @Param c the color to write into
	 */
	UFUNCTION()
	void WriteColor(FLinearColor&out c)
	{
		c = FLinearColor(0.25, 0.5, 0.75, 1.0);
	}

	/**
	 * Write two named colors into two out parameters.
	 *
	 * @Kind Action
	 * @Covers FLinearColor.FunctionParametersOut
	 * @Inputs none
	 * @Return the first out parameter as red, the second as green
	 * @Param a the first color to write into
	 * @Param b the second color to write into
	 */
	UFUNCTION()
	void WriteMultipleColors(FLinearColor&out a, FLinearColor&out b)
	{
		a = FLinearColor::Red;
		b = FLinearColor::Green;
	}

	/**
	 * Observe that the single out parameter receives the written value.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the out value equals (0.25, 0.5, 0.75, 1.0)
	 */
	UFUNCTION()
	bool WriteColorNominal()
	{
		FLinearColor OutValue;
		WriteColor(OutValue);
		return OutValue.Equals(FLinearColor(0.25, 0.5, 0.75, 1.0), 0.001);
	}

	/**
	 * Observe that both out parameters receive their own color.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the first reads red and the second reads green
	 */
	UFUNCTION()
	bool WriteMultipleColorsNominal()
	{
		FLinearColor OutA;
		FLinearColor OutB;
		WriteMultipleColors(OutA, OutB);

		if (OutA != FLinearColor::Red)
		{
			return false;
		}
		return OutB == FLinearColor::Green;
	}

	/**
	 * Observe that an out parameter starts empty before it is written.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersOut
	 * @Inputs an uninitialised out value
	 * @Return true when it equals (0, 0, 0, 1)
	 * @Boundary default value
	 */
	UFUNCTION()
	bool WriteColorDefaultEmptyBeforeWrite()
	{
		FLinearColor OutValue;
		return OutValue.Equals(FLinearColor(0.0, 0.0, 0.0, 1.0));
	}

	/**
	 * Observe that mutating one out value leaves the other untouched.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersOut
	 * @Inputs two out values, the first mutated afterwards
	 * @Return true when the second still reads green and the first keeps R 1
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool WriteMultipleColorsCopyIndependence()
	{
		FLinearColor OutA;
		FLinearColor OutB;
		WriteMultipleColors(OutA, OutB);
		OutA.G = 1.0;

		if (OutB != FLinearColor::Green)
		{
			return false;
		}
		return OutA.R == 1.0;
	}
}
/** @end */
/**
 * @begin function-parameters-value
 * @summary FLinearColors passed by value, where the callee receives its own copy. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The observers cover the.
 * @topic Unreal
 */
namespace FLinearColorTest
{
	/**
	 * Double every component of a color passed by value.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersValue
	 * @Inputs a color
	 * @Return the color with every component doubled
	 * @Param c the color to scale
	 */
	UFUNCTION()
	FLinearColor AcceptColor(FLinearColor c)
	{
		return c * 2.0;
	}

	/**
	 * Blend two colors passed by value.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersValue
	 * @Inputs two colors
	 * @Return the 50/50 blend of the two
	 * @Param a the first color
	 * @Param b the second color
	 */
	UFUNCTION()
	FLinearColor BlendColors(FLinearColor a, FLinearColor b)
	{
		return a * 0.5 + b * 0.5;
	}

	/**
	 * Observe that doubling matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersValue
	 * @Inputs none
	 * @Return true when the result equals (0.4, 0.6, 0.8, 1.0)
	 */
	UFUNCTION()
	bool AcceptColorNominal()
	{
		return AcceptColor(FLinearColor(0.2, 0.3, 0.4, 0.5)).Equals(FLinearColor(0.4, 0.6, 0.8, 1.0), 0.001);
	}

	/**
	 * Observe that blending red and blue keeps both channels above 0.4.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersValue
	 * @Inputs none
	 * @Return true when R and B are both greater than 0.4
	 */
	UFUNCTION()
	bool BlendColorsNominal()
	{
		FLinearColor Result = BlendColors(FLinearColor::Red, FLinearColor::Blue);

		if (Result.R <= 0.4)
		{
			return false;
		}
		return Result.B > 0.4;
	}

	/**
	 * Observe that doubling an empty color doubles only the default alpha.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersValue
	 * @Inputs a default-constructed color
	 * @Return true when the result equals (0, 0, 0, 2)
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptColorDefaultEmpty()
	{
		return AcceptColor(FLinearColor()).Equals(FLinearColor(0.0, 0.0, 0.0, 2.0), 0.001);
	}

	/**
	 * Observe that mutating the returned blend leaves both arguments alone.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionParametersValue
	 * @Inputs two colors and the mutated blend built from them
	 * @Return true when both arguments still read red and blue
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool BlendColorsCopyIndependence()
	{
		FLinearColor A = FLinearColor::Red;
		FLinearColor B = FLinearColor::Blue;
		FLinearColor Mid = BlendColors(A, B);
		Mid.R = 0.0;

		if (!A.Equals(FLinearColor::Red))
		{
			return false;
		}
		return B.Equals(FLinearColor::Blue);
	}
}
/** @end */
/**
 * @begin function-return-values
 * @summary Colors returned from functions: a constant, a literal and a computed mix. C++ executes each entrypoint and compares the result with the native equivalent, so those names are part of the contract and are kept verbatim.
 * @topic Unreal
 */
namespace FLinearColorTest
{
	/**
	 * Return a color constant.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionReturnValues
	 * @Inputs none
	 * @Return white
	 */
	UFUNCTION()
	FLinearColor ReturnWhite()
	{
		return FLinearColor::White;
	}

	/**
	 * Return a literal color.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionReturnValues
	 * @Inputs none
	 * @Return FLinearColor(0.3, 0.6, 0.9, 1.0)
	 */
	UFUNCTION()
	FLinearColor ReturnCustomColor()
	{
		return FLinearColor(0.3, 0.6, 0.9, 1.0);
	}

	/**
	 * Return a color computed from two others.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionReturnValues
	 * @Inputs none
	 * @Return the 50/50 mix of red and blue
	 */
	UFUNCTION()
	FLinearColor ReturnComputedColor()
	{
		FLinearColor a = FLinearColor::Red;
		FLinearColor b = FLinearColor::Blue;
		return a * 0.5 + b * 0.5;
	}

	/**
	 * Observe that the constant return matches white.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals white
	 */
	UFUNCTION()
	bool ReturnWhiteNominal()
	{
		return ReturnWhite() == FLinearColor::White;
	}

	/**
	 * Observe that the literal return matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals (0.3, 0.6, 0.9, 1.0)
	 */
	UFUNCTION()
	bool ReturnCustomColorNominal()
	{
		return ReturnCustomColor().Equals(FLinearColor(0.3, 0.6, 0.9, 1.0), 0.001);
	}

	/**
	 * Observe that the computed return keeps both red and blue above 0.4.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionReturnValues
	 * @Inputs none
	 * @Return true when R and B are both greater than 0.4
	 */
	UFUNCTION()
	bool ReturnComputedColorNominal()
	{
		FLinearColor Result = ReturnComputedColor();

		if (Result.R <= 0.4)
		{
			return false;
		}
		return Result.B > 0.4;
	}

	/**
	 * Observe that a default color is not white.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionReturnValues
	 * @Inputs a default-constructed color
	 * @Return true when it differs from white
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ReturnWhiteNotDefaultEmpty()
	{
		return FLinearColor() != FLinearColor::White;
	}

	/**
	 * Observe that mutating a copy leaves a fresh computed return untouched.
	 *
	 * @Kind Observe
	 * @Covers FLinearColor.FunctionReturnValues
	 * @Inputs the computed color and a mutated copy of it
	 * @Return true when a fresh computed return still has R greater than 0.4
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ReturnComputedColorCopyIndependence()
	{
		FLinearColor Result = ReturnComputedColor();
		Result.R = 0.0;
		return ReturnComputedColor().R > 0.4;
	}
}
/** @end */
