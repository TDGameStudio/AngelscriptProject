/**
 * @version v1
 * @summary Named argument calls with mixed positional order.
 * @topic Language
 * @topic Syntax
 *
 * named-arguments                                // A call that names later arguments and keeps one positional.
 * named-arguments-all-named                      // A call that names every argument.
 * named-arguments-trailing-only                  // A call that names only the trailing argument.
 * named-arguments-mixed-positional-then-named    // A call that keeps a leading positional then names the rest.
 * named-arguments-default-skipped                // A named later argument skips a defaulted middle parameter.
 */
/**
 * @begin named-arguments
 * @summary A call that names later arguments and keeps one positional.
 */
int Mix(int First, int Second, int Third)
{
	return First + Second * 10 + Third * 100;
}

int NamedPartial()
{
	return Mix(1, Third: 3, Second: 2);
}
/** @end */
/**
 * @begin named-arguments-all-named
 * @summary A call that names every argument.
 * @topic Syntax
 */
int Combine(int Left, int Right)
{
	return Left + Right;
}

int CallNamed()
{
	return Combine(Left = 2, Right = 3);
}
/** @end */
/**
 * @begin named-arguments-trailing-only
 * @summary A call that names only the trailing argument.
 * @topic Syntax
 */
int Combine(int Left, int Right)
{
	return Left + Right;
}

int CallPartial()
{
	return Combine(2, Right = 3);
}
/** @end */
/**
 * @begin named-arguments-mixed-positional-then-named
 * @summary A call that keeps a leading positional then names the rest.
 * @topic Syntax
 */
int Mix(int First, int Second, int Third)
{
	return First + Second * 10 + Third * 100;
}

int CallMixed()
{
	return Mix(1, Second: 2, Third: 3);
}
/** @end */
/**
 * @begin named-arguments-default-skipped
 * @summary A named later argument skips a defaulted middle parameter.
 * @topic Syntax
 */
int Mix(int First, int Second = 2, int Third = 3)
{
	return First + Second + Third;
}

int CallSkip()
{
	return Mix(1, Third: 3);
}
/** @end */
