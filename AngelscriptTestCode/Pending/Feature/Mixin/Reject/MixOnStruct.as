/**
 * @version v1
 * @summary Applying a mixin to a struct is rejected. C++ compiles it as the module ASSyntaxMixOnStruct and expects the diagnostic to name the struct application.
 * @topic Feature
 */
/**
 * @version root
 * @summary Applying a mixin to a struct is rejected. C++ compiles it as the module ASSyntaxMixOnStruct and expects the diagnostic to name the struct application.
 * @topic Negative
 */
/**
 * A mixin class used only so it can be applied to a struct below.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixOnStruct
 * @Inputs mixin class UHealthMixinOnStruct
 * @Return does not compile once applied to a struct
 */
mixin class UHealthMixinOnStruct
{
	int Health = 100;
}

/**
 * The isolated failing program: mixins cannot be applied to structs.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixOnStruct
 * @Inputs struct FMixStruct applying UHealthMixinOnStruct
 * @Return does not compile
 */
struct FMixStruct
{
	mixin UHealthMixinOnStruct;
}
/** @end */
