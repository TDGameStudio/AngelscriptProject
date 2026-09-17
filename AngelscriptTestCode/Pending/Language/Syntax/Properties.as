/**
 * @version v1
 * @summary Script virtual properties with get_ and set_ accessors.
 * @topic Language
 * @topic Syntax
 */
/**
 * @version root
 * @summary A class exposes a read-write virtual property.
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
 * @version valid-const-getter
 * @parent root
 * @summary A const getter may be read from a const receiver.
 * @topic Syntax
 */
class AHolder
{
	int Stored;

	int get_Value() const property
	{
		return Stored;
	}
}

int ReadConst(const AHolder@ Object)
{
	return Object.Value;
}
/** @end */
/**
 * @version valid-indexed-property
 * @parent root
 * @summary A virtual property may take an index argument.
 * @topic Syntax
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
 * @version valid-compound-assignment
 * @parent root
 * @summary A read-write property accepts compound assignment.
 * @topic Syntax
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
 * @version invalid-write-without-setter
 * @parent root
 * @summary A getter-only property cannot be assigned.
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
/**
 * @version invalid-read-without-getter
 * @parent root
 * @summary A setter-only property cannot be read.
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
/**
 * @version invalid-nonconst-getter-on-const
 * @parent root
 * @summary A non-const getter cannot be read from a const receiver.
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

int Test(const AHolder@ Object)
{
	return Object.Value;
}
/** @end */
