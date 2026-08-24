// Purpose: Observe FColor factory helpers and the first group of named
// opaque color constants.
// AS-facing API: FColor FColor::MakeRandomColor();
// FColor FColor::MakeRedToGreenColorFromScalar(float32 Scalar);
// FColor FColor::MakeFromColorTemperature(float32 Temp);
// FColor FColor::White; FColor FColor::Black; FColor FColor::Transparent;
// FColor FColor::Red; FColor FColor::Green; FColor FColor::Blue; FColor FColor::Yellow;
// Inputs: Scalar 0.0, 0.5, and 1.0; temperature 6500; named constants as
// explicit operands.
// Expected observations: Random color is opaque. Scalar 0 leans red, 1 leans
// green. White.R is 255, Black.R is 0, Transparent.A is 0. Named constants
// differ from each other.
// Boundary/ownership: Constants are shared values, not unique allocations.
// Scalar is expected in 0..1; temperature is Kelvin.

namespace TS_FColor_NamespaceAndGlobalFunctions_01
{
	// FColor::MakeRandomColor. Oracle: A is 255 (opaque). Shared factory, no fixture.
	bool Observe_MakeRandomColor_Nominal()
	{
		FColor First = FColor::MakeRandomColor();
		FColor Second = FColor::MakeRandomColor();
		return First.A == 255 && Second.A == 255;
	}

	// FColor::MakeRedToGreenColorFromScalar. Inputs: 0.0, 0.5, 1.0.
	// Oracle: 0 is (255,0,0), 1 is (0,255,0), 0.5 is (255,255,0).
	bool Observe_MakeRedToGreenColorFromScalar_Nominal()
	{
		FColor AtZero = FColor::MakeRedToGreenColorFromScalar(0.0);
		FColor AtOne = FColor::MakeRedToGreenColorFromScalar(1.0);
		FColor Mid = FColor::MakeRedToGreenColorFromScalar(0.5);
		return AtZero.R == 255 && AtZero.G == 0 && AtZero.B == 0 && AtOne.R == 0 && AtOne.G == 255 && AtOne.B == 0 && Mid.R == 255 && Mid.G == 255 && Mid.B == 0 && Mid.A == 255;
	}

	// FColor::MakeFromColorTemperature. Inputs: 6500K and 2000K. Oracle: both opaque and distinct.
	bool Observe_MakeFromColorTemperature_Nominal()
	{
		FColor Daylight = FColor::MakeFromColorTemperature(6500.0);
		FColor Warm = FColor::MakeFromColorTemperature(2000.0);
		return Daylight.A == 255 && Warm.A == 255 && !(Daylight == Warm);
	}

	// FColor::White. Oracle: (255,255,255,255). Shared constant.
	bool Observe_Surface014_Nominal()
	{
		FColor White = FColor::White;
		return White.R == 255 && White.G == 255 && White.B == 255 && White.A == 255;
	}

	// FColor::Black. Oracle: (0,0,0,255). Shared constant.
	bool Observe_Surface015_Nominal()
	{
		FColor Black = FColor::Black;
		return Black.R == 0 && Black.G == 0 && Black.B == 0 && Black.A == 255;
	}

	// FColor::Transparent. Oracle: A is 0. Shared constant.
	bool Observe_Surface016_Nominal()
	{
		FColor Transparent = FColor::Transparent;
		return Transparent.R == 0 && Transparent.G == 0 && Transparent.B == 0 && Transparent.A == 0;
	}

	// FColor::Red. Oracle: (255,0,0). Shared constant.
	bool Observe_Surface017_Nominal()
	{
		FColor Red = FColor::Red;
		return Red.R == 255 && Red.G == 0 && Red.B == 0 && Red.A == 255;
	}

	// FColor::Green. Oracle: (0,255,0). Shared constant.
	bool Observe_Surface018_Nominal()
	{
		FColor Green = FColor::Green;
		return Green.G == 255 && Green.R == 0 && Green.B == 0 && Green.A == 255;
	}

	// FColor::Blue. Oracle: (0,0,255). Shared constant.
	bool Observe_Surface019_Nominal()
	{
		FColor Blue = FColor::Blue;
		return Blue.B == 255 && Blue.R == 0 && Blue.G == 0 && Blue.A == 255;
	}

	// FColor::Yellow. Oracle: (255,255,0,255). Shared constant.
	bool Observe_Surface020_Nominal()
	{
		FColor Yellow = FColor::Yellow;
		return Yellow.R == 255 && Yellow.G == 255 && Yellow.B == 0 && Yellow.A == 255;
	}
}
