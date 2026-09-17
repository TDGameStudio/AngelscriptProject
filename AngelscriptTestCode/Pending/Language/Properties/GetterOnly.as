/**
 * @version v1
 * @summary A getter-only property can be read and returns the stored value.
 * @topic Language
 * @topic Properties
 */
/**
 * @version root
 * @summary Constructor stores 7; Object.Value reads 7 through get_Value.
 * @topic Baseline
 */
class AHolder
{
	int Stored;

	AHolder()
	{
		Stored = 7;
	}

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
 * @version valid-getter-only-on-handle
 * @parent root
 * @summary A getter-only property can be read through a handle.
 * @topic Properties
 */
class AHolder
{
	int Stored;

	int get_Value() property
	{
		return Stored;
	}
}

int ReadHandle(AHolder@ Object)
{
	return Object.Value;
}
/** @end */
/**
 * @version valid-getter-only-from-field
 * @parent root
 * @summary Writing the backing field is visible through the getter-only property.
 * @topic Properties
 */
class AHolder
{
	int Stored;

	int get_Value() property
	{
		return Stored;
	}
}

int ReadAfterFieldWrite()
{
	AHolder Object;
	Object.Stored = 11;
	return Object.Value;
}
/** @end */
