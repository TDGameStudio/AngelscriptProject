/**
 * @version v1
 * @summary If-else and else-if ladder forms.
 * @topic Language
 * @topic ControlFlow
 *
 * if-else
 * if-else-false-condition
 * else-if-chain
 * unbraced-if-else
 * compound-condition-if-else
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
