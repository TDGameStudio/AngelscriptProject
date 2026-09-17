/**
 * @version v1
 * @summary A class subobject path is a subobject; empty and AActor::StaticClass paths are not.
 * @topic Containers
 *
 * ClassPathIsSubobject
 */
/**
 * @begin ClassPathIsSubobject
 * @summary A class subobject path is a subobject; empty and AActor::StaticClass paths are not.
 * @topic Containers
 */
bool ClassPathIsSubobject()
{
	FSoftClassPath Empty;
	FSoftClassPath ClassPath(AActor::StaticClass());
	FSoftClassPath SubobjectPath("/Script/Engine.Actor:Default__Actor");
	return !Empty.IsSubobject() && !ClassPath.IsSubobject() && SubobjectPath.IsSubobject();
}
/** @end */
