/**
 * @version v1
 * @summary While-loop forms without observation wrappers.
 * @topic Language
 * @topic ControlFlow
 *
 * while
 * while-zero-iterations
 * while-nested
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
