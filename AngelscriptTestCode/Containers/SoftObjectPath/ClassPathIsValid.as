/**
 * @version v1
 * @summary An empty FSoftClassPath is not valid; AActor::StaticClass path is valid.
 * @topic Containers
 *
 * ClassPathIsValid
 */
/**
 * @begin ClassPathIsValid
 * @summary An empty FSoftClassPath is not valid; AActor::StaticClass path is valid.
 * @topic Containers
 */
bool ClassPathIsValid()
{
	FSoftClassPath Empty;
	FSoftClassPath ClassPath(AActor::StaticClass());
	return !Empty.IsValid() && ClassPath.IsValid();
}
/** @end */
