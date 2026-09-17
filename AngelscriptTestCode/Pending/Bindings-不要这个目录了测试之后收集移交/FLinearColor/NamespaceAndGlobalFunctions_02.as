/**
 * @version v1
 * @summary Observe remaining FLinearColor palette constants.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe remaining FLinearColor palette constants.
 * @topic Baseline
 */
// LucBlue is the print default blue. Each constant is distinct from Black.
// Boundary/ownership: Palette values are shared constants.

namespace TS_FLinearColor_NamespaceAndGlobalFunctions_02
{
	// FLinearColor::Green G exceeds R. Palette constant.
	bool Observe_Surface040_Nominal()
	{
		return FLinearColor::Green.G > FLinearColor::Green.R;
	}

	// FLinearColor::Blue B exceeds R. Palette constant.
	bool Observe_Surface041_Nominal()
	{
		return FLinearColor::Blue.B > FLinearColor::Blue.R;
	}

	// FLinearColor::Yellow has positive R and G. Palette constant.
	bool Observe_Surface042_Nominal()
	{
		return FLinearColor::Yellow.R > 0.0 && FLinearColor::Yellow.G > 0.0;
	}

	// FLinearColor::LucBlue has positive B and A=1. Palette constant.
	bool Observe_Surface043_Nominal()
	{
		return FLinearColor::LucBlue.B > 0.0 && FLinearColor::LucBlue.A == 1.0;
	}

	// FLinearColor::DPink is not Black. Palette constant.
	bool Observe_Surface044_Nominal()
	{
		return !(FLinearColor::DPink == FLinearColor::Black);
	}

	// FLinearColor::Teal has positive G and B. Palette constant.
	bool Observe_Surface045_Nominal()
	{
		return FLinearColor::Teal.G > 0.0 && FLinearColor::Teal.B > 0.0;
	}

	// FLinearColor::Purple has positive R and B. Palette constant.
	bool Observe_Surface046_Nominal()
	{
		return FLinearColor::Purple.R > 0.0 && FLinearColor::Purple.B > 0.0;
	}
}
/** @end */
