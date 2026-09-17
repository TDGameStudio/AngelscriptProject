/**
 * @version v1
 * @summary Nested if statements without observation wrappers.
 * @topic Language
 * @topic ControlFlow
 */
/**
 * @version root
 * @summary An inner if nested in both arms of an outer if.
 * @topic Baseline
 */
int IfNested(bool Outer, bool Inner)
{
	int X = 0;
	if (Outer)
	{
		if (Inner)
		{
			X = 1;
		}
		else
		{
			X = 2;
		}
	}
	else
	{
		if (Inner)
		{
			X = 3;
		}
		else
		{
			X = 4;
		}
	}
	return X;
}
/** @end */
/**
 * @version invalid-dangling-else-token
 * @parent root
 * @summary A second else on the same if is invalid.
 * @topic Negative
 */
void Test(bool Flag)
{
	if (Flag)
	{
		return;
	}
	else
	{
		return;
	}
	else
	{
		return;
	}
}
/** @end */
/**
 * @version valid-if-nested-three-deep
 * @parent root
 * @summary Three nested ifs all taking the true arm.
 * @topic ControlFlow
 */
int NestedThree(bool A, bool B, bool C)
{
	int Value = 0;
	if (A)
	{
		if (B)
		{
			if (C)
			{
				Value = 1;
			}
			else
			{
				Value = 2;
			}
		}
		else
		{
			Value = 3;
		}
	}
	return Value;
}
/** @end */
/**
 * @version valid-if-nested-in-else
 * @parent root
 * @summary Inner if lives only in the outer else arm.
 * @topic ControlFlow
 */
int NestedInElse(bool Outer, bool Inner)
{
	int Value = 0;
	if (Outer)
	{
		Value = 1;
	}
	else
	{
		if (Inner)
		{
			Value = 2;
		}
		else
		{
			Value = 3;
		}
	}
	return Value;
}
/** @end */
/**
 * @version valid-if-nested-unbraced-inner
 * @parent root
 * @summary Outer if contains an unbraced inner if.
 * @topic ControlFlow
 */
int NestedUnbraced(bool Outer, bool Inner)
{
	int Value = 0;
	if (Outer)
		if (Inner)
			Value = 1;
		else
			Value = 2;
	return Value;
}
/** @end */
/**
 * @version invalid-if-missing-inner-condition
 * @parent root
 * @summary A nested if still requires a condition.
 * @topic Negative
 */
void Test(bool Outer)
{
	if (Outer)
	{
		if
		{
			return;
		}
	}
}
/** @end */
