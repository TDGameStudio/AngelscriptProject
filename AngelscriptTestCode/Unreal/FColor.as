/**
 * @version v1
 * @summary FColor host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FColor
 *
 * container-api
 * fcolor-dwcolor-packed-storage
 * init-from-string
 * reinterpret-as-linear
 * add-assign
 * to-hex
 * from-rgbe
 * from-hex
 * to-f-color
 * make-random-color
 * make-red-to-green-color-from-scalar
 * make-from-color-temperature
 * fcolor-white
 * fcolor-black
 * fcolor-transparent
 * fcolor-red
 * fcolor-green
 * fcolor-blue
 * fcolor-yellow
 * fcolor-cyan
 * fcolor-magenta
 * fcolor-orange
 * fcolor-purple
 * fcolor-turquoise
 * fcolor-silver
 * fcolor-emerald
 * equality
 */
/**
 * @begin container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveValueNominal
 * @summary Observe the container API.
 * @covers FColor.container-api
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FColor Value(uint DWColor); uint FColor.DWColor;
// bool FColor.InitFromString(const FString& SourceString);
// FLinearColor FColor.ReinterpretAsLinear() const;
// Inputs: RGBA (255, 128, 64) with omitted alpha, packed DWColor from that
// value, UE color text "(R=255,G=0,B=0,A=255)", empty text, and Black.
// Expected observations: Omitted alpha is 255. Packed constructor round-trips
// DWColor. InitFromString returns true for valid text and false for empty.
// ReinterpretAsLinear maps 255 toward 1.0 without sRGB.
// Boundary/ownership: InitFromString mutates the receiver. ReinterpretAsLinear
// returns a new FLinearColor and does not convert through sRGB.
// FColor(R,G,B) default alpha 255, explicit alpha, packed DWColor constructor.
// Inputs: (255,128,64) and (255,128,64,128). Oracle: channels and packed round-trip.
bool ObserveValueNominal()
{
	FColor WithDefaultAlpha(255, 128, 64);
	FColor WithExplicitAlpha(255, 128, 64, 128);
	FColor Packed(WithDefaultAlpha.DWColor);
	return WithDefaultAlpha.A == 255 && WithDefaultAlpha.R == 255 && WithExplicitAlpha.A == 128 && Packed == WithDefaultAlpha;
}
/** @end */
/**
 * @begin fcolor-dwcolor-packed-storage
 * @summary FColor.DWColor packed storage.
 * @topic Unreal
 */
/**
 * @function ObserveSurface003Nominal
 * @summary FColor.DWColor packed storage.
 * @covers FColor.fcolor-dwcolor-packed-storage
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveSurface003Nominal()
{
	FColor Color(1, 2, 3, 4);
	uint Packed = Color.DWColor;
	FColor Restored;
	Restored.DWColor = Packed;
	return Restored == Color && Packed != 0;
}
/** @end */
/**
 * @begin init-from-string
 * @summary FColor.InitFromString.
 * @topic Unreal
 */
/**
 * @function ObserveInitFromStringNominal
 * @summary FColor.InitFromString.
 * @covers FColor.init-from-string
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveInitFromStringNominal()
{
	FColor Parsed;
	bool bValid = Parsed.InitFromString("(R=255,G=0,B=0,A=255)");
	FColor EmptyTarget;
	bool bEmpty = EmptyTarget.InitFromString("");
	return bValid && Parsed.R == 255 && Parsed.G == 0 && Parsed.B == 0 && Parsed.A == 255 && !bEmpty;
}
/** @end */
/**
 * @begin reinterpret-as-linear
 * @summary Oracle: Red.R is 1.0, Black is 0.
 * @topic Unreal
 */
