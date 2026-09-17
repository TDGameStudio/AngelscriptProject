/**
 * @version v1
 * @summary Break and continue inside loops.
 * @topic Language
 * @topic ControlFlow
 *
 * loop-jump                  // A while that breaks early and a while that continues on even values.
 * break-in-loop              // Authored language form for break in loop.
 * continue-in-loop           // Authored language form for continue in loop.
 * break-in-nested-loop       // Break leaves only the inner loop.
 * continue-in-nested-loop    // Continue skips the rest of the inner iteration.
 * break-in-while             // Break leaves a while loop before later iterations.
 * continue-in-while          // Continue skips the rest of one while iteration.
 * break-in-do-while          // Break leaves a do-while before the condition is retested.
 */
/**
 * @begin loop-jump
 * @summary A while that breaks early and a while that continues on even values.
 */
int BreakInLoop(int Limit)
{
	int Index = 0;
	int Total = 0;
	while (Index < Limit)
	{
		if (Index == 3)
		{
			break;
		}
		Total += Index;
		++Index;
	}
	return Total;
}

int ContinueInLoop(int Limit)
{
	int Index = 0;
	int Total = 0;
	while (Index < Limit)
	{
		++Index;
		if ((Index % 2) == 0)
		{
			continue;
		}
		Total += Index;
	}
	return Total;
}
/** @end */
/**
 * @begin break-in-loop
 * @summary Authored language form for break in loop.
 * @topic ControlFlow
 */
int BreakInLoop()
{
	int Total = 0;
	for (int Index = 0; Index < 8; ++Index)
	{
		if (Index == 3)
		{
			break;
		}
		Total += Index;
	}
	return Total;
}
/** @end */
/**
 * @begin continue-in-loop
 * @summary Authored language form for continue in loop.
 * @topic ControlFlow
 */
int ContinueInLoop()
{
	int Total = 0;
	for (int Index = 0; Index < 5; ++Index)
	{
		if (Index == 2)
		{
			continue;
		}
		Total += Index;
	}
	return Total;
}
/** @end */
/**
 * @begin break-in-nested-loop
 * @summary Break leaves only the inner loop.
 * @topic ControlFlow
 */
int NestedBreak()
{
	int Total = 0;
	for (int Outer = 0; Outer < 3; ++Outer)
	{
		for (int Inner = 0; Inner < 3; ++Inner)
		{
			if (Inner == 1)
			{
				break;
			}
			Total += 1;
		}
	}
	return Total;
}
/** @end */
/**
 * @begin continue-in-nested-loop
 * @summary Continue skips the rest of the inner iteration.
 * @topic ControlFlow
 */
int NestedContinue()
{
	int Total = 0;
	for (int Outer = 0; Outer < 2; ++Outer)
	{
		for (int Inner = 0; Inner < 3; ++Inner)
		{
			if (Inner == 1)
			{
				continue;
			}
			Total += Inner;
		}
	}
	return Total;
}
/** @end */
/**
 * @begin break-in-while
 * @summary Break leaves a while loop before later iterations.
 * @topic ControlFlow
 */
int BreakInWhile()
{
	int Index = 0;
	int Total = 0;
	while (Index < 8)
	{
		if (Index == 3)
		{
			break;
		}
		Total += Index;
		++Index;
	}
	return Total;
}
/** @end */
/**
 * @begin continue-in-while
 * @summary Continue skips the rest of one while iteration.
 * @topic ControlFlow
 */
int ContinueInWhile()
{
	int Index = 0;
	int Total = 0;
	while (Index < 5)
	{
		++Index;
		if (Index == 2)
		{
			continue;
		}
		Total += Index;
	}
	return Total;
}
/** @end */
/**
 * @begin break-in-do-while
 * @summary Break leaves a do-while before the condition is retested.
 * @topic ControlFlow
 */
int BreakInDoWhile()
{
	int Index = 0;
	int Total = 0;
	do
	{
		if (Index == 3)
		{
			break;
		}
		Total += Index;
		++Index;
	}
	while (Index < 8);
	return Total;
}
/** @end */
