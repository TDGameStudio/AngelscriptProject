/**
 * @version v1
 * @summary A function mixin dispatches onto a plain class receiver.
 * @topic Language
 * @topic Mixin
 */
/**
 * @version root
 * @summary Mixin AddScore writes Score through Self and is called as Object.AddScore.
 * @topic Baseline
 */
mixin void AddScore(AHost Self, int Delta)
{
	Self.Score += Delta;
}

class AHost
{
	int Score;
}

int UseMixin()
{
	AHost Object;
	Object.AddScore(4);
	return Object.Score;
}
/** @end */
/**
 * @version valid-zero-delta
 * @parent root
 * @summary Adding zero leaves the host Score unchanged.
 * @topic Mixin
 */
mixin void AddScore(AHost Self, int Delta)
{
	Self.Score += Delta;
}

class AHost
{
	int Score;
}

int UseZeroDelta()
{
	AHost Object;
	Object.Score = 3;
	Object.AddScore(0);
	return Object.Score;
}
/** @end */
/**
 * @version invalid-missing-argument
 * @parent root
 * @summary A mixin call must supply every non-default argument.
 * @topic Negative
 */
mixin void AddScore(AHost Self, int Delta)
{
	Self.Score += Delta;
}

class AHost
{
	int Score;
}

void Test()
{
	AHost Object;
	Object.AddScore();
}
/** @end */
