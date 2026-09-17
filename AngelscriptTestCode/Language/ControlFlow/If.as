/**
 * @version v1
 * @summary Single-branch if statements and condition forms.
 * @topic Language
 * @topic ControlFlow
 */
/**
 * @version root
 * @summary A boolean if that assigns only on the true path, plus comparison conditions.
 * @topic Baseline
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
 * @version invalid-if-non-bool
 * @parent root
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
 * @version valid-if-conditions
 * @parent root
 * @summary Positive language form retained from legacy if conditions.
 * @topic ControlFlow
 */
bool IsReady()
	{
		return true;
	}
/** @end */
/**
 * @version invalid-if-empty-condition
 * @parent root
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
 * @version invalid-if-float-condition
 * @parent root
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
 * @version invalid-if-integer-condition
 * @parent root
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
 * @version invalid-if-string-condition
 * @parent root
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
 * @version invalid-if-unparenthesized-condition
 * @parent root
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
 * @version invalid-if-variable-integer-condition
 * @parent root
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
/**
 * @version valid-bare-if-true
 * @parent root
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
 * @version valid-if-unbraced-body
 * @parent root
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
