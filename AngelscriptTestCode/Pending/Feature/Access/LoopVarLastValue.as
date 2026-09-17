/**
 * @version v1
 * @summary Loop variables are isolated per for-loop. The first loop's last value is 4; a second empty loop does not reuse that counter; a zero-iteration loop leaves its marker unchanged.
 * @topic Feature
 */
/**
 * @version root
 * @summary Loop variables are isolated per for-loop. The first loop's last value is 4; a second empty loop does not reuse that counter; a zero-iteration loop leaves its marker unchanged.
 * @topic Baseline
 */
namespace AccessTest
{
	/**
	 * Two for-loops each declaring their own I.
	 *
	 * @Covers Access.Scope
	 * @Inputs none
	 * @Return nothing
	 */
	void Test()
	{
		for (int I = 0; I < 5; ++I)
		{
			int X = I;
		}
		for (int I = 0; I < 3; ++I)
		{
		}
	}

	/**
	 * Observe the last value taken by the loop-scoped counter.
	 *
	 * @Kind Observe
	 * @Covers Access.Scope
	 * @Inputs a for-loop from 0 to 4 assigning Last each pass
	 * @Return 4
	 */
	UFUNCTION()
	int LoopVarLastValue()
	{
		int Last = -1;
		for (int I = 0; I < 5; ++I)
		{
			int X = I;
			Last = X;
		}
		return Last;
	}

	/**
	 * Observe that an empty second loop leaves an outer counter untouched.
	 *
	 * @Kind Observe
	 * @Covers Access.Scope
	 * @Inputs a Count of 0 and an empty for-loop from 0 to 2
	 * @Return 0
	 * @Boundary empty second loop
	 */
	UFUNCTION()
	int EmptySecondLoopDefault()
	{
		int Count = 0;
		for (int I = 0; I < 3; ++I)
		{
		}
		return Count;
	}

	/**
	 * Observe that a zero-iteration loop never writes the marker.
	 *
	 * @Kind Observe
	 * @Covers Access.Scope
	 * @Inputs a Marker of 7 and a for-loop whose bound is 0
	 * @Return 7
	 * @Boundary zero iteration
	 */
	UFUNCTION()
	int ZeroIterationBoundary()
	{
		int Marker = 7;
		for (int I = 0; I < 0; ++I)
		{
			Marker = 0;
		}
		return Marker;
	}
}
/** @end */
