/**
 * @version v1
 * @summary An empty FSoftClassPath is null; AActor::StaticClass path is not null.
 * @topic Containers
 *
 * ClassPathIsNull
 */
/**
 * @begin ClassPathIsNull
 * @summary An empty FSoftClassPath is null; AActor::StaticClass path is not null.
 * @topic Containers
 */
bool ClassPathIsNull()
{
	FSoftClassPath Empty;
	FSoftClassPath ClassPath(AActor::StaticClass());
	return Empty.IsNull() && !ClassPath.IsNull();
}
/** @end */
