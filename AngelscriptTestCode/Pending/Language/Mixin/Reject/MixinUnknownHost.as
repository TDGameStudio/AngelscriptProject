/**
 * @version v1
 * @summary A function mixin cannot target a host type that does not exist.
 * @topic Language
 * @topic Mixin
 */
/**
 * @version root
 * @summary Self typed as AMissingHost is rejected because that type is never declared.
 * @topic Negative
 */
mixin void AddScore(AMissingHost Self, int Delta)
{
	Self.Score += Delta;
}
/** @end */
/**
 * @version invalid-unknown-host-with-call
 * @parent root
 * @summary Calling a mixin on a declared host still fails when Self names another missing type.
 * @topic Negative
 */
mixin void AddScore(AMissingHost Self, int Delta)
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
	Object.AddScore(4);
}
/** @end */
