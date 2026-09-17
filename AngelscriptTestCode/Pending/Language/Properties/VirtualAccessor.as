/**
 * @version v1
 * @summary A read-write virtual property with get_ and set_.
 * @topic Language
 * @topic Properties
 */
/**
 * @version root
 * @summary Object.Value reads and writes through the accessors.
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

int UseProperty()
{
	AHolder Object;
	Object.Value = 6;
	return Object.Value;
}
/** @end */
/**
 * @version valid-compound-assignment
 * @parent root
 * @summary A read-write property accepts compound assignment.
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

int UseCompound()
{
	AHolder Object;
	Object.Value = 10;
	Object.Value += 3;
	return Object.Value;
}
/** @end */
/**
 * @version valid-property-overwrite
 * @parent root
 * @summary A later property write replaces the earlier stored value.
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

int UseOverwrite()
{
	AHolder Object;
	Object.Value = 2;
	Object.Value = 9;
	return Object.Value;
}
/** @end */
