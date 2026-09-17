/**
 * @version v1
 * @summary Single-branch if statements and condition forms.
 * @topic Language
 * @topic ControlFlow
 *
 * if
 * if-conditions
 * bare-if-true
 * if-unbraced-body
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
