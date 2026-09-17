/**
 * @version v1
 * @summary Iterator GetValue after Proceed reads and writes through the current value.
 * @topic Containers
 *
 * GetValueReturnsStoredValue
 */
/**
 * @begin GetValueReturnsStoredValue
 * @summary Iterator GetValue after Proceed reads and writes through the current value.
 * @topic Containers
 */
bool GetValueReturnsStoredValue()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	TMapIterator<FName, int32> It = Map.Iterator();
	It.Proceed();
	int32& Value = It.GetValue();
	bool bValueIsOne = Value == 1;
	Value = 8;
	const TMap<FName, int32> ConstMap = Map;
	TMapConstIterator<FName, int32> ConstIt = ConstMap.Iterator();
	ConstIt.Proceed();
	return bValueIsOne && Map[n"Alpha"] == 8 && ConstIt.GetValue() == 8;
}
/** @end */