/**
 * @function ObserveReinterpretAsLinearNominal
 * @summary Oracle: Red.R is 1.0, Black is 0.
 * @covers FColor.reinterpret-as-linear
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveReinterpretAsLinearNominal()
{
	FColor Red(255, 0, 0, 255);
	FLinearColor Linear = Red.ReinterpretAsLinear();
	FLinearColor BlackLinear = FColor::Black.ReinterpretAsLinear();
	return Linear.R == 1.0 && Linear.G == 0.0 && Linear.B == 0.0 && Linear.A == 1.0 && BlackLinear.R == 0.0 && BlackLinear.G == 0.0 && BlackLinear.B == 0.0;
}
/** @end */
/**
 * @begin add-assign
 * @summary channel.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary channel.
 * @covers FColor.add-assign
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal()
{
	FColor Color(10, 20, 30, 40);
	FColor ColorB(1, 2, 3, 4);
	FColor CopiedAddend = ColorB;
	Color += ColorB;
	FColor Restored(10, 20, 30, 40);
	Restored += FColor::Black;
	return Color.R == 11 && Color.G == 22 && Color.B == 33 && Color.A == 44 && ColorB.R == CopiedAddend.R && ColorB.G == CopiedAddend.G && Restored.R == 10 && Restored.G == 20 && Restored.B == 30;
}
/** @end */
/**
 * @begin to-hex
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveToHexNominal
 * @summary Observe the container API.
 * @covers FColor.to-hex
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: FColor(255, 0, 0, 255), empty/black, hex "FF0000" and "#FF0000FF",
// invalid "not-hex", and bSRGB true/false.
// Expected observations: ToHex is an 8-digit RRGGBBAA string. FromHex of a
// valid RGB string yields red. Invalid text does not match Red. ToFColor
// returns a byte color from linear white for both sRGB flags.
// Boundary/ownership: FromHex copies hex digits; the source FString is not
// retained. ToFColor optionally applies sRGB transfer before quantization.
bool ObserveToHexNominal()
{
	FColor Red(255, 0, 0, 255);
	FString Hex = Red.ToHex();
	FString BlackHex = FColor::Black.ToHex();
	return Hex == "FF0000FF" && BlackHex == "000000FF";
}
/** @end */
/**
 * @begin from-rgbe
 * @summary retained.
 * @topic Unreal
 */
/**
 * @function ObserveFromRGBENominal
 * @summary retained.
 * @covers FColor.from-rgbe
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveFromRGBENominal()
{
	FColor Packed(128, 64, 32, 128);
	FLinearColor Decoded = Packed.FromRGBE();
	FLinearColor BlackDecoded = FColor(0, 0, 0, 0).FromRGBE();
	return Decoded.R > 0.0 && BlackDecoded.R == 0.0 && BlackDecoded.G == 0.0 && BlackDecoded.B == 0.0;
}
/** @end */
/**
 * @begin from-hex
 * @summary retained.
 * @topic Unreal
 */
/**
 * @function ObserveFromHexNominal
 * @summary retained.
 * @covers FColor.from-hex
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveFromHexNominal()
{
	FColor FromRgb = FColor::FromHex("FF0000");
	FColor FromPrefixed = FColor::FromHex("#FF0000FF");
	FColor Invalid = FColor::FromHex("not-hex");
	return FromRgb.R == 255 && FromRgb.G == 0 && FromRgb.B == 0 && FromRgb.A == 255 && FromPrefixed.R == 255 && FromPrefixed.A == 255 && Invalid.R == 0 && Invalid.G == 0 && Invalid.B == 0 && Invalid.A == 0;
}
/** @end */
/**
 * @begin to-f-color
 * @summary retained.
 * @topic Unreal
 */
/**
 * @function ObserveToFColorNominal
 * @summary retained.
 * @covers FColor.to-f-color
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveToFColorNominal()
{
	FLinearColor White(1.0, 1.0, 1.0, 1.0);
	FColor WithSrgb = White.ToFColor(true);
	FColor WithoutSrgb = White.ToFColor(false);
	FLinearColor Zero(0.0, 0.0, 0.0, 0.0);
	FColor ZeroColor = Zero.ToFColor(false);
	return WithSrgb.R == 255 && WithSrgb.G == 255 && WithSrgb.B == 255 && WithoutSrgb.R == 255 && ZeroColor.R == 0 && ZeroColor.A == 0;
}
/** @end */
/**
 * @begin make-random-color
 * @summary FColor::MakeRandomColor.
 * @topic Unreal
 */
