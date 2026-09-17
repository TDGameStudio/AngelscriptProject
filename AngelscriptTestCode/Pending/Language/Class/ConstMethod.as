/**
 * @version v1
 * @summary A const method may read instance fields and return them.
 * @topic Language
 * @topic Class
 */
/**
 * @version root
 * @summary Read() const returns the field written before the call.
 * @topic Baseline
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
 * @version valid-const-method-on-const-handle
 * @parent root
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
 * @version valid-const-method-adds-locals
 * @parent root
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
