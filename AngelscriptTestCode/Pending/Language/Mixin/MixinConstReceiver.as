/**
 * @version v1
 * @summary A function mixin may only read the host and return a field.
 * @topic Language
 * @topic Mixin
 */
/**
 * @version root
 * @summary GetScore reads Self.Score and is called as Object.GetScore.
 * @topic Baseline
 */
mixin int GetScore(AHost Self)
{
	return Self.Score;
}

class AHost
{
	int Score;
}

int ReadScore()
{
	AHost Object;
	Object.Score = 4;
	return Object.GetScore();
}
/** @end */
/**
 * @version valid-zero-score
 * @parent root
 * @summary A read-only mixin returns a zero Score unchanged.
 * @topic Mixin
 */
mixin int GetScore(AHost Self)
{
	return Self.Score;
}

class AHost
{
	int Score;
}

int ReadZero()
{
	AHost Object;
	return Object.GetScore();
}
/** @end */
/**
 * @version invalid-write-through-const-self
 * @parent root
 * @summary A mixin whose Self is const cannot assign a host field.
 * @topic Negative
 */
mixin void BumpScore(const AHost Self)
{
	Self.Score += 1;
}

class AHost
{
	int Score;
}
/** @end */
