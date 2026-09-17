/**
 * @version v1
 * @summary Nested blocks, chained addition, and short-circuit skip forms.
 * @topic Language
 * @topic Syntax
 *
 * blocks                                 // Deep blocks, parenthesized addition, a long chain, and short-circuit skip.
 * deeply-parenthesized-addition          // Positive language form retained from legacy deeply parenthesized addition.
 * long-chained-addition                  // Positive language form retained from legacy long chained addition.
 * multiple-statements-in-one-function    // Positive language form retained from legacy multiple statements in one function.
 * short-circuit-skips-right-hand-side    // Positive language form retained from legacy short circuit skips right hand side.
 * nested-block-shadow                    // An inner block local hides the outer local of the same name.
 * empty-block                            // A function whose only statement is an empty block.
 */
/**
 * @begin blocks
 * @summary Deep blocks, parenthesized addition, a long chain, and short-circuit skip.
 */
int DeeplyNestedBlocks()
{
	int Total = 0;
	{
		{
			{
				Total = 1;
			}
		}
	}
	return Total;
}

int DeeplyParenthesizedAddition()
{
	return ((((1 + 2) + 3) + 4));
}

int LongChainedAddition()
{
	return 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8;
}

int MultipleStatements()
{
	int X = 1;
	int Y = 2;
	int Z = X + Y;
	return Z;
}

int ShortCircuitSkip()
{
	int Z = 0;
	bool Result = (false && (1 / Z) == 1);
	return Result ? 1 : 0;
}
/** @end */
/**
 * @begin deeply-parenthesized-addition
 * @summary Positive language form retained from legacy deeply parenthesized addition.
 * @topic Syntax
 */
void Test()
	{
		int X = ((((1 + 2))));
	}
/** @end */
/**
 * @begin long-chained-addition
 * @summary Positive language form retained from legacy long chained addition.
 * @topic Syntax
 */
void Test()
	{
		int X = 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 + 11 + 12 + 13 + 14 + 15;
	}
/** @end */
/**
 * @begin multiple-statements-in-one-function
 * @summary Positive language form retained from legacy multiple statements in one function.
 * @topic Syntax
 */
void Test()
	{
		int A = 1;
		int B = 2;
		int C = A + B;
	}
/** @end */
/**
 * @begin short-circuit-skips-right-hand-side
 * @summary Positive language form retained from legacy short circuit skips right hand side.
 * @topic Syntax
 */
bool RecordTrue(int&inout Calls)
	{
		Calls += 1;
		return true;
	}

	bool RecordFalse(int&inout Calls)
	{
		Calls += 1;
		return false;
	}

	int AndSkipsRightSide()
	{
		int Calls = 0;
		if (false && RecordTrue(Calls))
		{
			return -1;
		}
		return Calls;
	}

	int OrSkipsRightSide()
	{
		int Calls = 0;
		if (true || RecordFalse(Calls))
		{
			return Calls;
		}
		return -1;
	}

	int RightSideEvaluatesWhenNeeded()
	{
		int Calls = 0;
		if (true && RecordTrue(Calls))
		{
			return Calls;
		}
		return -1;
	}
/** @end */
/**
 * @begin nested-block-shadow
 * @summary An inner block local hides the outer local of the same name.
 * @topic Syntax
 */
int Shadow()
{
	int Value = 1;
	{
		int Value = 2;
		return Value;
	}
}
/** @end */
/**
 * @begin empty-block
 * @summary A function whose only statement is an empty block.
 * @topic Syntax
 */
void Empty()
{
	{
	}
}
/** @end */
