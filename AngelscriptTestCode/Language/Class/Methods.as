/**
 * @version v1
 * @summary Class methods, const methods, and ordinary get_Value accessors.
 * @topic Language
 * @topic Class
 *
 * method-call                     // Double calls Add on this and returns 8 for input 4.
 * method-calls-field-writer       // One method stores a field; another method reads that store.
 * const-method                    // Read() const returns the field written before the call.
 * const-method-on-const-handle    // A const method can be called on a const handle.
 * const-method-adds-locals        // A const method may compute from a field and a local.
 * method-with-argument            // A method accepts one argument and returns it plus a field.
 * method-returns-field            // A method returns the stored field.
 * get-value-accessor              // Ordinary get_Value() reads the stored field without a property decorator.
 */
/**
 * @begin method-call
 * @summary Double calls Add on this and returns 8 for input 4.
 * @topic Class
 */
class AAdder
{
	int Add(int Left, int Right)
	{
		return Left + Right;
	}

	int Double(int Amount)
	{
		return Add(Amount, Amount);
	}
}

int UseCall()
{
	AAdder Object;
	return Object.Double(4);
}
/** @end */
/**
 * @begin method-calls-field-writer
 * @summary One method stores a field; another method reads that store.
 * @topic Class
 */
class AHolder
{
	int Value;

	void Store(int InValue)
	{
		Value = InValue;
	}

	int Load()
	{
		return Value;
	}

	int WriteThenRead(int InValue)
	{
		Store(InValue);
		return Load();
	}
}

int UseWriteThenRead()
{
	AHolder Object;
	return Object.WriteThenRead(6);
}
/** @end */
/**
 * @begin const-method
 * @summary Read() const returns the field written before the call.
 * @topic Class
 */
class AHolder
{
	int Value;

	int Read() const
	{
		return Value;
	}
}

int UseConst()
{
	AHolder Object;
	Object.Value = 4;
	return Object.Read();
}
/** @end */
/**
 * @begin const-method-on-const-handle
 * @summary A const method can be called on a const handle.
 * @topic Class
 */
class AHolder
{
	int Value;

	int Read() const
	{
		return Value;
	}
}

int UseConstHandle(const AHolder@ Object)
{
	return Object.Read();
}
/** @end */
/**
 * @begin const-method-adds-locals
 * @summary A const method may compute from a field and a local.
 * @topic Class
 */
class AHolder
{
	int Value;

	int Plus(int Extra) const
	{
		int Total = Value + Extra;
		return Total;
	}
}

int UsePlus()
{
	AHolder Object;
	Object.Value = 5;
	return Object.Plus(2);
}
/** @end */
/**
 * @begin method-with-argument
 * @summary A method accepts one argument and returns it plus a field.
 * @topic Class
 */
class AHolder
{
	int Value;

	int Add(int Extra)
	{
		return Value + Extra;
	}
}

int UseArgument()
{
	AHolder Object;
	Object.Value = 3;
	return Object.Add(4);
}
/** @end */
/**
 * @begin method-returns-field
 * @summary A method returns the stored field.
 * @topic Class
 */
class AHolder
{
	int Value;

	int Load()
	{
		return Value;
	}
}

int UseReturn()
{
	AHolder Object;
	Object.Value = 9;
	return Object.Load();
}
/** @end */
/**
 * @begin get-value-accessor
 * @summary Ordinary get_Value() reads the stored field without a property decorator.
 * @topic Class
 */
class AHolder
{
	int Stored;

	int get_Value()
	{
		return Stored;
	}

	void Set(int InValue)
	{
		Stored = InValue;
	}
}

int UseAccessor()
{
	AHolder Object;
	Object.Set(7);
	return Object.get_Value();
}
/** @end */
