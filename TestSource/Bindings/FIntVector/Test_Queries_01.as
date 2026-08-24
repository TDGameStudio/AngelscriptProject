// Purpose: Observe FIntVector GetMax/GetMin/IsZero.
// AS-facing API: GetMax; GetMin; IsZero.
// Inputs: (2,8,4), (0,0,0), (-3,1,2).
// Expected observations: GetMax of (2,8,4) is 8. GetMin is 2. Zero is true
// only for (0,0,0). Negative components participate in min.
// Boundary/ownership: Queries return scalars and do not mutate the vector.

namespace TS_FIntVector_Queries_01
{
	bool Observe_GetMax_Nominal()
	{
		FIntVector Vector(2, 8, 4);
		FIntVector Zero(0, 0, 0);
		return Vector.GetMax() == 8 && Zero.GetMax() == 0;
	}

	bool Observe_GetMin_Nominal()
	{
		FIntVector Vector(2, 8, 4);
		FIntVector Negative(-3, 1, 2);
		return Vector.GetMin() == 2 && Negative.GetMin() == -3;
	}

	bool Observe_IsZero_Nominal()
	{
		return FIntVector(0, 0, 0).IsZero() && !FIntVector(0, 0, 1).IsZero();
	}
}
