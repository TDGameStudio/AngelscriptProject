/**
 * @version v1
 * @summary A const method may read and return a field.
 * @topic Language
 * @topic Const
 */
/**
 * @version root
 * @summary Get returns Score from a const method.
 * @topic Baseline
 */
class AHost
{
	int Score;

	int Get() const
	{
		return Score;
	}
}

int ReadScore()
{
	AHost Object;
	Object.Score = 4;
	return Object.Get();
}
/** @end */
/**
 * @version valid-const-method-zero
 * @parent root
 * @summary A const method returns a default-zero field.
 * @topic Const
 */
class AHost
{
	int Score;

	int Get() const
	{
		return Score;
	}
}

int ReadZero()
{
	AHost Object;
	return Object.Get();
}
/** @end */
/**
 * @version valid-const-method-this
 * @parent root
 * @summary A const method may read the field through this.
 * @topic Const
 */
class AHost
{
	int Score;

	int Get() const
	{
		return this.Score;
	}
}

int ReadThroughThis()
{
	AHost Object;
	Object.Score = 4;
	return Object.Get();
}
/** @end */
