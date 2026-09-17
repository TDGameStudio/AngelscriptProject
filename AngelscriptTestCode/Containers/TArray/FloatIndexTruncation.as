/**
 * @version v1
 * @summary Float indices truncate toward zero: 0.5f and 0.0f read slot 0, 1.9f reads slot 1.
 * @topic Containers
 *
 * FloatIndexTruncation
 */
/**
 * @begin FloatIndexTruncation
 * @summary Float indices truncate toward zero: 0.5f and 0.0f read slot 0, 1.9f reads slot 1.
 * @topic Containers
 */
bool FloatIndexTruncation()
{
	TArray<int32> Half;
	Half.Add(1);
	if (Half[0.5f] != 1)
	{
		return false;
	}

	TArray<int32> Zero;
	Zero.Add(7);
	if (Zero[0.0f] != 7)
	{
		return false;
	}

	TArray<int32> Trunc;
	Trunc.Add(1);
	Trunc.Add(2);
	return Trunc[1.9f] == 2;
}
/** @end */
