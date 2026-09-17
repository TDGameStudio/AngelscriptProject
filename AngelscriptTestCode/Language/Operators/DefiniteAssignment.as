/**
 * @version v1
 * @summary Branch and partial definite-assignment forms without observation wrappers.
 * @topic Language
 * @topic Operators
 *
 * definite-assignment              // Both branches assign the same local before it is read.
 * partial-then-complete            // A later assignment completes a path that left the local unset.
 * branch-definite-assignment       // Positive language form retained from legacy branch definite assignment.
 * partial-definite-assignment      // Positive language form retained from legacy partial definite assignment.
 * assigned-on-all-returns          // A local is assigned on every return path before it is read.
 * assigned-before-nested-block     // A local is assigned before a nested block reads it.
 * assigned-on-both-if-else-arms    // Both if and else arms assign before each arm returns.
 */
/**
 * @begin definite-assignment
 * @summary Both branches assign the same local before it is read.
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
 * @begin partial-then-complete
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
 * @begin branch-definite-assignment
 * @summary Positive language form retained from legacy branch definite assignment.
 * @topic Operators
 */
int Compute(bool Flag)
{
	int Value;
	if (Flag)
	{
		Value = 7;
	}
	else
	{
		Value = 9;
	}
	return Value;
}
/** @end */
/**
 * @begin partial-definite-assignment
 * @summary Positive language form retained from legacy partial definite assignment.
 * @topic Operators
 */
int RunPartial(bool Flag)
{
	int Value;
	if (Flag)
	{
		Value = 7;
	}
	return Value;
}
/** @end */
/**
 * @begin assigned-on-all-returns
 * @summary A local is assigned on every return path before it is read.
 * @topic Operators
 */
int AllPaths(bool Flag)
{
	int Value;
	if (Flag)
	{
		Value = 1;
		return Value;
	}
	Value = 2;
	return Value;
}
/** @end */
/**
 * @begin assigned-before-nested-block
 * @summary A local is assigned before a nested block reads it.
 * @topic Operators
 */
int AssignedBeforeNestedBlock()
{
	int Value = 1;
	{
		return Value;
	}
}
/** @end */
/**
 * @begin assigned-on-both-if-else-arms
 * @summary Both if and else arms assign before each arm returns.
 * @topic Operators
 */
int AssignedOnBothIfElseArms(bool Flag)
{
	int Value;
	if (Flag)
	{
		Value = 1;
		return Value;
	}
	else
	{
		Value = 2;
		return Value;
	}
}
/** @end */