/**
 * @function ObserveMakeRandomColorNominal
 * @summary FColor::MakeRandomColor.
 * @covers FColor.make-random-color
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
 is 255 (opaque). Shared factory, no fixture.
bool ObserveMakeRandomColorNominal()
{
	FColor First = FColor::MakeRandomColor();
	FColor Second = FColor::MakeRandomColor();
	return First.A == 255 && Second.A == 255;
}
/** @end */
/**
 * @begin make-red-to-green-color-from-scalar
 * @summary Oracle:
 * @topic Unreal
 */
/**
 * @function ObserveMakeRedToGreenColorFromScalarNominal
 * @summary Oracle:
 * @covers FColor.make-red-to-green-color-from-scalar
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
 0 is (255,0,0), 1 is (0,255,0), 0.5 is (255,255,0).
bool ObserveMakeRedToGreenColorFromScalarNominal()
{
	FColor AtZero = FColor::MakeRedToGreenColorFromScalar(0.0);
	FColor AtOne = FColor::MakeRedToGreenColorFromScalar(1.0);
	FColor Mid = FColor::MakeRedToGreenColorFromScalar(0.5);
	return AtZero.R == 255 && AtZero.G == 0 && AtZero.B == 0 && AtOne.R == 0 && AtOne.G == 255 && AtOne.B == 0 && Mid.R == 255 && Mid.G == 255 && Mid.B == 0 && Mid.A == 255;
}
/** @end */
/**
 * @begin make-from-color-temperature
 * @summary FColor::MakeFromColorTemperature.
 * @topic Unreal
 */
/**
 * @function ObserveMakeFromColorTemperatureNominal
 * @summary FColor::MakeFromColorTemperature.
 * @covers FColor.make-from-color-temperature
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMakeFromColorTemperatureNominal()
{
	FColor Daylight = FColor::MakeFromColorTemperature(6500.0);
	FColor Warm = FColor::MakeFromColorTemperature(2000.0);
	return Daylight.A == 255 && Warm.A == 255 && !(Daylight == Warm);
}
/** @end */
/**
 * @begin fcolor-white
 * @summary FColor::White.
 * @topic Unreal
 */
/**
 * @function ObserveSurface014Nominal
 * @summary FColor::White.
 * @covers FColor.fcolor-white
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface014Nominal()
{
	FColor White = FColor::White;
	return White.R == 255 && White.G == 255 && White.B == 255 && White.A == 255;
}
/** @end */
/**
 * @begin fcolor-black
 * @summary FColor::Black.
 * @topic Unreal
 */
/**
 * @function ObserveSurface015Nominal
 * @summary FColor::Black.
 * @covers FColor.fcolor-black
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface015Nominal()
{
	FColor Black = FColor::Black;
	return Black.R == 0 && Black.G == 0 && Black.B == 0 && Black.A == 255;
}
/** @end */
/**
 * @begin fcolor-transparent
 * @summary FColor::Transparent.
 * @topic Unreal
 */
/**
 * @function ObserveSurface016Nominal
 * @summary FColor::Transparent.
 * @covers FColor.fcolor-transparent
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface016Nominal()
{
	FColor Transparent = FColor::Transparent;
	return Transparent.R == 0 && Transparent.G == 0 && Transparent.B == 0 && Transparent.A == 0;
}
/** @end */
/**
 * @begin fcolor-red
 * @summary FColor::Red.
 * @topic Unreal
 */
/**
 * @function ObserveSurface017Nominal
 * @summary FColor::Red.
 * @covers FColor.fcolor-red
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface017Nominal()
{
	FColor Red = FColor::Red;
	return Red.R == 255 && Red.G == 0 && Red.B == 0 && Red.A == 255;
}
/** @end */
/**
 * @begin fcolor-green
 * @summary FColor::Green.
 * @topic Unreal
 */
/**
 * @function ObserveSurface018Nominal
 * @summary FColor::Green.
 * @covers FColor.fcolor-green
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface018Nominal()
{
	FColor Green = FColor::Green;
	return Green.G == 255 && Green.R == 0 && Green.B == 0 && Green.A == 255;
}
/** @end */
/**
 * @begin fcolor-blue
 * @summary FColor::Blue.
 * @topic Unreal
 */
/**
 * @function ObserveSurface019Nominal
 * @summary FColor::Blue.
 * @covers FColor.fcolor-blue
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface019Nominal()
{
	FColor Blue = FColor::Blue;
	return Blue.B == 255 && Blue.R == 0 && Blue.G == 0 && Blue.A == 255;
}
/** @end */
/**
 * @begin fcolor-yellow
 * @summary FColor::Yellow.
 * @topic Unreal
 */
