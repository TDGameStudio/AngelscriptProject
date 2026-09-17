/**
 * @version v1
 * @summary A #else directive cannot appear without an open #if.
 * @topic Language
 */
/**
 * @version root
 * @summary A #else directive cannot appear without an open #if.
 * @topic Negative
 */
int Entry()
{
#else
	return 1;
#endif
	return 0;
}
/** @end */
