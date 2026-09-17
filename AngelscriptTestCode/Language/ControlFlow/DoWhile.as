/**
 * @version v1
 * @summary Do-while loop forms without observation wrappers.
 * @topic Language
 * @topic ControlFlow
 *
 * do-while
 * do-while-once
 * do-while-nested
 */
/**
 * @begin do-while
 * @summary A do-while that executes the body before testing the condition.
 */
int DoWhileLoop(int Limit)
{
	int Index = 0;
	int Total = 0;
	do
	{
		Total += Index;
		++Index;
	}
	while (Index < Limit);
	return Total;
}
/** @end */
/**
 * @begin do-while-once
 * @summary Do-while body runs once when the condition is already false.
 * @topic ControlFlow
 */
int DoWhileOnce()
{
	int Value = 0;
	do
	{
		Value = 1;
	}
	while (false);
	return Value;
}
/** @end */
/**
 * @begin do-while-nested
 * @summary Inner do-while nested in an outer do-while.
 * @topic ControlFlow
 */
int DoWhileNested()
{
	int Total = 0;
	int Outer = 0;
	do
	{
		int Inner = 0;
		do
		{
			Total += 1;
			++Inner;
		}
		while (Inner < 2);
		++Outer;
	}
	while (Outer < 2);
	return Total;
}
/** @end */
