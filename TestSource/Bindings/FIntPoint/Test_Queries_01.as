// Purpose: Observe FIntPoint GetMax and GetMin.
// AS-facing API: int32 FIntPoint.GetMax() const; int32 FIntPoint.GetMin() const;
// Inputs: (2,4), (4,2), and (0,0).
// Expected observations: GetMax of (2,4) is 4. GetMin is 2. Zero is 0 for
// both. Equal components return that component.
// Boundary/ownership: These return component values, not indices.

namespace TS_FIntPoint_Queries_01
{
	bool Observe_GetMax_Nominal()
	{
		FIntPoint Point(2, 4);
		FIntPoint Swapped(4, 2);
		FIntPoint Zero(0, 0);
		return Point.GetMax() == 4 && Swapped.GetMax() == 4 && Zero.GetMax() == 0;
	}

	bool Observe_GetMin_Nominal()
	{
		FIntPoint Point(2, 4);
		FIntPoint Swapped(4, 2);
		FIntPoint Zero(0, 0);
		return Point.GetMin() == 2 && Swapped.GetMin() == 2 && Zero.GetMin() == 0;
	}
}
