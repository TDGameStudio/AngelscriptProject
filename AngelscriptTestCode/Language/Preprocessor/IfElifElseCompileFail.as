/**
 * @version v1
 * @summary Compile-fail cases for IfElifElse.
 * @topic Language
 * @topic Preprocessor
 *
 * invalid-missing-endif
 * invalid-elif-without-if
 * invalid-endif-without-if
 */
/**
 * @begin invalid-missing-endif
 * @summary A #if chain must close with #endif.
 * @topic Negative
 * @topic SourceOnly
 */
int Test()
{
#if FLAG
	return 1;
#else
	return 0;
}
/** @end */
/**
 * @begin invalid-elif-without-if
 * @summary Elif cannot appear without an open if.
 * @topic Negative
 * @topic SourceOnly
 */
int Test()
{
#elif FLAG
	return 1;
#endif
	return 0;
}
/** @end */
/**
 * @begin invalid-endif-without-if
 * @summary Endif cannot appear without an open if.
 * @topic Negative
 * @topic SourceOnly
 */
int Test()
{
#endif
	return 0;
}
/** @end */
