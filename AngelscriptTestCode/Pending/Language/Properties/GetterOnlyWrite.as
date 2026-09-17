/**
 * @version v1
 * @summary A getter-only virtual property cannot be assigned.
 * @topic Language
 * @topic Properties
 */
/**
 * @version root
 * @summary Reading a getter-only property is legal.
 * @topic Baseline
 */
class AHolder
{
	int Stored;

	int get_Value() property
	{
		return Stored;
	}
}

int ReadOnly()
{
	AHolder Object;
	return Object.Value;
}
/** @end */
/**
 * @version invalid-write-without-setter
 * @parent root
 * @summary Assigning a getter-only property is rejected.
 * @topic Negative
 */
class AHolder
{
	int Stored;

	int get_Value() property
	{
		return Stored;
	}
}

void Test()
{
	AHolder Object;
	Object.Value = 1;
}
/** @end */
