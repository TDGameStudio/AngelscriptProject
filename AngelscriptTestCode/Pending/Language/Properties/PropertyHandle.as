/**
 * @version v1
 * @summary A read-write virtual property can be used through a handle.
 * @topic Language
 * @topic Properties
 */
/**
 * @version root
 * @summary Object.Value = 6 through a handle reads back 6.
 * @topic Baseline
 */
class AHolder
{
	int Stored;

	int get_Value() property
	{
		return Stored;
	}

	void set_Value(int InValue) property
	{
		Stored = InValue;
	}
}

int UseHandle(AHolder@ Object)
{
	Object.Value = 6;
	return Object.Value;
}
/** @end */
/**
 * @version valid-handle-property-overwrite
 * @parent root
 * @summary A later handle write replaces the earlier property value.
 * @topic Properties
 */
class AHolder
{
	int Stored;

	int get_Value() property
	{
		return Stored;
	}

	void set_Value(int InValue) property
	{
		Stored = InValue;
	}
}

int UseOverwrite(AHolder@ Object)
{
	Object.Value = 1;
	Object.Value = 9;
	return Object.Value;
}
/** @end */
/**
 * @version invalid-unknown-property-on-handle
 * @parent root
 * @summary A handle cannot write a property name with no get_ or set_ accessor.
 * @topic Negative
 */
class AHolder
{
	int Stored;
}

void Test(AHolder@ Object)
{
	Object.Value = 1;
}
/** @end */
