/**
 * @version v1
 * @summary Compile-fail cases for Blocks.
 * @topic Language
 * @topic Syntax
 *
 * invalid-unmatched-opening-brace
 * invalid-extra-closing-brace
 * invalid-garbage-tokens
 * invalid-missing-semicolon-between-declarations
 * invalid-out-of-scope-use
 * invalid-top-level-assignment
 * invalid-unmatched-parenthesis
 * invalid-syntax-error-missing-semicolon
 */
/**
 * @begin invalid-unmatched-opening-brace
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
 * @begin invalid-extra-closing-brace
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
 * @begin invalid-garbage-tokens
 * @summary Compile-rejection form retained from legacy garbage tokens.
 * @topic Negative
 */
asdfgh jklmn @#$%
/** @end */
/**
 * @begin invalid-missing-semicolon-between-declarations
 * @summary Compile-rejection form retained from legacy missing semicolon between declarations.
 * @topic Negative
 */
void Test()
{
	int X = 1 int Y = 2;
}
/** @end */
/**
 * @begin invalid-out-of-scope-use
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
 * @begin invalid-top-level-assignment
 * @summary Compile-rejection form retained from legacy top level assignment.
 * @topic Negative
 */
int X = 5;
X = 10;
/** @end */
/**
 * @begin invalid-unmatched-parenthesis
 * @summary Compile-rejection form retained from legacy unmatched parenthesis.
 * @topic Negative
 */
void Test()
{
	int X = (1 + 2;
}
/** @end */
/**
 * @begin invalid-syntax-error-missing-semicolon
 * @summary Adjacent declarations require a semicolon.
 * @topic Negative
 */
void Test()
{
	int Left = 1
	int Right = 2;
}
/** @end */
