/**
 * @version v1
 * @summary Copy-constructing from a pointer copies the same target.
 * @topic Containers
 *
 * CopyConstructFromPointer
 */
/**
 * @begin CopyConstructFromPointer
 * @summary Copy-constructing from a pointer copies the same target.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrCopyConstructTarget : UObject
{
}

bool CopyConstructFromPointer()
{
	UObject Target = NewObject(GetTransientPackage(), UTObjectPtrCopyConstructTarget::StaticClass(), n"TObjPtrCopy_Source", true);
	if (Target == nullptr)
	{
		return false;
	}

	TObjectPtr<UObject> Source;
	Source = Target;
	TObjectPtr<UObject> Copied(Source);
	return Copied.Get() == Target && Copied == Source;
}
/** @end */
