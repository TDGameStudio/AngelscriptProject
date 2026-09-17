/**
 * @version v1
 * @summary Auto infers a local type from a class constructor call.
 * @topic Language
 * @topic Auto
 */
/**
 * @version root
 * @summary auto Object = AHost() infers AHost and reads Score.
 * @topic Baseline
 */
class AHost
{
	int Score;

	AHost()
	{
		Score = 0;
	}
}

int Constructed()
{
	auto Object = AHost();
	Object.Score = 4;
	return Object.Score;
}
/** @end */
/**
 * @version valid-default-score
 * @parent root
 * @summary A default-constructed auto host keeps Score at 0.
 * @topic Auto
 */
class AHost
{
	int Score;

	AHost()
	{
		Score = 0;
	}
}

int DefaultScore()
{
	auto Object = AHost();
	return Object.Score;
}
/** @end */
/**
 * @version invalid-constructor-wrong-arity
 * @parent root
 * @summary Auto cannot construct AHost with an argument the class does not accept.
 * @topic Negative
 */
class AHost
{
	int Score;

	AHost()
	{
		Score = 0;
	}
}

void Test()
{
	auto Object = AHost(4);
}
/** @end */
