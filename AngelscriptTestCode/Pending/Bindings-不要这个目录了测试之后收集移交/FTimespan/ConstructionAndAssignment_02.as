/**
 * @version v1
 * @summary Observe in-place remainder assignment of FTimespan.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe in-place remainder assignment of FTimespan.
 * @topic Baseline
 */
// as a restoration check after a second %= of an exact multiple.
// Expected observations: After %= 1h, Span is 30 minutes. Other is unchanged.
// A subsequent %= of 30 minutes by 30 minutes yields zero.
// Boundary/ownership: %= mutates Span and does not consume Other.

namespace TS_FTimespan_ConstructionAndAssignment_02
{
	// FTimespan %= FTimespan. Inputs 90 minutes %= 1 hour, then %= 30 minutes.
	// Remainder is 30 minutes; Other is unchanged; exact multiple becomes zero.
	// Mutates Span only.
	bool Observe_Surface015_Nominal()
	{
		FTimespan Span = FTimespan::FromMinutes(90.0);
		FTimespan Other = FTimespan::FromHours(1.0);
		FTimespan OriginalOther = Other;
		Span %= Other;
		bool bRemainderIsThirty = Span.GetTotalMinutes() == 30.0;
		Span %= FTimespan::FromMinutes(30.0);
		return bRemainderIsThirty && Other == OriginalOther && Span.IsZero();
	}
}
/** @end */
