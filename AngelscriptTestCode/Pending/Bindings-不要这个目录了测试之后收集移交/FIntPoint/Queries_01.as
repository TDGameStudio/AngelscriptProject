/**
 * @version v1
 * @summary Observe FIntPoint GetMax and GetMin.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FIntPoint GetMax and GetMin.
 * @topic Baseline
 */
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
/** @end */
