/**
 * @version v1
 * @summary Named argument calls with mixed positional order.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary A call that names later arguments and keeps one positional.
 * @topic Baseline
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
 * @version invalid-named-unknown
 * @parent root
 * @summary A named argument must match a parameter name.
 * @topic Negative
 */
int Mix(int First, int Second)
{
	return First + Second;
}

int Test()
{
	return Mix(First: 1, Missing: 2);
}
/** @end */
/**
 * @version invalid-named-duplicate
 * @parent root
 * @summary The same parameter cannot be named twice.
 * @topic Negative
 */
int Mix(int First, int Second)
{
	return First + Second;
}

int Test()
{
	return Mix(First: 1, First: 2);
}
/** @end */
/**
 * @version invalid-named-argument-duplicate-name
 * @parent root
 * @summary Compile-rejection form retained from legacy named argument duplicate name.
 * @topic Negative
 */
int Mix(int A, int B, int C)
{
	return 0;
}

int Run()
{
	return Mix(A: 1, A: 2, C: 3);
}
/** @end */
/**
 * @version invalid-named-argument-unknown-name
 * @parent root
 * @summary Compile-rejection form retained from legacy named argument unknown name.
 * @topic Negative
 */
int Mix(int A, int B, int C)
{
	return 0;
}

int Run()
{
	return Mix(A: 1, D: 2, C: 3);
}
/** @end */
/**
 * @version valid-named-arguments-all-named
 * @parent root
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
 * @version valid-named-arguments-trailing-only
 * @parent root
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
