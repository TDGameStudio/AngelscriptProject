/**
 * @version v1
 * @summary Function mixin call and declaration forms that do not compile.
 * @topic Language
 * @topic Mixin
 *
 * invalid-missing-argument            // A mixin call must supply every non-default argument.
 * invalid-too-many-arguments          // A mixin call cannot pass more arguments than the signature allows.
 * invalid-mixin-no-self-param         // A function mixin with no Self parameter has no type to attach to.
 * invalid-global-mixin-application    // A mixin application at global scope has no receiving type.
 * invalid-mixin-without-receiver      // A mixin cannot be invoked as a free function; the host is the receiver.
 */
/**
 * @begin invalid-missing-argument
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
/**
 * @begin invalid-too-many-arguments
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
/**
 * @begin invalid-mixin-no-self-param
 * @summary A function mixin with no Self parameter has no type to attach to.
 * @topic Negative
 */
mixin void NoReceiver(int Delta)
{
}
/** @end */
/**
 * @begin invalid-global-mixin-application
 * @summary A mixin application at global scope has no receiving type.
 * @topic Negative
 */
mixin class UHealthMixinGlobal
{
	int Health = 100;
}

mixin UHealthMixinGlobal;
/** @end */
/**
 * @begin invalid-mixin-without-receiver
 * @summary A mixin cannot be invoked as a free function; the host is the receiver.
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
	AddScore(Object, 4);
}
/** @end */
