// Purpose: Observe Math pairwise min/max and three-argument Max3.
// AS-facing API: Math::Min; Math::Max3; Math::Max.
// Inputs: 3 vs -1 for signed pairs; 3 vs 1 for uint32; Max3(1, 5, 3);
// equal pair 4 vs 4; zero.
// Expected observations: Min of 3 and -1 is -1. Max of 3 and -1 is 3.
// uint32 Min of 3 and 1 is 1. Max3 of 1, 5, 3 is 5. Equal inputs return
// that value.
// Boundary/ownership: Overloads are selected by typed locals. Results are
// values; arguments are not mutated.

namespace TS_FMath_Queries_03
{
	bool Observe_Min_Nominal()
	{
		float64 Min64 = Math::Min(3.0, -1.0);
		float64 Equal64 = Math::Min(4.0, 4.0);
		float32 Three32 = 3.0;
		float32 Neg32 = -1.0;
		float32 Min32 = Math::Min(Three32, Neg32);
		int32 MinI = Math::Min(int32(3), int32(-1));
		uint32 MinU = Math::Min(uint32(3), uint32(1));
		return Min64 == -1.0 && Equal64 == 4.0 && Min32 == -1.0 && MinI == -1 && MinU == 1;
	}

	bool Observe_Max3_Nominal()
	{
		float64 Max3_64 = Math::Max3(1.0, 5.0, 3.0);
		float64 Max3First64 = Math::Max3(9.0, 1.0, 2.0);
		float32 A32 = 1.0;
		float32 B32 = 5.0;
		float32 C32 = 3.0;
		float32 Max3_32 = Math::Max3(A32, B32, C32);
		return Max3_64 == 5.0 && Max3First64 == 9.0 && Max3_32 == 5.0;
	}

	bool Observe_Max_Nominal()
	{
		float64 Max64 = Math::Max(3.0, -1.0);
		float64 Equal64 = Math::Max(4.0, 4.0);
		float32 Three32 = 3.0;
		float32 Neg32 = -1.0;
		float32 Max32 = Math::Max(Three32, Neg32);
		int32 MaxI = Math::Max(int32(3), int32(-1));
		uint32 MaxU = Math::Max(uint32(3), uint32(1));
		return Max64 == 3.0 && Equal64 == 4.0 && Max32 == 3.0 && MaxI == 3 && MaxU == 3;
	}
}
