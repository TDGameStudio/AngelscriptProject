/**
 * @version v1
 * @summary Branch and partial definite-assignment forms without observation wrappers.
 * @topic Language
 * @topic Operators
 */
/**
 * @version root
 * @summary Both branches assign the same local before it is read.
 * @topic Baseline
 */
int BothBranchesAssign(bool Flag)
{
	int X;
	if (Flag)
	{
		X = 1;
	}
	else
	{
		X = 2;
	}
	return X;
}
/** @end */
/**
 * @version valid-partial-then-complete
 * @parent root
 * @summary A later assignment completes a path that left the local unset.
 * @topic Operators
 */
int CompleteAfterPartial(bool Flag)
{
	int X;
	if (Flag)
	{
		X = 1;
	}
	X = 3;
	return X;
}
/** @end */
/**
 * @version invalid-unassigned-read
 * @parent root
 * @summary Reading a local that is not definitely assigned is invalid.
 * @topic Negative
 */
int Test(bool Flag)
{
	int X;
	if (Flag)
	{
		X = 1;
	}
	return X;
}
/** @end */
/**
 * @version valid-branch-definite-assignment
 * @parent root
 * @summary Positive language form retained from legacy branch definite assignment.
 * @topic Operators
 */
int Compute(bool bFlag)
	{
		int Value;
		if (bFlag)
		{
			Value = 7;
		}
		else
		{
			Value = 9;
		}
		return Value;
	}

	int RunSafeTrue()
	{
		return Compute(true);
	}

	int RunSafeFalse()
	{
		return Compute(false);
	}
/** @end */
/**
 * @version valid-partial-definite-assignment
 * @parent root
 * @summary Positive language form retained from legacy partial definite assignment.
 * @topic Operators
 */
int RunPartial(bool bFlag)
	{
		int Value;
		if (bFlag)
		{
			Value = 7;
		}
		return Value;
	}
/** @end */
/**
 * @version valid-assigned-on-all-returns
 * @parent root
 * @summary A local is assigned on every return path before it is read.
 * @topic Operators
 */
int AllPaths(bool Flag)
{
	int Value;
	if (Flag)
	{
		Value = 1;
	}
	else
	{
		Value = 2;
	}
	return Value;
}
/** @end */
