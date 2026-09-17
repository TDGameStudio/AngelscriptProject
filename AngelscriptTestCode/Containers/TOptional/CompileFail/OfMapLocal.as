/**
 * @version v1
 * @summary TOptional of TMap is rejected: containers cannot be nested in other containers.
 * @topic Containers
 *
 * OfMapLocal
 */
/**
 * @begin OfMapLocal
 * @summary TOptional of TMap is rejected: containers cannot be nested in other containers.
 * @topic Containers
 */
void OfMapLocal()
{
	TOptional<TMap<int32, int32>> Optional;
}
/** @end */
