/**
 * @version v1
 * @summary Line, block, documentation, and escaped-annotation comment forms.
 * @topic Language
 * @topic Syntax
 *
 * comments                                  // A function preceded by line and block comments, with an inline comment.
 * escaped-annotation-comment                // An escaped annotation comment remains literal source text.
 * block-comment-before-function             // Positive language form retained from legacy block comment before function.
 * block-comment-with-separate-markers       // Positive language form retained from legacy block comment with separate markers.
 * comment-before-function                   // Positive language form retained from legacy comment before function.
 * documentation-comment                     // Positive language form retained from legacy documentation comment.
 * inline-comment-inside-function            // Positive language form retained from legacy inline comment inside function.
 * multi-line-block-comment                  // Positive language form retained from legacy multi line block comment.
 * range-based-for-rewrite-skips-literals    // Positive language form retained from legacy range based for rewrite skips literals.
 * single-line-comment                       // Positive language form retained from legacy single line comment.
 * comment-in-string-is-literal              // Comment markers inside a string remain payload.
 */
/**
 * @begin comments
 * @summary A function preceded by line and block comments, with an inline comment.
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
 * @begin escaped-annotation-comment
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
 * @begin block-comment-before-function
 * @summary Positive language form retained from legacy block comment before function.
 * @topic Syntax
 */
void Test()
	{
		int X = 1;
	}
/** @end */
/**
 * @begin block-comment-with-separate-markers
 * @summary Positive language form retained from legacy block comment with separate markers.
 * @topic Syntax
 */
void Test()
	{
	}
/** @end */
/**
 * @begin comment-before-function
 * @summary Positive language form retained from legacy comment before function.
 * @topic Syntax
 */
void Test()
	{
		int X = 1;
	}
/** @end */
/**
 * @begin documentation-comment
 * @summary Positive language form retained from legacy documentation comment.
 * @topic Syntax
 */
int DocumentationCommented()
	{
		return 3;
	}
/** @end */
/**
 * @begin inline-comment-inside-function
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
 * @begin multi-line-block-comment
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
 * @begin range-based-for-rewrite-skips-literals
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
 * @begin single-line-comment
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
 * @begin comment-in-string-is-literal
 * @summary Comment markers inside a string remain payload.
 * @topic Syntax
 */
string Text()
{
	return "/* not a comment */ // still a string";
}
/** @end */
