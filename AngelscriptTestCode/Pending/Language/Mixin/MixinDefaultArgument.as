/**
 * @version v1
 * @summary A function mixin can declare a default argument after Self.
 * @topic Language
 * @topic Mixin
 */
/**
 * @version root
 * @summary Calling AddScore with no extra argument uses the default Delta of 5.
 * @topic Baseline
 */
mixin void AddScore(AHost Self, int Delta = 5)
{
	Self.Score += Delta;
}

class AHost
{
	int Score;
}

int UseDefault()
{
	AHost Object;
	Object.AddScore();
	return Object.Score;
}
/** @end */
/**
 * @version valid-explicit-delta
 * @parent root
 * @summary An explicit argument overrides the mixin default.
 * @topic Mixin
 */
mixin void AddScore(AHost Self, int Delta = 5)
{
	Self.Score += Delta;
}

class AHost
{
	int Score;
}

int UseExplicit()
{
	AHost Object;
	Object.AddScore(7);
	return Object.Score;
}
/** @end */
/**
 * @version invalid-too-many-arguments
 * @parent root
 * @summary A mixin call cannot pass more arguments than the signature allows.
 * @topic Negative
 */
mixin void AddScore(AHost Self, int Delta = 5)
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
	Object.AddScore(1, 2);
}
/** @end */
