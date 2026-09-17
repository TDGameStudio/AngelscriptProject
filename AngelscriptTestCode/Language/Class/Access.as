/**
 * @version v1
 * @summary Private, public, and protected member prefixes.
 * @topic Language
 * @topic Class
 *
 * private-access                    // Set stores 5 in a private field; Get reads that 5 back.
 * private-method-from-inside        // A public method may call a private method on the same instance.
 * public-field-from-outside         // A public field can be written and read from a free function.
 * protected-field-from-subclass     // A subclass method may read and write a protected base field.
 * protected-method-from-subclass    // A subclass method may call a protected base method.
 */
/**
 * @begin private-access
 * @summary Set stores 5 in a private field; Get reads that 5 back.
 * @topic Class
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
 * @begin private-method-from-inside
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
 * @begin public-field-from-outside
 * @summary A public field can be written and read from a free function.
 * @topic Class
 */
class AHolder
{
	int Value;
}

int UsePublic()
{
	AHolder Object;
	Object.Value = 5;
	return Object.Value;
}
/** @end */
/**
 * @begin protected-field-from-subclass
 * @summary A subclass method may read and write a protected base field.
 * @topic Class
 */
class ABase
{
	protected int Secret;
}

class AChild : ABase
{
	void Write(int InValue)
	{
		Secret = InValue;
	}

	int Read() const
	{
		return Secret;
	}
}

int UseProtectedField()
{
	AChild Object;
	Object.Write(5);
	return Object.Read();
}
/** @end */
/**
 * @begin protected-method-from-subclass
 * @summary A subclass method may call a protected base method.
 * @topic Class
 */
class ABase
{
	protected int Secret;

	protected void Store(int InValue)
	{
		Secret = InValue;
	}
}

class AChild : ABase
{
	int WriteThenRead(int InValue)
	{
		Store(InValue);
		return Secret;
	}
}

int UseProtectedMethod()
{
	AChild Object;
	return Object.WriteThenRead(8);
}
/** @end */
