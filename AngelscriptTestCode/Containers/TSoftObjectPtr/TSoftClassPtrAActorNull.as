/**
 * @version v1
 * @summary Default TSoftClassPtr<AActor> is null and Get is invalid.
 * @topic Containers
 * TSoftClassPtrAActorNull
 */
/**
 * @begin TSoftClassPtrAActorNull
 * @summary Default TSoftClassPtr<AActor> is null and Get is invalid.
 * @topic Containers
 */
bool TSoftClassPtrAActorNull()
{
	TSoftClassPtr<AActor> ClassRef;
	return ClassRef.IsNull() && !ClassRef.Get().IsValid();
}
/** @end */
