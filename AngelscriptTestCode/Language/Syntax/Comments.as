/**
 * @version v1
 * @summary Line, block, documentation, and escaped-annotation comment forms.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary A function preceded by line and block comments, with an inline comment.
 * @topic Baseline
 */
// single-line comment before the function
/* block comment
   on two lines */
int Commented()
{
	int X = 1; // trailing line comment
	/* inline block */ int Y = 2;
	return X + Y;
}
/** @end */
/**
 * @version valid-escaped-annotation-comment
 * @parent root
 * @summary An escaped annotation comment remains literal source text.
 * @topic Syntax
 */
int Documented()
{
	/** @@point name */
	int X = 1;
	return X;
}
/** @end */
/**
 * @version invalid-unterminated-block-comment
 * @parent root
 * @summary A block comment must close.
 * @topic Negative
 */
int Test()
{
	/* unterminated
	return 1;
}
/** @end */
/**
 * @version valid-block-comment-before-function
 * @parent root
 * @summary Positive language form retained from legacy block comment before function.
 * @topic Syntax
 */
void Test()
	{
		int X = 1;
	}
/** @end */
/**
 * @version valid-block-comment-with-separate-markers
 * @parent root
 * @summary Positive language form retained from legacy block comment with separate markers.
 * @topic Syntax
 */
void Test()
	{
	}
/** @end */
/**
 * @version valid-comment-before-function
 * @parent root
 * @summary Positive language form retained from legacy comment before function.
 * @topic Syntax
 */
void Test()
	{
		int X = 1;
	}
/** @end */
/**
 * @version valid-documentation-comment
 * @parent root
 * @summary Positive language form retained from legacy documentation comment.
 * @topic Syntax
 */
int DocumentationCommented()
	{
		return 3;
	}
/** @end */
/**
 * @version valid-inline-comment-inside-function
 * @parent root
 * @summary Positive language form retained from legacy inline comment inside function.
 * @topic Syntax
 */
void Test()
	{
		int X = 1; // inline comment
		int Y = 2; /* block */ int Z = 3;
	}
/** @end */
/**
 * @version valid-multi-line-block-comment
 * @parent root
 * @summary Positive language form retained from legacy multi line block comment.
 * @topic Syntax
 */
int MultiLineCommented()
	{
		int Value = 2;
		/* Inline block comment */ return Value;
	}
/** @end */
/**
 * @version valid-range-based-for-rewrite-skips-literals
 * @parent root
 * @summary Positive language form retained from legacy range based for rewrite skips literals.
 * @topic Syntax
 */
int Entry()
	{
		array<int> Values;
		Values.insertLast(20);
		Values.insertLast(22);

		string LoopText = "for (const int Value : Values)";
		// for (const int Value : Values)
		/* for (const int Value : Values) */

		int Sum = 0;
		for (const int Value : Values)
		{
			Sum += Value;
		}

		if (LoopText != "for (const int Value : Values)")
		{
			return 10;
		}

		return Sum;
	}
/** @end */
/**
 * @version valid-single-line-comment
 * @parent root
 * @summary Positive language form retained from legacy single line comment.
 * @topic Syntax
 */
int SingleLineCommented()
	{
		int Value = 1; // Inline single-line comment.
		return Value;
	}
/** @end */
/**
 * @version valid-comment-in-string-is-literal
 * @parent root
 * @summary Comment markers inside a string remain payload.
 * @topic Syntax
 */
string Text()
{
	return "/* not a comment */ // still a string";
}
/** @end */
