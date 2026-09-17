/**
 * @version v1
 * @summary Observe Math truncation, rounding, and FloorToInt across floating widths. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe Math truncation, rounding, and FloorToInt across floating widths. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// Math::RoundToFloat; Math::RoundToDouble; Math::FloorToInt.
// Inputs: 1.9, -1.9, 1.5, 0.0 for float64 and float32.
// Expected observations: Trunc toward zero yields 1 and -1. RoundToInt(1.5)
// is 2. FloorToInt(1.9) is 1 and FloorToInt(-1.1) is -2. Zero stays 0.
// Boundary/ownership: Trunc preserves sign and drops the fraction. Floor
// rounds down. Call Math::. DefaultSafe; no fixture.

namespace TS_FMath_NamespaceAndGlobalFunctions_10
{
	bool Observe_TruncToFloat_Nominal()
	{
		float64 Pos64 = Math::TruncToFloat(1.9);
		float64 Neg64 = Math::TruncToFloat(-1.9);
		float64 Zero64 = Math::TruncToFloat(0.0);
		float32 Pos32In = 1.9;
		float32 Neg32In = -1.9;
		float32 Zero32In = 0.0;
		float32 Pos32 = Math::TruncToFloat(Pos32In);
		float32 Neg32 = Math::TruncToFloat(Neg32In);
		float32 Zero32 = Math::TruncToFloat(Zero32In);
		return Pos64 == 1.0 && Neg64 == -1.0 && Zero64 == 0.0 && Pos32 == 1.0 && Neg32 == -1.0 && Zero32 == 0.0;
	}

	bool Observe_TruncToDouble_Nominal()
	{
		float64 Pos = Math::TruncToDouble(1.9);
		float64 Neg = Math::TruncToDouble(-1.9);
		float64 Zero = Math::TruncToDouble(0.0);
		return Pos == 1.0 && Neg == -1.0 && Zero == 0.0;
	}

	bool Observe_RoundToInt_Nominal()
	{
		int32 Pos64 = Math::RoundToInt(1.5);
		int32 Neg64 = Math::RoundToInt(-1.1);
		int32 Zero64 = Math::RoundToInt(0.0);
		float32 Pos32 = 1.5;
		float32 Neg32 = -1.1;
		int32 PosI32 = Math::RoundToInt(Pos32);
		int32 NegI32 = Math::RoundToInt(Neg32);
		return Pos64 == 2 && Neg64 == -1 && Zero64 == 0 && PosI32 == 2 && NegI32 == -1;
	}

	bool Observe_RoundToFloat_Nominal()
	{
		float64 Pos64 = Math::RoundToFloat(1.5);
		float64 Neg64 = Math::RoundToFloat(-1.1);
		float32 Pos32In = 1.5;
		float32 Neg32In = -1.1;
		float32 Pos32 = Math::RoundToFloat(Pos32In);
		float32 Neg32 = Math::RoundToFloat(Neg32In);
		return Pos64 == 2.0 && Neg64 == -1.0 && Pos32 == 2.0 && Neg32 == -1.0;
	}

	bool Observe_RoundToDouble_Nominal()
	{
		float64 Pos = Math::RoundToDouble(1.5);
		float64 Neg = Math::RoundToDouble(-1.1);
		float64 Zero = Math::RoundToDouble(0.0);
		return Pos == 2.0 && Neg == -1.0 && Zero == 0.0;
	}

	bool Observe_FloorToInt_Nominal()
	{
		int32 Pos64 = Math::FloorToInt(1.9);
		int32 Neg64 = Math::FloorToInt(-1.1);
		int32 Zero64 = Math::FloorToInt(0.0);
		float32 Pos32 = 1.9;
		float32 Neg32 = -1.1;
		int32 PosI32 = Math::FloorToInt(Pos32);
		int32 NegI32 = Math::FloorToInt(Neg32);
		return Pos64 == 1 && Neg64 == -2 && Zero64 == 0 && PosI32 == 1 && NegI32 == -2;
	}
}
/** @end */
