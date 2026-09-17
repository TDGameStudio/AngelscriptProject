/**
 * @version v1
 * @summary Single-branch if statements and condition forms.
 * @topic Language
 * @topic ControlFlow
 *
 * if                           // A boolean if that assigns only on the true path, plus comparison conditions.
 * if-conditions                // Positive language form retained from legacy if conditions.
 * bare-if-true                 // Bare if with a true condition executes its body.
 * if-unbraced-body             // Unbraced if owns only the following statement.
 * if-false-skips-body          // False if leaves the following statements unchanged.
 * if-compound-and-condition    // If condition uses a conjunctive && test.
 * if-compound-or-condition     // If condition uses a disjunctive || test.
 * if-not-condition             // If condition uses a negated boolean.
 */
/**
 * @begin if
 * @summary A boolean if that assigns only on the true path, plus comparison conditions.
 */
int IfBasic(bool Flag)
{
	int X = 0;
	if (Flag)
	{
		X = 1;
	}
	return X;
}

int IfComparison(int Value)
{
	int X = 0;
	if (Value > 0)
	{
		X = 1;
	}
	if (Value == 0)
	{
		X = 2;
	}
	return X;
}
/** @end */
/**
 * @begin if-conditions
 * @summary Positive language form retained from legacy if conditions.
 * @topic ControlFlow
 */
bool IsReady()
	{
		return true;
	}
/** @end */
/**
 * @begin bare-if-true
 * @summary Bare if with a true condition executes its body.
 * @topic ControlFlow
 */
int BareIf()
{
	if (true)
	{
		return 1;
	}
	return 0;
}
/** @end */
/**
 * @begin if-unbraced-body
 * @summary Unbraced if owns only the following statement.
 * @topic ControlFlow
 */
int UnbracedIf(bool Flag)
{
	int Value = 0;
	if (Flag)
		Value = 1;
	return Value;
}
/** @end */
/**
 * @begin if-false-skips-body
 * @summary False if leaves the following statements unchanged.
 * @topic ControlFlow
 */
int IfFalseSkips()
{
	int Value = 1;
	if (false)
	{
		Value = 0;
	}
	return Value;
}
/** @end */
/**
 * @begin if-compound-and-condition
 * @summary If condition uses a conjunctive && test.
 * @topic ControlFlow
 */
int IfCompoundAnd(int Left, int Right)
{
	int Value = 0;
	if (Left > 0 && Right > 0)
	{
		Value = Left + Right;
	}
	return Value;
}
/** @end */
/**
 * @begin if-compound-or-condition
 * @summary If condition uses a disjunctive || test.
 * @topic ControlFlow
 */
int IfCompoundOr(int Left, int Right)
{
	int Value = 0;
	if (Left > 0 || Right > 0)
	{
		Value = 1;
	}
	return Value;
}
/** @end */
/**
 * @begin if-not-condition
 * @summary If condition uses a negated boolean.
 * @topic ControlFlow
 */
int IfNot(bool Flag)
{
	int Value = 0;
	if (!Flag)
	{
		Value = 1;
	}
	return Value;
}
/** @end */
