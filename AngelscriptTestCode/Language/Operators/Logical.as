/**
 * @version v1
 * @summary Logical conjunction, disjunction, negation, and short-circuit forms.
 * @topic Language
 * @topic Operators
 */
/**
 * @version root
 * @summary And, or, not, a compound mix, and a short-circuit probe.
 * @topic Baseline
 */
int ConjunctionHolds()
{
	bool Result = (true && true);
	return Result ? 1 : 0;
}

int DisjunctionHolds()
{
	bool Result = (false || true);
	return Result ? 1 : 0;
}

int NegationHolds()
{
	return (!false) ? 1 : 0;
}

int CompoundExpressionHolds()
{
	bool Result = ((true && !false) || (false && true));
	return Result ? 1 : 0;
}

int ShortCircuitSkipsDivisor()
{
	int Z = 0;
	bool Result = (false && (1 / Z) == 0);
	return Result ? 1 : 0;
}
/** @end */
/**
 * @version invalid-logical-on-int
 * @parent root
 * @summary Logical and requires boolean operands.
 * @topic Negative
 */
void Test()
{
	bool Result = 1 && 2;
}
/** @end */
/**
 * @version invalid-logical-and-on-floats
 * @parent root
 * @summary Compile-rejection form retained from legacy logical and on floats.
 * @topic Negative
 */
void Test()
{
	bool X = 1.0f && 2.0f;
}
/** @end */
/**
 * @version invalid-logical-and-on-integers
 * @parent root
 * @summary Compile-rejection form retained from legacy logical and on integers.
 * @topic Negative
 */
void Test()
{
	int X = 1 && 2;
}
/** @end */
/**
 * @version invalid-logical-missing-right-operand
 * @parent root
 * @summary Compile-rejection form retained from legacy logical missing right operand.
 * @topic Negative
 */
void Test()
{
	bool X = true && ;
}
/** @end */
/**
 * @version invalid-logical-not-on-integer
 * @parent root
 * @summary Compile-rejection form retained from legacy logical not on integer.
 * @topic Negative
 */
void Test()
{
	int X = !5;
}
/** @end */
/**
 * @version invalid-logical-or-on-strings
 * @parent root
 * @summary Compile-rejection form retained from legacy logical or on strings.
 * @topic Negative
 */
void Test()
{
	auto X = "a" || "b";
}
/** @end */
/**
 * @version invalid-triple-ampersand-operator
 * @parent root
 * @summary Compile-rejection form retained from legacy triple ampersand operator.
 * @topic Negative
 */
void Test()
{
	bool X = true &&& false;
}
/** @end */
/**
 * @version valid-short-circuit-and
 * @parent root
 * @summary Logical and skips the right operand when the left is false.
 * @topic Operators
 */
int Probe()
{
	int Value = 0;
	bool Result = (false && (Value = 1) == 1);
	return Result ? Value : 0;
}
/** @end */
/**
 * @version valid-short-circuit-or
 * @parent root
 * @summary Logical or skips the right operand when the left is true.
 * @topic Operators
 */
int Probe()
{
	int Value = 0;
	bool Result = (true || (Value = 1) == 1);
	return Result ? 1 : Value;
}
/** @end */
