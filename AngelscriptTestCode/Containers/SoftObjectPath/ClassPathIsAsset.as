/**
 * @version v1
 * @summary AActor::StaticClass path is an asset; empty and class-subobject paths are not.
 * @topic Containers
 *
 * ClassPathIsAsset
 */
/**
 * @begin ClassPathIsAsset
 * @summary AActor::StaticClass path is an asset; empty and class-subobject paths are not.
 * @topic Containers
 */
bool ClassPathIsAsset()
{
	FSoftClassPath Empty;
	FSoftClassPath ClassPath(AActor::StaticClass());
	FSoftClassPath SubobjectPath("/Script/Engine.Actor:Default__Actor");
	return !Empty.IsAsset() && ClassPath.IsAsset() && !SubobjectPath.IsAsset();
}
/** @end */
