/**
 * @version v1
 * @summary A mixin needs a receiving type; a free call or missing Self is rejected.
 * @topic Language
 * @topic Mixin
 */
/**
 * @version root
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
/**
 * @version invalid-mixin-no-self-param
 * @parent root
 * @summary A function mixin with no Self parameter has no type to attach to.
 * @topic Negative
 */
mixin void NoReceiver(int Delta)
{
}
/** @end */
/**
 * @version invalid-global-mixin-application
 * @parent root
 * @summary A mixin application at global scope has no receiving type.
 * @topic Negative
 */
mixin class UHealthMixinGlobal
{
	int Health = 100;
}

mixin UHealthMixinGlobal;
/** @end */
