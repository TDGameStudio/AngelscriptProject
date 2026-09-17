/**
 * @version v1
 * @summary Compile-fail cases for NamedArguments.
 * @topic Language
 * @topic Syntax
 *
 * invalid-named-unknown
 * invalid-named-duplicate
 * invalid-named-argument-duplicate-name
 * invalid-named-argument-unknown-name
 */
/**
 * @begin invalid-named-unknown
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
 * @begin invalid-named-duplicate
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
 * @begin invalid-named-argument-duplicate-name
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
 * @begin invalid-named-argument-unknown-name
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
