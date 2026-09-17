/**
 * @version v1
 * @summary Preprocessor if, elif, else, and endif branch skeletons.
 * @topic Language
 * @topic Preprocessor
 */
/**
 * @version root
 * @summary A three-arm directive chain selecting among integer returns.
 * @topic Baseline
 * @topic SourceOnly
 */
int Entry()
{
#if FIRST_BRANCH
	return 1;
#elif SECOND_BRANCH
	return 2;
#else
	return 3;
#endif
}
/** @end */
/**
 * @version valid-editor-flag-branch
 * @parent root
 * @summary A single #if/#else pair guarded by an editor configuration flag.
 * @topic Preprocessor
 * @topic SourceOnly
 */
int EditorBranch()
{
#if WITH_EDITOR
	return 1;
#else
	return 0;
#endif
}
/** @end */
/**
 * @version invalid-missing-endif
 * @parent root
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
 * @version valid-editor-configuration-flag-branch
 * @parent root
 * @summary Positive language form retained from legacy editor configuration flag branch.
 * @topic Preprocessor
 * @topic SourceOnly
 */
int Entry()
	{
#if EDITOR
		return 11;
#else
		return -11;
#endif
	}
/** @end */
/**
 * @version valid-if-elif-endif-no-else
 * @parent root
 * @summary If/elif/endif chain without an else arm.
 * @topic Preprocessor
 * @topic SourceOnly
 */
int Entry()
{
#if FIRST
	return 1;
#elif SECOND
	return 2;
#endif
	return 0;
}
/** @end */
/**
 * @version valid-nested-if-directives
 * @parent root
 * @summary An inner #if nested inside an outer #if/#endif.
 * @topic Preprocessor
 * @topic SourceOnly
 */
int Entry()
{
#if OUTER
#if INNER
	return 1;
#endif
	return 2;
#else
	return 0;
#endif
}
/** @end */
/**
 * @version valid-if-zero-dead-branch
 * @parent root
 * @summary A #if 0 branch is source text that is not selected.
 * @topic Preprocessor
 * @topic SourceOnly
 */
int Entry()
{
#if 0
	return 1;
#else
	return 0;
#endif
}
/** @end */
/**
 * @version invalid-elif-without-if
 * @parent root
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
 * @version invalid-endif-without-if
 * @parent root
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
