/**
 * @version v1
 * @summary Observe FIntVector GetMax/GetMin/IsZero.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FIntVector GetMax/GetMin/IsZero.
 * @topic Baseline
 */
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
/** @end */
