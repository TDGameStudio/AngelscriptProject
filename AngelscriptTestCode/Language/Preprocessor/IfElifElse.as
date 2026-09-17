/**
 * @version v1
 * @summary Preprocessor if, elif, else, and endif branch skeletons.
 * @topic Language
 * @topic Preprocessor
 *
 * if-elif-else
 * editor-flag-branch
 * editor-configuration-flag-branch
 * if-elif-endif-no-else
 * nested-if-directives
 * if-zero-dead-branch
 */
/**
 * @begin if-elif-else
 * @summary A three-arm directive chain selecting among integer returns.
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
 * @begin editor-flag-branch
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
 * @begin editor-configuration-flag-branch
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
 * @begin if-elif-endif-no-else
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
 * @begin nested-if-directives
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
 * @begin if-zero-dead-branch
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
