/**
 * @version v1
 * @summary While-loop forms without observation wrappers.
 * @topic Language
 * @topic ControlFlow
 */
/**
 * @version root
 * @summary A counted while loop that advances a local.
 * @topic Baseline
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
 * @version invalid-while-non-bool
 * @parent root
 * @summary A while condition must be boolean.
 * @topic Negative
 */
void Test()
{
	while (1)
	{
		break;
	}
}
/** @end */
/**
 * @version invalid-while-empty-condition
 * @parent root
 * @summary Compile-rejection form retained from legacy while empty condition.
 * @topic Negative
 */
void Test()
{
	while ()
	{
	}
}
/** @end */
/**
 * @version invalid-while-integer-condition
 * @parent root
 * @summary Compile-rejection form retained from legacy while integer condition.
 * @topic Negative
 */
void Test()
{
	while (5)
	{
	}
}
/** @end */
/**
 * @version invalid-while-unparenthesized-condition
 * @parent root
 * @summary Compile-rejection form retained from legacy while unparenthesized condition.
 * @topic Negative
 */
void Test()
{
	while true
	{
	}
}
/** @end */
/**
 * @version invalid-while-variable-condition
 * @parent root
 * @summary Compile-rejection form retained from legacy while variable condition.
 * @topic Negative
 */
void Test()
{
	int X = 1;
	while (X)
	{
		break;
	}
}
/** @end */
/**
 * @version valid-while-zero-iterations
 * @parent root
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
 * @version valid-while-nested
 * @parent root
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
