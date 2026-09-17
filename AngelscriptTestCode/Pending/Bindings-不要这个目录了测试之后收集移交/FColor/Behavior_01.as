/**
 * @version v1
 * @summary Observe FColor byte and packed constructors, DWColor storage, InitFromString success/failure, and ReinterpretAsLinear.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FColor byte and packed constructors, DWColor storage, InitFromString success/failure, and ReinterpretAsLinear.
 * @topic Baseline
 */
// FColor Value(uint DWColor); uint FColor.DWColor;
// bool FColor.InitFromString(const FString& SourceString);
// FLinearColor FColor.ReinterpretAsLinear() const;
// Inputs: RGBA (255, 128, 64) with omitted alpha, packed DWColor from that
// value, UE color text "(R=255,G=0,B=0,A=255)", empty text, and Black.
// Expected observations: Omitted alpha is 255. Packed constructor round-trips
// DWColor. InitFromString returns true for valid text and false for empty.
// ReinterpretAsLinear maps 255 toward 1.0 without sRGB.
// Boundary/ownership: InitFromString mutates the receiver. ReinterpretAsLinear
// returns a new FLinearColor and does not convert through sRGB.

namespace TS_FColor_Behavior_01
{
	// FColor(R,G,B) default alpha 255, explicit alpha, packed DWColor constructor.
	// Inputs: (255,128,64) and (255,128,64,128). Oracle: channels and packed round-trip.
	bool Observe_Value_Nominal()
	{
		FColor WithDefaultAlpha(255, 128, 64);
		FColor WithExplicitAlpha(255, 128, 64, 128);
		FColor Packed(WithDefaultAlpha.DWColor);
		return WithDefaultAlpha.A == 255 && WithDefaultAlpha.R == 255 && WithExplicitAlpha.A == 128 && Packed == WithDefaultAlpha;
	}

	// FColor.DWColor packed storage. Inputs: (1,2,3,4). Oracle: assign DWColor round-trips equality.
	bool Observe_Surface003_Nominal()
	{
		FColor Color(1, 2, 3, 4);
		uint Packed = Color.DWColor;
		FColor Restored;
		Restored.DWColor = Packed;
		return Restored == Color && Packed != 0;
	}

	// FColor.InitFromString. Inputs: "(R=255,G=0,B=0,A=255)" and empty. Oracle: valid parses R=255, empty fails.
	bool Observe_InitFromString_Nominal()
	{
		FColor Parsed;
		bool bValid = Parsed.InitFromString("(R=255,G=0,B=0,A=255)");
		FColor EmptyTarget;
		bool bEmpty = EmptyTarget.InitFromString("");
		return bValid && Parsed.R == 255 && Parsed.G == 0 && Parsed.B == 0 && Parsed.A == 255 && !bEmpty;
	}

	// FColor.ReinterpretAsLinear maps bytes / 255 without sRGB. Inputs: Red and Black.
	// Oracle: Red.R is 1.0, Black is 0. Value return, no fixture.
	bool Observe_ReinterpretAsLinear_Nominal()
	{
		FColor Red(255, 0, 0, 255);
		FLinearColor Linear = Red.ReinterpretAsLinear();
		FLinearColor BlackLinear = FColor::Black.ReinterpretAsLinear();
		return Linear.R == 1.0 && Linear.G == 0.0 && Linear.B == 0.0 && Linear.A == 1.0 && BlackLinear.R == 0.0 && BlackLinear.G == 0.0 && BlackLinear.B == 0.0;
	}
}
/** @end */
