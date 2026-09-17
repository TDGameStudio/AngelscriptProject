/**
 * @version v1
 * @summary Proceed moves onto the first pair so GetKey and GetValue are valid.
 * @topic Containers
 *
 * IteratorProceed
 */
/**
 * @begin IteratorProceed
 * @summary Proceed moves onto the first pair so GetKey and GetValue are valid.
 * @topic Containers
 */
bool IteratorProceed()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	Map.Add(n"Beta", 2);
	TMapIterator<FName, int32> It = Map.Iterator();
	bool bCanEnter = It.CanProceed;
	TMapIterator<FName, int32>& Alias = It.Proceed();
	const FName& Key = Alias.GetKey();
	int32& Value = Alias.GetValue();
	int32 Before = Value;
	Value = Before + 10;
	bool bAliasWroteThrough = Map[Key] == Before + 10;
	if (Alias.CanProceed)
	{
		Alias.Proceed();
	}
	const TMap<FName, int32> ConstMap = Map;
	TMapConstIterator<FName, int32> ConstIt = ConstMap.Iterator();
	TMapConstIterator<FName, int32>& ConstAlias = ConstIt.Proceed();
	const FName& ConstKey = ConstAlias.GetKey();
	const int32& ConstValue = ConstAlias.GetValue();
	return bCanEnter && Map.Contains(Key) && bAliasWroteThrough
		&& ConstMap.Contains(ConstKey) && ConstValue == ConstMap[ConstKey];
}
/** @end */
