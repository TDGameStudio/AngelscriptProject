// Purpose: Observe Zero and Ratio helpers.
// AS-facing API: FTimespan FTimespan::Zero();
// float64 FTimespan::Ratio(FTimespan Dividend, FTimespan Divisor);
// Inputs: Zero, dividend 2 hours, divisor 1 hour, and equal spans as ratio 1.
// Expected observations: Zero.IsZero is true. Ratio of 2h/1h is 2.0. Ratio of
// equal spans is 1.0.
// Boundary/ownership: Ratio does not mutate either duration. A zero divisor is
// a diagnostic boundary and is not invoked in the nominal path.

namespace TS_FTimespan_NamespaceAndGlobalFunctions_01
{
	bool Observe_Zero_Nominal()
	{
		FTimespan Zero = FTimespan::Zero();
		return Zero.IsZero() && Zero.GetTicks() == 0;
	}

	bool Observe_Ratio_Nominal()
	{
		float64 Two = FTimespan::Ratio(FTimespan::FromHours(2.0), FTimespan::FromHours(1.0));
		float64 One = FTimespan::Ratio(FTimespan::FromMinutes(30.0), FTimespan::FromMinutes(30.0));
		return Two == 2.0 && One == 1.0;
	}
}
