/**
 * @version v1
 * @summary A mixin class inheriting another mixin is rejected. C++ compiles it as the module ASSyntaxMixInheritMixin and expects the diagnostic to name the mixin inheritance.
 * @topic Feature
 */
/**
 * @version root
 * @summary A mixin class inheriting another mixin is rejected. C++ compiles it as the module ASSyntaxMixInheritMixin and expects the diagnostic to name the mixin inheritance.
 * @topic Negative
 */
/**
 * A base mixin class used only so a child mixin can try to inherit it.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixInheritMixin
 * @Inputs mixin class UBaseMixin
 * @Return does not compile once inherited by another mixin
 */
mixin class UBaseMixin
{
	int X = 0;
}

/**
 * The isolated failing program: mixin classes cannot inherit mixins.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixInheritMixin
 * @Inputs mixin class UChildMixin deriving from UBaseMixin
 * @Return does not compile
 */
mixin class UChildMixin : UBaseMixin
{
	int Y = 0;
}
/** @end */
