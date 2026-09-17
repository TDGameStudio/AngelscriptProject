/**
 * @version v1
 * @summary Mixin class and unknown-host forms that do not compile.
 * @topic Language
 * @topic Mixin
 *
 * invalid-mixin-class                    // A mixin class declaration is rejected.
 * invalid-mixin-class-with-method        // A mixin class that also declares a method is still rejected.
 * invalid-mixin-on-struct                // A mixin class cannot be applied to a struct.
 * invalid-mixin-keyword-inside-struct    // The mixin application statement is illegal inside a struct body.
 * invalid-unknown-host                   // Self typed as AMissingHost is rejected because that type is never declared.
 * invalid-unknown-host-with-call         // Calling a mixin on a declared host still fails when Self names another missing type.
 */
/**
 * @begin invalid-mixin-class
 * @summary A mixin class declaration is rejected.
 * @topic Negative
 */
mixin class UCoverageMixin
{
	int SharedValue = 1;
}
/** @end */
/**
 * @begin invalid-mixin-class-with-method
 * @summary A mixin class that also declares a method is still rejected.
 * @topic Negative
 */
mixin class UHealthMixin
{
	int Health = 100;

	void TakeDamage(int Amount)
	{
		Health -= Amount;
	}
}
/** @end */
/**
 * @begin invalid-mixin-on-struct
 * @summary A mixin class cannot be applied to a struct.
 * @topic Negative
 */
mixin class UHealthMixinOnStruct
{
	int Health = 100;
}

struct FMixStruct
{
	mixin UHealthMixinOnStruct;
}
/** @end */
/**
 * @begin invalid-mixin-keyword-inside-struct
 * @summary The mixin application statement is illegal inside a struct body.
 * @topic Negative
 */
struct FBareMixStruct
{
	mixin UMissingMixin;
}
/** @end */
/**
 * @begin invalid-unknown-host
 * @summary Self typed as AMissingHost is rejected because that type is never declared.
 * @topic Negative
 */
mixin void AddScore(AMissingHost Self, int Delta)
{
	Self.Score += Delta;
}
/** @end */
/**
 * @begin invalid-unknown-host-with-call
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
