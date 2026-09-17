/**
 * @version v1
 * @summary Observe remaining floor/ceil conversions and RoundFromZero.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe remaining floor/ceil conversions and RoundFromZero.
 * @topic Baseline
 */
// Math::CeilToFloat; Math::CeilToDouble; Math::RoundFromZero.
// Inputs: 1.1, 1.9, -1.1, 1.5, -1.5, 0.0 for float64 and float32.
// Expected observations: Floor(1.9) is 1 and Floor(-1.1) is -2. Ceil(1.1)
// is 2 and Ceil(-1.1) is -1. RoundFromZero(1.5) is 2 and RoundFromZero(-1.5)
// is -2.
// Boundary/ownership: Floor rounds down. Ceil rounds up. RoundFromZero
// pushes halfway cases away from zero. Call Math::.

namespace TS_FMath_NamespaceAndGlobalFunctions_11
{
	bool Observe_FloorToFloat_Nominal()
	{
		float64 Pos64 = Math::FloorToFloat(1.9);
		float64 Neg64 = Math::FloorToFloat(-1.1);
		float32 Pos32In = 1.9;
		float32 Neg32In = -1.1;
		float32 Pos32 = Math::FloorToFloat(Pos32In);
		float32 Neg32 = Math::FloorToFloat(Neg32In);
		return Pos64 == 1.0 && Neg64 == -2.0 && Pos32 == 1.0 && Neg32 == -2.0;
	}

	bool Observe_FloorToDouble_Nominal()
	{
		float64 Pos = Math::FloorToDouble(1.9);
		float64 Neg = Math::FloorToDouble(-1.1);
		float64 Zero = Math::FloorToDouble(0.0);
		return Pos == 1.0 && Neg == -2.0 && Zero == 0.0;
	}

	bool Observe_CeilToInt_Nominal()
	{
		int32 Pos64 = Math::CeilToInt(1.1);
		int32 Neg64 = Math::CeilToInt(-1.1);
		int32 Zero64 = Math::CeilToInt(0.0);
		float32 Pos32 = 1.1;
		float32 Neg32 = -1.1;
		int32 PosI32 = Math::CeilToInt(Pos32);
		int32 NegI32 = Math::CeilToInt(Neg32);
		return Pos64 == 2 && Neg64 == -1 && Zero64 == 0 && PosI32 == 2 && NegI32 == -1;
	}

	bool Observe_CeilToFloat_Nominal()
	{
		float64 Pos64 = Math::CeilToFloat(1.1);
		float64 Neg64 = Math::CeilToFloat(-1.1);
		float32 Pos32In = 1.1;
		float32 Neg32In = -1.1;
		float32 Pos32 = Math::CeilToFloat(Pos32In);
		float32 Neg32 = Math::CeilToFloat(Neg32In);
		return Pos64 == 2.0 && Neg64 == -1.0 && Pos32 == 2.0 && Neg32 == -1.0;
	}

	bool Observe_CeilToDouble_Nominal()
	{
		float64 Pos = Math::CeilToDouble(1.1);
		float64 Neg = Math::CeilToDouble(-1.1);
		float64 Zero = Math::CeilToDouble(0.0);
		return Pos == 2.0 && Neg == -1.0 && Zero == 0.0;
	}

	bool Observe_RoundFromZero_Nominal()
	{
		float64 Pos64 = Math::RoundFromZero(1.5);
		float64 Neg64 = Math::RoundFromZero(-1.5);
		float64 Zero64 = Math::RoundFromZero(0.0);
		float32 Pos32In = 1.5;
		float32 Neg32In = -1.5;
		float32 Zero32In = 0.0;
		float32 Pos32 = Math::RoundFromZero(Pos32In);
		float32 Neg32 = Math::RoundFromZero(Neg32In);
		float32 Zero32 = Math::RoundFromZero(Zero32In);
		return Pos64 == 2.0 && Neg64 == -2.0 && Zero64 == 0.0 && Pos32 == 2.0 && Neg32 == -2.0 && Zero32 == 0.0;
	}
}
/** @end */
