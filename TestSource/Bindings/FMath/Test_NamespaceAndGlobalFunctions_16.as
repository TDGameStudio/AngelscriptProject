// Purpose: Observe Math absolute value, sign, and square across numeric
// widths.
// AS-facing API: Math::Abs; Math::Sign; Math::Square.
// Inputs: 3, -3, and 0 for float64/float32/int32; uint32 3 for Square.
// Expected observations: Abs(-3) is 3. Sign is -1, 0, or 1. Square(3) is 9
// and Square(0) is 0.
// Boundary/ownership: Sign(0) is 0. uint32 Square is unsigned. Call Math::.

namespace TS_FMath_NamespaceAndGlobalFunctions_16
{
	bool Observe_Abs_Nominal()
	{
		float64 AbsPos64 = Math::Abs(3.0);
		float64 AbsNeg64 = Math::Abs(-3.0);
		float64 AbsZero64 = Math::Abs(0.0);
		float32 Pos32 = 3.0;
		float32 Neg32 = -3.0;
		float32 Zero32 = 0.0;
		float32 AbsPos32 = Math::Abs(Pos32);
		float32 AbsNeg32 = Math::Abs(Neg32);
		float32 AbsZero32 = Math::Abs(Zero32);
		int32 AbsPosI = Math::Abs(int32(3));
		int32 AbsNegI = Math::Abs(int32(-3));
		int32 AbsZeroI = Math::Abs(int32(0));
		return AbsPos64 == 3.0 && AbsNeg64 == 3.0 && AbsZero64 == 0.0 && AbsPos32 == 3.0 && AbsNeg32 == 3.0 && AbsZero32 == 0.0 && AbsPosI == 3 && AbsNegI == 3 && AbsZeroI == 0;
	}

	bool Observe_Sign_Nominal()
	{
		float64 SignPos64 = Math::Sign(3.0);
		float64 SignNeg64 = Math::Sign(-3.0);
		float64 SignZero64 = Math::Sign(0.0);
		float32 Pos32 = 3.0;
		float32 Neg32 = -3.0;
		float32 Zero32 = 0.0;
		float32 SignPos32 = Math::Sign(Pos32);
		float32 SignNeg32 = Math::Sign(Neg32);
		float32 SignZero32 = Math::Sign(Zero32);
		int32 SignPosI = Math::Sign(int32(3));
		int32 SignNegI = Math::Sign(int32(-3));
		int32 SignZeroI = Math::Sign(int32(0));
		return SignPos64 == 1.0 && SignNeg64 == -1.0 && SignZero64 == 0.0 && SignPos32 == 1.0 && SignNeg32 == -1.0 && SignZero32 == 0.0 && SignPosI == 1 && SignNegI == -1 && SignZeroI == 0;
	}

	bool Observe_Square_Nominal()
	{
		float64 Sq64 = Math::Square(3.0);
		float64 SqZero64 = Math::Square(0.0);
		float32 Three32 = 3.0;
		float32 Zero32 = 0.0;
		float32 Sq32 = Math::Square(Three32);
		float32 SqZero32 = Math::Square(Zero32);
		int32 SqI = Math::Square(int32(3));
		int32 SqNegI = Math::Square(int32(-3));
		uint32 SqU = Math::Square(uint32(3));
		return Sq64 == 9.0 && SqZero64 == 0.0 && Sq32 == 9.0 && SqZero32 == 0.0 && SqI == 9 && SqNegI == 9 && SqU == 9;
	}
}
