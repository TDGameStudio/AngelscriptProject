/**
 * @version v1
 * @summary Logical conjunction, disjunction, negation, and short-circuit forms.
 * @topic Language
 * @topic Operators
 *
 * logical
 * short-circuit-and
 * short-circuit-or
 */
/**
 * @begin logical
 * @summary And, or, not, a compound mix, and a short-circuit probe.
 */
int ConjunctionHolds()
{
	bool Result = (true && true);
	return Result ? 1 : 0;
}

int DisjunctionHolds()
{
	bool Result = (false || true);
	return Result ? 1 : 0;
}

int NegationHolds()
{
	return (!false) ? 1 : 0;
}

int CompoundExpressionHolds()
{
	bool Result = ((true && !false) || (false && true));
	return Result ? 1 : 0;
}

int ShortCircuitSkipsDivisor()
{
	int Z = 0;
	bool Result = (false && (1 / Z) == 0);
	return Result ? 1 : 0;
}
/** @end */
/**
 * @begin short-circuit-and
 * @summary Logical and skips the right operand when the left is false.
 * @topic Operators
 */
int Probe()
{
	int Value = 0;
	bool Result = (false && (Value = 1) == 1);
	return Result ? Value : 0;
}
/** @end */
/**
 * @begin short-circuit-or
 * @summary Logical or skips the right operand when the left is true.
 * @topic Operators
 */
int Probe()
{
	int Value = 0;
	bool Result = (true || (Value = 1) == 1);
	return Result ? 1 : Value;
}
/** @end */
