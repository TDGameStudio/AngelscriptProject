/**
 * @version v1
 * @summary Function mixins dispatched onto a class receiver.
 * @topic Language
 * @topic Mixin
 *
 * function-mixin            // Mixin AddScore writes Score through Self and is called as Object.AddScore.
 * zero-delta                // Adding zero leaves the host Score unchanged.
 * mixin-default-argument    // Calling AddScore with no extra argument uses the default Delta of 5.
 * explicit-delta            // An explicit argument overrides the mixin default.
 * mixin-on-two-hosts        // The same mixin name attaches to two host types through Self.
 */
/**
 * @begin function-mixin
 * @summary Mixin AddScore writes Score through Self and is called as Object.AddScore.
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

int UseMixin()
{
	AHost Object;
	Object.AddScore(4);
	return Object.Score;
}
/** @end */
/**
 * @begin zero-delta
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
 * @begin mixin-default-argument
 * @summary Calling AddScore with no extra argument uses the default Delta of 5.
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

int UseDefault()
{
	AHost Object;
	Object.AddScore();
	return Object.Score;
}
/** @end */
/**
 * @begin explicit-delta
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
 * @begin mixin-on-two-hosts
 * @summary The same mixin name attaches to two host types through Self.
 * @topic Mixin
 */
mixin void AddScore(AHost Self, int Delta)
{
	Self.Score += Delta;
}

mixin void AddScore(AOther Self, int Delta)
{
	Self.Score += Delta;
}

class AHost
{
	int Score;
}

class AOther
{
	int Score;
}

int UseTwoHosts()
{
	AHost First;
	AOther Second;
	First.AddScore(2);
	Second.AddScore(3);
	return First.Score + Second.Score;
}
/** @end */
