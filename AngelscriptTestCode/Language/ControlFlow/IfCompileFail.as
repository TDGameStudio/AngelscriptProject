/**
 * @version v1
 * @summary Compile-fail cases for If.
 * @topic Language
 * @topic ControlFlow
 *
 * invalid-if-non-bool                      // An if condition must be boolean.
 * invalid-if-empty-condition               // Compile-rejection form retained from legacy if empty condition.
 * invalid-if-float-condition               // Compile-rejection form retained from legacy if float condition.
 * invalid-if-integer-condition             // Compile-rejection form retained from legacy if integer condition.
 * invalid-if-string-condition              // Compile-rejection form retained from legacy if string condition.
 * invalid-if-unparenthesized-condition     // Compile-rejection form retained from legacy if unparenthesized condition.
 * invalid-if-variable-integer-condition    // Compile-rejection form retained from legacy if variable integer condition.
 */
/**
 * @begin invalid-if-non-bool
 * @summary An if condition must be boolean.
 * @topic Negative
 */
void Test()
{
	if (1)
	{
		return;
	}
}
/** @end */
/**
 * @begin invalid-if-empty-condition
 * @summary Compile-rejection form retained from legacy if empty condition.
 * @topic Negative
 */
void Test()
{
	if ()
	{
	}
}
/** @end */
/**
 * @begin invalid-if-float-condition
 * @summary Compile-rejection form retained from legacy if float condition.
 * @topic Negative
 */
void Test()
{
	if (1.0f)
	{
	}
}
/** @end */
/**
 * @begin invalid-if-integer-condition
 * @summary Compile-rejection form retained from legacy if integer condition.
 * @topic Negative
 */
void Test()
{
	if (5)
	{
	}
}
/** @end */
/**
 * @begin invalid-if-string-condition
 * @summary Compile-rejection form retained from legacy if string condition.
 * @topic Negative
 */
void Test()
{
	if ("hello")
	{
	}
}
/** @end */
/**
 * @begin invalid-if-unparenthesized-condition
 * @summary Compile-rejection form retained from legacy if unparenthesized condition.
 * @topic Negative
 */
void Test()
{
	if true
	{
	}
}
/** @end */
/**
 * @begin invalid-if-variable-integer-condition
 * @summary Compile-rejection form retained from legacy if variable integer condition.
 * @topic Negative
 */
void Test()
{
	int X = 0;
	if (X)
	{
	}
}
/** @end */
