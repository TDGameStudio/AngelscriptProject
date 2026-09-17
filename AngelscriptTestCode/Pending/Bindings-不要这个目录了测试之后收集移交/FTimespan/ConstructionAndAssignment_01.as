/**
 * @version v1
 * @summary Observe FTimespan arithmetic returning new values and mutating compound assignment, including negation.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FTimespan arithmetic returning new values and mutating compound assignment, including negation.
 * @topic Baseline
 */
// Span * Scalar; Span *= Scalar; Span / Scalar; Span /= Scalar; Span % Other;
// Inputs: One hour and 30 minutes, scalar 2.0, zero timespan, and a copied
// original for independence.
// Expected observations: + of 1h and 30m is 90 minutes. += mutates in place.
// Negation of a positive span is negative. * 2 doubles hours. % of 90m by 1h
// is 30m.
// Boundary/ownership: Value-returning operators do not mutate operands.
// Compound assignment mutates Span only.

namespace TS_FTimespan_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FTimespan Span = FTimespan::FromHours(1.0);
		FTimespan Other = FTimespan::FromMinutes(30.0);
		FTimespan Sum = Span + Other;
		FTimespan Original = Span;
		FTimespan Negated = -Span;
		return Sum.GetTotalMinutes() == 90.0 && Negated.GetTotalHours() == -1.0 && Original.GetTotalHours() == 1.0;
	}

	bool Observe_AddAssign_Nominal()
	{
		FTimespan Span = FTimespan::FromHours(1.0);
		FTimespan Other = FTimespan::FromMinutes(30.0);
		Span += Other;
		return Span.GetTotalMinutes() == 90.0 && Other.GetTotalMinutes() == 30.0;
	}

	bool Observe_SubtractAssign_Nominal()
	{
		FTimespan Span = FTimespan::FromHours(1.0);
		FTimespan Other = FTimespan::FromMinutes(30.0);
		FTimespan Difference = Span - Other;
		Span -= Other;
		return Difference.GetTotalMinutes() == 30.0 && Span.GetTotalMinutes() == 30.0;
	}

	bool Observe_MultiplyAssign_Nominal()
	{
		FTimespan Span = FTimespan::FromHours(1.0);
		FTimespan Scaled = Span * 2.0;
		Span *= 2.0;
		return Scaled.GetTotalHours() == 2.0 && Span.GetTotalHours() == 2.0;
	}

	bool Observe_DivideAssign_Nominal()
	{
		FTimespan Span = FTimespan::FromHours(2.0);
		FTimespan Divided = Span / 2.0;
		Span /= 2.0;
		FTimespan Ninety = FTimespan::FromMinutes(90.0);
		FTimespan Remainder = Ninety % FTimespan::FromHours(1.0);
		return Divided.GetTotalHours() == 1.0 && Span.GetTotalHours() == 1.0 && Remainder.GetTotalMinutes() == 30.0;
	}
}
/** @end */
