/**
 * @version v1
 * @summary Nested if statements without observation wrappers.
 * @topic Language
 * @topic ControlFlow
 *
 * if-nested                   // An inner if nested in both arms of an outer if.
 * if-nested-three-deep        // Three nested ifs all taking the true arm.
 * if-nested-in-else           // Inner if lives only in the outer else arm.
 * if-nested-unbraced-inner    // Outer if contains an unbraced inner if.
 * if-nested-false-outer       // A false outer if skips the nested inner if.
 * if-nested-false-inner       // A true outer if still skips a false inner if.
 */
/**
 * @begin if-nested
 * @summary An inner if nested in both arms of an outer if.
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
 * @begin if-nested-three-deep
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
 * @begin if-nested-in-else
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
 * @begin if-nested-unbraced-inner
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
 * @begin if-nested-false-outer
 * @summary A false outer if skips the nested inner if.
 * @topic ControlFlow
 */
int NestedFalseOuter()
{
	int Value = 1;
	if (false)
	{
		if (true)
		{
			Value = 0;
		}
	}
	return Value;
}
/** @end */
/**
 * @begin if-nested-false-inner
 * @summary A true outer if still skips a false inner if.
 * @topic ControlFlow
 */
int NestedFalseInner()
{
	int Value = 1;
	if (true)
	{
		if (false)
		{
			Value = 0;
		}
	}
	return Value;
}
/** @end */
