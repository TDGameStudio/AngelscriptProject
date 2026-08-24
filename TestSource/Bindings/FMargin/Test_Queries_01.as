// Purpose: Observe FMargin top-left, desired size, and axis totals.
// AS-facing API: GetTopLeft; GetDesiredSize; GetTotalSpaceAlongHorizontal;
// GetTotalSpaceAlongVertical.
// Inputs: LTRB (1,2,3,4), uniform 0, uniform 5.
// Expected observations: TopLeft is (1,2). Desired size is (4,6). Horizontal
// total is 4. Vertical total is 6. Zero margin totals are 0.
// Boundary/ownership: Queries do not mutate the margin.

namespace TS_FMargin_Queries_01
{
	bool Observe_GetTopLeft_Nominal()
	{
		FMargin Margin(1.0, 2.0, 3.0, 4.0);
		FVector2D TopLeft = Margin.GetTopLeft();
		return TopLeft.X == 1.0 && TopLeft.Y == 2.0;
	}

	bool Observe_GetDesiredSize_Nominal()
	{
		FMargin Margin(1.0, 2.0, 3.0, 4.0);
		FVector2D Size = Margin.GetDesiredSize();
		FVector2D Zero = FMargin(0.0).GetDesiredSize();
		return Size.X == 4.0 && Size.Y == 6.0 && Zero.X == 0.0;
	}

	bool Observe_GetTotalSpaceAlongHorizontal_Nominal()
	{
		FMargin Margin(1.0, 2.0, 3.0, 4.0);
		return Margin.GetTotalSpaceAlongHorizontal() == 4.0;
	}

	bool Observe_GetTotalSpaceAlongVertical_Nominal()
	{
		FMargin Margin(1.0, 2.0, 3.0, 4.0);
		return Margin.GetTotalSpaceAlongVertical() == 6.0;
	}
}
