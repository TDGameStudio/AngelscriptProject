/**
 * @version v1
 * @summary Write [1] on a one-element array throws Array index out of bounds.
 * @topic Containers
 *
 * WritePastEnd
 */
/**
 * @begin WritePastEnd
 * @summary Write [1] on a one-element array throws Array index out of bounds.
 * @topic Containers
 */
void WritePastEnd()
{
	TArray<int32> Values;
	Values.Add(10);
	Values[1] = 20;
}
/** @end */
