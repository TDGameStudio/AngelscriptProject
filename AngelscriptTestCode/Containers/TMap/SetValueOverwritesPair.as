/**
 * @version v1
 * @summary Iterator SetValue after Proceed replaces the current pair value.
 * @topic Containers
 *
 * SetValueOverwritesPair
 */
/**
 * @begin SetValueOverwritesPair
 * @summary Iterator SetValue after Proceed replaces the current pair value.
 * @topic Containers
 */
bool SetValueOverwritesPair()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	TMapIterator<FName, int32> It = Map.Iterator();
	It.Proceed();
	It.SetValue(8);
	return Map[n"Alpha"] == 8 && It.GetValue() == 8;
}
/** @end */
