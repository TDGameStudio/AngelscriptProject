/**
 * @version v1
 * @summary Break and continue inside loops.
 * @topic Language
 * @topic ControlFlow
 */
/**
 * @version root
 * @summary A while that breaks early and a while that continues on even values.
 * @topic Baseline
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
 * @version invalid-break-outside-loop
 * @parent root
 * @summary Break is invalid outside a loop or switch.
 * @topic Negative
 */
void Test()
{
	break;
}
/** @end */
/**
 * @version invalid-continue-outside-loop
 * @parent root
 * @summary Continue is invalid outside a loop.
 * @topic Negative
 */
void Test()
{
	continue;
}
/** @end */
/**
 * @version invalid-break-in-function-called-from-loop
 * @parent root
 * @summary Compile-rejection form retained from legacy break in function called from loop.
 * @topic Negative
 */
void Foo()
{
	break;
}

void Test()
{
	for (int I = 0; I < 5; ++I)
	{
		Foo();
	}
}
/** @end */
/**
 * @version invalid-break-inside-if-without-loop
 * @parent root
 * @summary Compile-rejection form retained from legacy break inside if without loop.
 * @topic Negative
 */
void Test()
{
	if (true)
	{
		break;
	}
}
/** @end */
/**
 * @version invalid-continue-inside-if-without-loop
 * @parent root
 * @summary Compile-rejection form retained from legacy continue inside if without loop.
 * @topic Negative
 */
void Test()
{
	if (true)
	{
		continue;
	}
}
/** @end */
/**
 * @version valid-break-in-loop
 * @parent root
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
 * @version valid-continue-in-loop
 * @parent root
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
 * @version valid-break-in-nested-loop
 * @parent root
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
 * @version valid-continue-in-nested-loop
 * @parent root
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
