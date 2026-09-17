/**
 * @version v1
 * @summary Compile-fail cases for Logical.
 * @topic Language
 * @topic Operators
 *
 * invalid-logical-on-int                   // Logical and requires boolean operands.
 * invalid-logical-and-on-floats            // Compile-rejection form retained from legacy logical and on floats.
 * invalid-logical-and-on-integers          // Compile-rejection form retained from legacy logical and on integers.
 * invalid-logical-missing-right-operand    // Compile-rejection form retained from legacy logical missing right operand.
 * invalid-logical-not-on-integer           // Compile-rejection form retained from legacy logical not on integer.
 * invalid-logical-or-on-strings            // Compile-rejection form retained from legacy logical or on strings.
 * invalid-triple-ampersand-operator        // Compile-rejection form retained from legacy triple ampersand operator.
 */
/**
 * @begin invalid-logical-on-int
 * @summary Logical and requires boolean operands.
 * @topic Negative
 */
void Test()
{
	bool Result = 1 && 2;
}
/** @end */
/**
 * @begin invalid-logical-and-on-floats
 * @summary Compile-rejection form retained from legacy logical and on floats.
 * @topic Negative
 */
void Test()
{
	bool X = 1.0f && 2.0f;
}
/** @end */
/**
 * @begin invalid-logical-and-on-integers
 * @summary Compile-rejection form retained from legacy logical and on integers.
 * @topic Negative
 */
void Test()
{
	int X = 1 && 2;
}
/** @end */
/**
 * @begin invalid-logical-missing-right-operand
 * @summary Compile-rejection form retained from legacy logical missing right operand.
 * @topic Negative
 */
void Test()
{
	bool X = true && ;
}
/** @end */
/**
 * @begin invalid-logical-not-on-integer
 * @summary Compile-rejection form retained from legacy logical not on integer.
 * @topic Negative
 */
void Test()
{
	int X = !5;
}
/** @end */
/**
 * @begin invalid-logical-or-on-strings
 * @summary Compile-rejection form retained from legacy logical or on strings.
 * @topic Negative
 */
void Test()
{
	auto X = "a" || "b";
}
/** @end */
/**
 * @begin invalid-triple-ampersand-operator
 * @summary Compile-rejection form retained from legacy triple ampersand operator.
 * @topic Negative
 */
void Test()
{
	bool X = true &&& false;
}
/** @end */
