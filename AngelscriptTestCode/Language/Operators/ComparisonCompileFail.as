/**
 * @version v1
 * @summary Compile-fail cases for Comparison.
 * @topic Language
 * @topic Operators
 *
 * invalid-compare-incompatible-types
 * invalid-boolean-ordering-comparison
 * invalid-compare-string-to-int
 * invalid-comparison-missing-right-operand
 * invalid-triple-equals-operator
 * invalid-string-compared-to-int
 */
/**
 * @begin invalid-compare-incompatible-types
 * @summary A struct value cannot be compared with an integer.
 * @topic Negative
 */
struct FPair
{
	int X;
}

void Test()
{
	FPair Value;
	bool Result = Value == 1;
}
/** @end */
/**
 * @begin invalid-boolean-ordering-comparison
 * @summary Compile-rejection form retained from legacy boolean ordering comparison.
 * @topic Negative
 */
void Test()
{
	bool X = (true < false);
}
/** @end */
/**
 * @begin invalid-compare-string-to-int
 * @summary Compile-rejection form retained from legacy compare string to int.
 * @topic Negative
 */
void Test()
{
	bool X = ("hello" < 5);
}
/** @end */
/**
 * @begin invalid-comparison-missing-right-operand
 * @summary Compile-rejection form retained from legacy comparison missing right operand.
 * @topic Negative
 */
void Test()
{
	bool X = (1 == );
}
/** @end */
/**
 * @begin invalid-triple-equals-operator
 * @summary Compile-rejection form retained from legacy triple equals operator.
 * @topic Negative
 */
void Test()
{
	bool X = (1 === 1);
}
/** @end */
/**
 * @begin invalid-string-compared-to-int
 * @summary A string cannot be compared to an integer.
 * @topic Negative
 */
void Test()
{
	bool Result = "1" == 1;
}
/** @end */
