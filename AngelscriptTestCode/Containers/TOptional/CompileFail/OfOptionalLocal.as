/**
 * @version v1
 * @summary TOptional of TOptional is rejected: containers cannot be nested in other containers.
 * @topic Containers
 *
 * OfOptionalLocal
 */
/**
 * @begin OfOptionalLocal
 * @summary TOptional of TOptional is rejected: containers cannot be nested in other containers.
 * @topic Containers
 */
void OfOptionalLocal()
{
	TOptional<TOptional<int32>> Optional;
}
/** @end */
