/**
 * @version v1
 * @summary Add appends float values in insertion order.
 * @topic Containers
 *
 * AddAndOrderFloat
 */
/**
 * @begin AddAndOrderFloat
 * @summary Add appends float values in insertion order.
 * @topic Containers
 */
bool AddAndOrderFloat()
{
	TArray<float> Values;
	Values.Add(10.0f);
	Values.Add(20.0f);
	return Values.Num() == 2 && Values[0] == 10.0f && Values[1] == 20.0f;
}
/** @end */
