/**
 * @version v1
 * @summary Function mixins whose Self parameter is const.
 * @topic Language
 * @topic Mixin
 *
 * mixin-const-receiver    // GetScore reads const Self.Score and is called as Object.GetScore.
 * zero-score              // A const-Self mixin returns a zero Score unchanged.
 */
/**
 * @begin mixin-const-receiver
 * @summary GetScore reads const Self.Score and is called as Object.GetScore.
 * @topic Mixin
 */
mixin int GetScore(const AHost Self)
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
 * @begin zero-score
 * @summary A const-Self mixin returns a zero Score unchanged.
 * @topic Mixin
 */
mixin int GetScore(const AHost Self)
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
