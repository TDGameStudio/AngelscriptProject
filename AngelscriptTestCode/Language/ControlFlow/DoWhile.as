/**
 * @version v1
 * @summary Do-while loop forms without observation wrappers.
 * @topic Language
 * @topic ControlFlow
 */
/**
 * @version root
 * @summary A do-while that executes the body before testing the condition.
 * @topic Baseline
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
 * @version invalid-do-without-while
 * @parent root
 * @summary A do body must be followed by while.
 * @topic Negative
 */
void Test()
{
	do
	{
		return;
	}
}
/** @end */
/**
 * @version invalid-do-while-integer-condition
 * @parent root
 * @summary Compile-rejection form retained from legacy do while integer condition.
 * @topic Negative
 */
void Test()
{
	do
	{
	} while (1);
}
/** @end */
/**
 * @version invalid-do-while-missing-semicolon
 * @parent root
 * @summary Compile-rejection form retained from legacy do while missing semicolon.
 * @topic Negative
 */
void Test()
{
	do
	{
	} while (true)
}
/** @end */
/**
 * @version valid-do-while-once
 * @parent root
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
 * @version valid-do-while-nested
 * @parent root
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
/**
 * @version invalid-do-while-empty-condition
 * @parent root
 * @summary Do-while condition cannot be empty.
 * @topic Negative
 */
void Test()
{
	do
	{
	}
	while ();
}
/** @end */
/**
 * @version invalid-do-while-missing-parens
 * @parent root
 * @summary Do-while condition must be parenthesized.
 * @topic Negative
 */
void Test()
{
	do
	{
	}
	while true;
}
/** @end */