/**
 * @function ObserveSurface020Nominal
 * @summary FColor::Yellow.
 * @covers FColor.fcolor-yellow
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface020Nominal()
{
	FColor Yellow = FColor::Yellow;
	return Yellow.R == 255 && Yellow.G == 255 && Yellow.B == 0 && Yellow.A == 255;
}
/** @end */
/**
 * @begin fcolor-cyan
 * @summary FColor::Cyan.
 * @topic Unreal
 */
/**
 * @function ObserveSurface021Nominal
 * @summary FColor::Cyan.
 * @covers FColor.fcolor-cyan
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface021Nominal()
{
	FColor Cyan = FColor::Cyan;
	return Cyan.R == 0 && Cyan.G == 255 && Cyan.B == 255 && Cyan.A == 255;
}
/** @end */
/**
 * @begin fcolor-magenta
 * @summary FColor::Magenta.
 * @topic Unreal
 */
/**
 * @function ObserveSurface022Nominal
 * @summary FColor::Magenta.
 * @covers FColor.fcolor-magenta
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface022Nominal()
{
	FColor Magenta = FColor::Magenta;
	return Magenta.R == 255 && Magenta.G == 0 && Magenta.B == 255 && Magenta.A == 255;
}
/** @end */
/**
 * @begin fcolor-orange
 * @summary FColor::Orange.
 * @topic Unreal
 */
/**
 * @function ObserveSurface023Nominal
 * @summary FColor::Orange.
 * @covers FColor.fcolor-orange
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface023Nominal()
{
	FColor Orange = FColor::Orange;
	return Orange.R == 243 && Orange.G == 156 && Orange.B == 18 && Orange.A == 255;
}
/** @end */
/**
 * @begin fcolor-purple
 * @summary FColor::Purple.
 * @topic Unreal
 */
/**
 * @function ObserveSurface024Nominal
 * @summary FColor::Purple.
 * @covers FColor.fcolor-purple
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface024Nominal()
{
	FColor Purple = FColor::Purple;
	return Purple.R == 169 && Purple.G == 7 && Purple.B == 228 && Purple.A == 255 && !(Purple == FColor::Red);
}
/** @end */
/**
 * @begin fcolor-turquoise
 * @summary FColor::Turquoise.
 * @topic Unreal
 */
/**
 * @function ObserveSurface025Nominal
 * @summary FColor::Turquoise.
 * @covers FColor.fcolor-turquoise
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface025Nominal()
{
	FColor Turquoise = FColor::Turquoise;
	return Turquoise.R == 26 && Turquoise.G == 188 && Turquoise.B == 156 && Turquoise.A == 255;
}
/** @end */
/**
 * @begin fcolor-silver
 * @summary FColor::Silver.
 * @topic Unreal
 */
/**
 * @function ObserveSurface026Nominal
 * @summary FColor::Silver.
 * @covers FColor.fcolor-silver
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface026Nominal()
{
	FColor Silver = FColor::Silver;
	return Silver.R == 189 && Silver.G == 195 && Silver.B == 199 && Silver.A == 255;
}
/** @end */
/**
 * @begin fcolor-emerald
 * @summary FColor::Emerald.
 * @topic Unreal
 */
/**
 * @function ObserveSurface027Nominal
 * @summary FColor::Emerald.
 * @covers FColor.fcolor-emerald
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface027Nominal()
{
	FColor Emerald = FColor::Emerald;
	return Emerald.R == 46 && Emerald.G == 204 && Emerald.B == 113 && Emerald.A == 255 && Emerald.G > Emerald.R;
}
/** @end */
/**
 * @begin equality
 * @summary returns a bool and is not the mutating += path.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary returns a bool and is not the mutating += path.
 * @covers FColor.equality
 * @inputs FColor values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FColor Color(255, 128, 64, 255);
	FColor ColorB(255, 128, 64, 255);
	FColor AlphaBoundary(255, 128, 64, 0);
	return Color == ColorB && !(Color == FColor::Black) && !(Color == AlphaBoundary);
}
/** @end */
