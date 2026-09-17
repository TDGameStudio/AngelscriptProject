/**
 * @version v1
 * @summary A property setter accepts only a value matching its parameter type.
 * @topic Language
 * @topic Properties
 */
/**
 * @version root
 * @summary set_Value(int) stores 4; reading the backing field returns 4.
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

int WriteInt()
{
	AHolder Object;
	Object.Value = 4;
	return Object.Stored;
}
/** @end */
/**
 * @version invalid-setter-string-for-int
 * @parent root
 * @summary A string cannot be assigned to an int property setter.
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

void Test()
{
	AHolder Object;
	Object.Value = "nope";
}
/** @end */
/**
 * @version invalid-setter-bool-for-int
 * @parent root
 * @summary A bool cannot be assigned to an int property setter.
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

void Test()
{
	AHolder Object;
	Object.Value = true;
}
/** @end */
