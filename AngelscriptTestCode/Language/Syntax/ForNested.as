/**
 * @version v1
 * @summary Nested for loops without observation wrappers.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary An inner for nested inside an outer for.
 * @topic Baseline
 */
int NestedFors()
{
	int Total = 0;
	for (int Row = 0; Row < 3; ++Row)
	{
		for (int Column = 0; Column < 3; ++Column)
		{
			Total += Row + Column;
		}
	}
	return Total;
}
/** @end */
/**
 * @version invalid-inner-index-escape
 * @parent root
 * @summary A for-declared index is not visible after the loop.
 * @topic Negative
 */
int Test()
{
	for (int Index = 0; Index < 1; ++Index)
	{
	}
	return Index;
}
/** @end */
/**
 * @version invalid-for-loop-variable-escapes-scope
 * @parent root
 * @summary Compile-rejection form retained from legacy for loop variable escapes scope.
 * @topic Negative
 */
void Test()
{
	for (int I = 0; I < 5; ++I)
	{
	}
	int X = I;
}
/** @end */
/**
 * @version valid-for-nested-three-deep
 * @parent root
 * @summary Three nested for loops accumulate a product of trip counts.
 * @topic Syntax
 */
int NestedThree()
{
	int Total = 0;
	for (int A = 0; A < 2; ++A)
	{
		for (int B = 0; B < 2; ++B)
		{
			for (int C = 0; C < 2; ++C)
			{
				Total += 1;
			}
		}
	}
	return Total;
}
/** @end */
/**
 * @version valid-for-nested-with-break
 * @parent root
 * @summary Inner for break leaves the outer loop running.
 * @topic Syntax
 */
int NestedBreak()
{
	int Total = 0;
	for (int Outer = 0; Outer < 3; ++Outer)
	{
		for (int Inner = 0; Inner < 5; ++Inner)
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
