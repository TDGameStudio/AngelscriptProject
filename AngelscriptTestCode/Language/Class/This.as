/**
 * @version v1
 * @summary This writes, compound writes, and this as an argument.
 * @topic Language
 * @topic Class
 *
 * this-keyword           // A method writes a field through this and reads it back.
 * this-compound-write    // This can be the target of a compound assignment.
 * this-as-argument       // A method may pass this to another method.
 */
/**
 * @begin this-keyword
 * @summary A method writes a field through this and reads it back.
 * @topic Class
 */
class AHolder
{
	int Value;

	void Set(int InValue)
	{
		this.Value = InValue;
	}

	int Get() const
	{
		return this.Value;
	}
}

int UseThis()
{
	AHolder Object;
	Object.Set(4);
	return Object.Get();
}
/** @end */
/**
 * @begin this-compound-write
 * @summary This can be the target of a compound assignment.
 * @topic Class
 */
class ACounter
{
	int Count;

	void Add(int Delta)
	{
		this.Count += Delta;
	}
}

int Tick()
{
	ACounter Object;
	Object.Add(5);
	return Object.Count;
}
/** @end */
/**
 * @begin this-as-argument
 * @summary A method may pass this to another method.
 * @topic Class
 */
class AHolder
{
	int Value;

	int ReadFrom(AHolder Other)
	{
		return Other.Value;
	}

	int UseThisArgument()
	{
		return ReadFrom(this);
	}
}

int UseThisArg()
{
	AHolder Object;
	Object.Value = 6;
	return Object.UseThisArgument();
}
/** @end */
