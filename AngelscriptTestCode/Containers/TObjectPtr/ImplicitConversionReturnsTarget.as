/**
 * @version v1
 * @summary Implicit conversion returns the assigned object.
 * @topic Containers
 *
 * ImplicitConversionReturnsTarget
 */
/**
 * @begin ImplicitConversionReturnsTarget
 * @summary Implicit conversion returns the assigned object.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrImplicitConversionTarget : UObject
{
}

bool ImplicitConversionReturnsTarget()
{
	UObject Target = NewObject(GetTransientPackage(), UTObjectPtrImplicitConversionTarget::StaticClass(), n"TObjPtrAssign_Conv", true);
	if (Target == nullptr)
	{
		return false;
	}

	TObjectPtr<UObject> Ptr;
	Ptr = Target;
	UObject Resolved = Ptr;
	return Resolved == Target;
}
/** @end */
