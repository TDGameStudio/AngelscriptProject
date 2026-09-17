/**
 * @version v1
 * @summary Typed function returns including early and nested return.
 * @topic Language
 * @topic Syntax
 *
 * function-return          // A function that returns a constant integer.
 * return-bool              // A function that returns a boolean literal.
 * return-float             // A function that returns a float literal.
 * return-void-early        // A void function returns before later statements.
 * return-string            // A function that returns a string literal.
 * return-from-nested-if    // A return inside a nested if leaves the function.
 */
/**
 * @begin function-return
 * @summary A function that returns a constant integer.
 */
int Answer()
{
	return 42;
}
/** @end */
/**
 * @begin return-bool
 * @summary A function that returns a boolean literal.
 * @topic Syntax
 */
bool Ready()
{
	return true;
}
/** @end */
/**
 * @begin return-float
 * @summary A function that returns a float literal.
 * @topic Syntax
 */
float Scale()
{
	return 1.5f;
}
/** @end */
/**
 * @begin return-void-early
 * @summary A void function returns before later statements.
 * @topic Syntax
 */
void EarlyExit(bool Flag)
{
	if (Flag)
	{
		return;
	}
	int Kept = 1;
}
/** @end */
/**
 * @begin return-string
 * @summary A function that returns a string literal.
 * @topic Syntax
 */
string Message()
{
	return "ok";
}
/** @end */
/**
 * @begin return-from-nested-if
 * @summary A return inside a nested if leaves the function.
 * @topic Syntax
 */
int NestedReturn(bool Outer, bool Inner)
{
	if (Outer)
	{
		if (Inner)
		{
			return 1;
		}
	}
	return 0;
}
/** @end */
