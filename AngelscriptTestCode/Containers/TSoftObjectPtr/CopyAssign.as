/**
 * @version v1
 * @summary Copy assignment from another soft pointer keeps the same resolved object.
 * @topic Containers
 * CopyAssign
 */
/**
 * @begin CopyAssign
 * @summary Copy assignment from another soft pointer keeps the same resolved object.
 * @topic Containers
 */
bool CopyAssign()
{
	UObject LiveCdo = TSubclassOf<UObject>(UObject::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		return false;
	}

	TSoftObjectPtr<UObject> Source = LiveCdo;
	TSoftObjectPtr<UObject> Dest;
	Dest = Source;
	return Dest.Get() == LiveCdo && Dest == Source && Dest.IsValid();
}
/** @end */
