/**
 * @version v1
 * @summary Relational and equality comparison forms without observation wrappers.
 * @topic Language
 * @topic Operators
 */
/**
 * @version root
 * @summary Equality, inequality, and ordered comparisons on integers and floats.
 * @topic Baseline
 */
int EqualInt()
{
	return (1 == 1) ? 1 : 0;
}

int NotEqualInt()
{
	return (1 != 2) ? 1 : 0;
}

int LessInt()
{
	return (1 < 2) ? 1 : 0;
}

int LessEqualInt()
{
	return (2 <= 2) ? 1 : 0;
}

int GreaterInt()
{
	return (3 > 2) ? 1 : 0;
}

int GreaterEqualInt()
{
	return (3 >= 3) ? 1 : 0;
}

int CompareFloat()
{
	return (1.0f < 2.5f) ? 1 : 0;
}
/** @end */
/**
 * @version invalid-compare-incompatible-types
 * @parent root
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
 * @version invalid-boolean-ordering-comparison
 * @parent root
 * @summary Compile-rejection form retained from legacy boolean ordering comparison.
 * @topic Negative
 */
void Test()
{
	bool X = (true < false);
}
/** @end */
/**
 * @version invalid-compare-string-to-int
 * @parent root
 * @summary Compile-rejection form retained from legacy compare string to int.
 * @topic Negative
 */
void Test()
{
	bool X = ("hello" < 5);
}
/** @end */
/**
 * @version invalid-comparison-missing-right-operand
 * @parent root
 * @summary Compile-rejection form retained from legacy comparison missing right operand.
 * @topic Negative
 */
void Test()
{
	bool X = (1 == );
}
/** @end */
/**
 * @version invalid-triple-equals-operator
 * @parent root
 * @summary Compile-rejection form retained from legacy triple equals operator.
 * @topic Negative
 */
void Test()
{
	bool X = (1 === 1);
}
/** @end */
/**
 * @version valid-string-equality-operator
 * @parent root
 * @summary String equality and inequality.
 * @topic Operators
 */
bool Equal()
{
	return "a" == "a";
}

bool Unequal()
{
	return "a" != "b";
}
/** @end */
/**
 * @version invalid-string-compared-to-int
 * @parent root
 * @summary A string cannot be compared to an integer.
 * @topic Negative
 */
void Test()
{
	bool Result = "1" == 1;
}
/** @end */
