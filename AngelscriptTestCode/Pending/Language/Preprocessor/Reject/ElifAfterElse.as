/**
 * @version v1
 * @summary A #elif directive cannot follow #else in the same chain.
 * @topic Language
 */
/**
 * @version root
 * @summary A #elif directive cannot follow #else in the same chain.
 * @topic Negative
 */
int Entry()
{
#if 1
	return 1;
#else
	return 2;
#elif 0
	return 3;
#endif
}
/** @end */
