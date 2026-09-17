/**
 * @version v1
 * @summary Nested blocks, chained addition, and short-circuit skip forms.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary Deep blocks, parenthesized addition, a long chain, and short-circuit skip.
 * @topic Baseline
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
 * @version invalid-unmatched-opening-brace
 * @parent root
 * @summary A block must close.
 * @topic Negative
 */
int Test()
{
	{
		return 1;
}
/** @end */
/**
 * @version invalid-extra-closing-brace
 * @parent root
 * @summary An extra closing brace is invalid.
 * @topic Negative
 */
int Test()
{
	return 1;
}
}
/** @end */
/**
 * @version valid-deeply-parenthesized-addition
 * @parent root
 * @summary Positive language form retained from legacy deeply parenthesized addition.
 * @topic Syntax
 */
void Test()
	{
		int X = ((((1 + 2))));
	}
/** @end */
/**
 * @version valid-long-chained-addition
 * @parent root
 * @summary Positive language form retained from legacy long chained addition.
 * @topic Syntax
 */
void Test()
	{
		int X = 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 10 + 11 + 12 + 13 + 14 + 15;
	}
/** @end */
/**
 * @version valid-multiple-statements-in-one-function
 * @parent root
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
 * @version valid-short-circuit-skips-right-hand-side
 * @parent root
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
 * @version invalid-garbage-tokens
 * @parent root
 * @summary Compile-rejection form retained from legacy garbage tokens.
 * @topic Negative
 */
asdfgh jklmn @#$%
/** @end */
/**
 * @version invalid-missing-semicolon-between-declarations
 * @parent root
 * @summary Compile-rejection form retained from legacy missing semicolon between declarations.
 * @topic Negative
 */
void Test()
{
	int X = 1 int Y = 2;
}
/** @end */
/**
 * @version invalid-out-of-scope-use
 * @parent root
 * @summary Compile-rejection form retained from legacy out of scope use.
 * @topic Negative
 */
int Entry()
{
	{
		int Inner = 2;
	}
	return Inner;
}
/** @end */
/**
 * @version invalid-top-level-assignment
 * @parent root
 * @summary Compile-rejection form retained from legacy top level assignment.
 * @topic Negative
 */
int X = 5;
X = 10;
/** @end */
/**
 * @version invalid-unmatched-parenthesis
 * @parent root
 * @summary Compile-rejection form retained from legacy unmatched parenthesis.
 * @topic Negative
 */
void Test()
{
	int X = (1 + 2;
}
/** @end */
/**
 * @version invalid-syntax-error-missing-semicolon
 * @parent root
 * @summary Adjacent declarations require a semicolon.
 * @topic Negative
 */
void Test()
{
	int Left = 1
	int Right = 2;
}
/** @end */
