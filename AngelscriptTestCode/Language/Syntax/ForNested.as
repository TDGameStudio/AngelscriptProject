/**
 * @version v1
 * @summary Nested for loops without observation wrappers.
 * @topic Language
 * @topic Syntax
 *
 * for-nested
 * for-nested-three-deep
 * for-nested-with-break
 */
/**
 * @begin for-nested
 * @summary An inner for nested inside an outer for.
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
 * @begin for-nested-three-deep
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
 * @begin for-nested-with-break
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
