/**
 * @version v1
 * @summary Compile-fail cases for While.
 * @topic Language
 * @topic ControlFlow
 *
 * invalid-while-non-bool                     // A while condition must be boolean.
 * invalid-while-empty-condition              // Compile-rejection form retained from legacy while empty condition.
 * invalid-while-integer-condition            // Compile-rejection form retained from legacy while integer condition.
 * invalid-while-unparenthesized-condition    // Compile-rejection form retained from legacy while unparenthesized condition.
 * invalid-while-variable-condition           // Compile-rejection form retained from legacy while variable condition.
 */
/**
 * @begin invalid-while-non-bool
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
 * @begin invalid-while-empty-condition
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
 * @begin invalid-while-integer-condition
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
 * @begin invalid-while-unparenthesized-condition
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
 * @begin invalid-while-variable-condition
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
