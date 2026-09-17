/**
 * @version v1
 * @summary Applying a mixin to a struct is rejected.
 * @topic Language
 * @topic Mixin
 */
/**
 * @version root
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
 * @version invalid-mixin-keyword-inside-struct
 * @parent root
 * @summary The mixin application statement is illegal inside a struct body.
 * @topic Negative
 */
struct FBareMixStruct
{
	mixin UMissingMixin;
}
/** @end */
