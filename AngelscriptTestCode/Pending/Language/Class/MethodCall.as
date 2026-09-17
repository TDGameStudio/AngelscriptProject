/**
 * @version v1
 * @summary A method may call another method on the same instance.
 * @topic Language
 * @topic Class
 */
/**
 * @version root
 * @summary Double calls Add on this and returns 8 for input 4.
 * @topic Baseline
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
 * @version valid-method-calls-field-writer
 * @parent root
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
 * @version invalid-unknown-method
 * @parent root
 * @summary Calling a method that the class does not declare is rejected.
 * @topic Negative
 */
class AHolder
{
	int Value;
}

int Test()
{
	AHolder Object;
	return Object.Missing();
}
/** @end */
