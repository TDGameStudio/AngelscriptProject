/**
 * @version v1
 * @summary A setter-only virtual property cannot be read.
 * @topic Language
 * @topic Properties
 */
/**
 * @version root
 * @summary Writing a setter-only property is legal.
 * @topic Baseline
 */
class AHolder
{
	int Stored;

	void set_Value(int InValue) property
	{
		Stored = InValue;
	}
}

void WriteOnly()
{
	AHolder Object;
	Object.Value = 1;
}
/** @end */
/**
 * @version invalid-read-without-getter
 * @parent root
 * @summary Reading a setter-only property is rejected.
 * @topic Negative
 */
class AHolder
{
	int Stored;

	void set_Value(int InValue) property
	{
		Stored = InValue;
	}
}

int Test()
{
	AHolder Object;
	return Object.Value;
}
/** @end */
