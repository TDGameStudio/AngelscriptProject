/**
 * @version v1
 * @summary A virtual property that takes an index argument.
 * @topic Language
 * @topic Properties
 */
/**
 * @version root
 * @summary Object.Value[i] reads and writes indexed accessors.
 * @topic Baseline
 */
class ASlots
{
	int First;
	int Second;

	int get_Value(int Index) property
	{
		if (Index == 0)
		{
			return First;
		}
		return Second;
	}

	void set_Value(int Index, int InValue) property
	{
		if (Index == 0)
		{
			First = InValue;
		}
		else
		{
			Second = InValue;
		}
	}
}

int UseIndexed()
{
	ASlots Object;
	Object.Value[0] = 2;
	Object.Value[1] = 5;
	return Object.Value[0] + Object.Value[1];
}
/** @end */
/**
 * @version valid-indexed-overwrite
 * @parent root
 * @summary A later indexed write replaces the value at that index.
 * @topic Properties
 */
class ASlots
{
	int First;
	int Second;

	int get_Value(int Index) property
	{
		if (Index == 0)
		{
			return First;
		}
		return Second;
	}

	void set_Value(int Index, int InValue) property
	{
		if (Index == 0)
		{
			First = InValue;
		}
		else
		{
			Second = InValue;
		}
	}
}

int UseOverwrite()
{
	ASlots Object;
	Object.Value[0] = 2;
	Object.Value[0] = 8;
	return Object.Value[0];
}
/** @end */
/**
 * @version invalid-indexed-without-subscript
 * @parent root
 * @summary An indexed property cannot be read as a scalar.
 * @topic Negative
 */
class ASlots
{
	int First;

	int get_Value(int Index) property
	{
		return First;
	}

	void set_Value(int Index, int InValue) property
	{
		First = InValue;
	}
}

int Test()
{
	ASlots Object;
	return Object.Value;
}
/** @end */
