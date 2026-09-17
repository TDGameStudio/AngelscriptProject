/**
 * @version v1
 * @summary While-loop forms without observation wrappers.
 * @topic Language
 * @topic ControlFlow
 *
 * while                       // A counted while loop that advances a local.
 * while-zero-iterations       // While body is skipped when the condition starts false.
 * while-nested                // Nested while loops accumulate a product of iterations.
 * while-one-iteration         // While body runs once when the condition is true only first.
 * while-compound-condition    // While condition uses a conjunctive && test.
 */
/**
 * @begin while
 * @summary A counted while loop that advances a local.
 */
int WhileLoop(int Limit)
{
	int Index = 0;
	int Total = 0;
	while (Index < Limit)
	{
		Total += Index;
		++Index;
	}
	return Total;
}
/** @end */
/**
 * @begin while-zero-iterations
 * @summary While body is skipped when the condition starts false.
 * @topic ControlFlow
 */
int WhileZero()
{
	int Value = 1;
	while (false)
	{
		Value = 0;
	}
	return Value;
}
/** @end */
/**
 * @begin while-nested
 * @summary Nested while loops accumulate a product of iterations.
 * @topic ControlFlow
 */
int WhileNested()
{
	int Total = 0;
	int Outer = 0;
	while (Outer < 2)
	{
		int Inner = 0;
		while (Inner < 3)
		{
			Total += 1;
			++Inner;
		}
		++Outer;
	}
	return Total;
}
/** @end */
/**
 * @begin while-one-iteration
 * @summary While body runs once when the condition is true only first.
 * @topic ControlFlow
 */
int WhileOne()
{
	int Value = 0;
	int Index = 0;
	while (Index < 1)
	{
		Value = 1;
		++Index;
	}
	return Value;
}
/** @end */
/**
 * @begin while-compound-condition
 * @summary While condition uses a conjunctive && test.
 * @topic ControlFlow
 */
int WhileCompound()
{
	int Index = 0;
	int Total = 0;
	while (Index < 3 && Total < 10)
	{
		Total += Index;
		++Index;
	}
	return Total;
}
/** @end */
