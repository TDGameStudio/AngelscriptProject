/**
 * @version v1
 * @summary A mixin application at global scope is rejected. C++ compiles it as the module ASSyntaxMixGlobal and expects the diagnostic to name the global mixin statement.
 * @topic Feature
 */
/**
 * @version root
 * @summary A mixin application at global scope is rejected. C++ compiles it as the module ASSyntaxMixGlobal and expects the diagnostic to name the global mixin statement.
 * @topic Negative
 */
/**
 * A mixin class used only so it can be applied at global scope below.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixGlobal
 * @Inputs mixin class UHealthMixinGlobal
 * @Return does not compile once applied at global scope
 */
mixin class UHealthMixinGlobal
{
	int Health = 100;
}

mixin UHealthMixinGlobal;
/** @end */
