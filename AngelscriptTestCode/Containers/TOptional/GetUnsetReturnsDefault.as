/**
 * @version v1
 * @summary Get on an unset TOptional returns the fallback and stays unset.
 * @topic Containers
 *
 * GetUnsetReturnsDefault
 */
/**
 * @begin GetUnsetReturnsDefault
 * @summary Get on an unset TOptional returns the fallback and stays unset.
 * @topic Containers
 */
bool GetUnsetReturnsDefault()
{
	TOptional<int32> Optional;
	return Optional.Get(7) == 7 && !Optional.IsSet();
}
/** @end */
