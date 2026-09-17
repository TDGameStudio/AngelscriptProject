/**
 * @version v1
 * @summary Named argument calls with mixed positional order.
 * @topic Language
 * @topic Syntax
 *
 * named-arguments
 * named-arguments-all-named
 * named-arguments-trailing-only
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
