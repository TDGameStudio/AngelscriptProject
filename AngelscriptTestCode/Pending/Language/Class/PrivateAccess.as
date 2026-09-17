/**
 * @version v1
 * @summary A class may read and write its own private field through its methods.
 * @topic Language
 * @topic Class
 */
/**
 * @version root
 * @summary Set stores 5 in a private field; Get reads that 5 back.
 * @topic Baseline
 */
class AHolder
{
	private int Secret;

	void Set(int InValue)
	{
		Secret = InValue;
	}

	int Get() const
	{
		return Secret;
	}
}

int UsePrivate()
{
	AHolder Object;
	Object.Set(5);
	return Object.Get();
}
/** @end */
/**
 * @version valid-private-method-from-inside
 * @parent root
 * @summary A public method may call a private method on the same instance.
 * @topic Class
 */
class AHolder
{
	private int Secret;

	private void Store(int InValue)
	{
		Secret = InValue;
	}

	int WriteThenRead(int InValue)
	{
		Store(InValue);
		return Secret;
	}
}

int UsePrivateMethod()
{
	AHolder Object;
	return Object.WriteThenRead(8);
}
/** @end */
/**
 * @version invalid-private-field-from-outside
 * @parent root
 * @summary A private field cannot be read from a free function.
 * @topic Negative
 */
class AHolder
{
	private int Secret;
}

int Test()
{
	AHolder Object;
	return Object.Secret;
}
/** @end */
