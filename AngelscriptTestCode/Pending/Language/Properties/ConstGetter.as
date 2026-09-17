/**
 * @version v1
 * @summary A const virtual-property getter on a const receiver.
 * @topic Language
 * @topic Properties
 */
/**
 * @version root
 * @summary A const getter can be read from a const handle.
 * @topic Baseline
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
