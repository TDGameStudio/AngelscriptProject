/**
 * @version v1
 * @summary The this keyword names the current class instance.
 * @topic Language
 * @topic Class
 */
/**
 * @version root
 * @summary A method writes a field through this and reads it back.
 * @topic Baseline
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
 * @version valid-this-compound-write
 * @parent root
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
 * @version invalid-this-outside-class
 * @parent root
 * @summary This has no referent at global scope.
 * @topic Negative
 */
void Test()
{
	auto X = this;
}
/** @end */
