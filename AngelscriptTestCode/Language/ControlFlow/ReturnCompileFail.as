/**
 * @version v1
 * @summary Compile-fail cases for Return.
 * @topic Language
 * @topic ControlFlow
 *
 * invalid-missing-return
 * invalid-return-type-mismatch
 * invalid-return-string-for-int
 * invalid-return-value-in-void-function
 * invalid-return-without-value-in-int-function
 */
/**
 * @begin invalid-missing-return
 * @summary A value-returning function cannot fall off the end.
 * @topic Negative
 */
int Test(bool Flag)
{
	if (Flag)
	{
		return 1;
	}
}
/** @end */
/**
 * @begin invalid-return-type-mismatch
 * @summary A boolean cannot be returned from an integer function.
 * @topic Negative
 */
int Test()
{
	return true;
}
/** @end */
/**
 * @begin invalid-return-string-for-int
 * @summary Compile-rejection form retained from legacy return string for int.
 * @topic Negative
 */
int Test()
{
	return "hello";
}
/** @end */
/**
 * @begin invalid-return-value-in-void-function
 * @summary Compile-rejection form retained from legacy return value in void function.
 * @topic Negative
 */
void Test()
{
	return 5;
}
/** @end */
/**
 * @begin invalid-return-without-value-in-int-function
 * @summary Compile-rejection form retained from legacy return without value in int function.
 * @topic Negative
 */
int Test()
{
	return;
}
/** @end */
