/**
 * @version v1
 * @summary Const-Self mixin forms that do not compile.
 * @topic Language
 * @topic Mixin
 *
 * invalid-write-through-const-self    // A mixin whose Self is const cannot assign a host field.
 */
/**
 * @begin invalid-write-through-const-self
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
