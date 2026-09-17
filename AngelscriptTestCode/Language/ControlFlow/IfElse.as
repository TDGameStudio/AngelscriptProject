/**
 * @version v1
 * @summary If-else and else-if ladder forms.
 * @topic Language
 * @topic ControlFlow
 *
 * if-else                       // A two-arm if-else and a three-arm else-if ladder.
 * if-else-false-condition       // Else arm runs when the if condition is false.
 * else-if-chain                 // Else-if chain selects the middle test.
 * unbraced-if-else              // Unbraced if-else binds a single statement per arm.
 * compound-condition-if-else    // If-else with a conjunctive condition.
 * else-if-false-middle          // A false middle else-if falls through to the final else.
 * if-else-nested-else           // The else arm owns another complete if-else.
 */
/**
 * @begin if-else
 * @summary A two-arm if-else and a three-arm else-if ladder.
 */
int IfElseForms(int Value)
{
	int X = 0;
	if (Value > 0)
	{
		X = 1;
	}
	else
	{
		X = -1;
	}
	return X;
}

int ElseIfLadder(int Value)
{
	if (Value < 0)
	{
		return -1;
	}
	else if (Value == 0)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}
/** @end */
/**
 * @begin if-else-false-condition
 * @summary Else arm runs when the if condition is false.
 * @topic ControlFlow
 */
int IfElseFalse()
{
	if (false)
	{
		return 1;
	}
	else
	{
		return 2;
	}
}
/** @end */
/**
 * @begin else-if-chain
 * @summary Else-if chain selects the middle test.
 * @topic ControlFlow
 */
int ElseIfChain(int Value)
{
	if (Value > 10)
	{
		return 1;
	}
	else if (Value > 3)
	{
		return 2;
	}
	else
	{
		return 3;
	}
}
/** @end */
/**
 * @begin unbraced-if-else
 * @summary Unbraced if-else binds a single statement per arm.
 * @topic ControlFlow
 */
int UnbracedIfElse(bool Flag)
{
	int Value = 0;
	if (Flag)
		Value = 1;
	else
		Value = 2;
	return Value;
}
/** @end */
/**
 * @begin compound-condition-if-else
 * @summary If-else with a conjunctive condition.
 * @topic ControlFlow
 */
int CompoundIfElse(int Left, int Right)
{
	if (Left > 0 && Right > 0)
	{
		return Left + Right;
	}
	else
	{
		return 0;
	}
}
/** @end */
/**
 * @begin else-if-false-middle
 * @summary A false middle else-if falls through to the final else.
 * @topic ControlFlow
 */
int ElseIfFalseMiddle()
{
	if (false)
	{
		return 1;
	}
	else if (false)
	{
		return 2;
	}
	else
	{
		return 3;
	}
}
/** @end */
/**
 * @begin if-else-nested-else
 * @summary The else arm owns another complete if-else.
 * @topic ControlFlow
 */
int IfElseNestedElse(bool Outer, bool Inner)
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
