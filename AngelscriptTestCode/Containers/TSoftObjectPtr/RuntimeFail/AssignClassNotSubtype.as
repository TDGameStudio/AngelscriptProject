/**
 * @version v1
 * @summary Assigning UObject::StaticClass() to TSoftClassPtr<AActor> throws Provided class is does not inherit from TSoftClassPtr subtype.
 * @topic Containers
 * AssignClassNotSubtype
 */
/**
 * @begin AssignClassNotSubtype
 * @summary Assigning UObject::StaticClass() to TSoftClassPtr<AActor> throws Provided class is does not inherit from TSoftClassPtr subtype.
 * @topic Containers
 */
void AssignClassNotSubtype()
{
	TSoftClassPtr<AActor> ClassRef;
	ClassRef = UObject::StaticClass();
}
/** @end */
