/**
 * @version v1
 * @summary Mixin class syntax is unsupported on this fork, so this program is rejected. C++ compiles it as the module ASCoverageMixin_ClassSyntaxUnsupported and expects the diagnostic "Expected data type". Do not rewrite the mixin.
 * @topic Feature
 */
/**
 * @version root
 * @summary Mixin class syntax is unsupported on this fork, so this program is rejected. C++ compiles it as the module ASCoverageMixin_ClassSyntaxUnsupported and expects the diagnostic "Expected data type". Do not rewrite the mixin.
 * @topic Negative
 */
/**
 * The isolated failing program: mixin class UCoverageMixinUnsupportedA.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixinClassSyntaxRejected
 * @Inputs mixin class UCoverageMixinUnsupportedA
 * @Return does not compile
 */
mixin class UCoverageMixinUnsupportedA
{
	int SharedValue = 1;
}

/**
 * The isolated failing program: mixin class UCoverageMixinUnsupportedB.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixinClassSyntaxRejected
 * @Inputs mixin class UCoverageMixinUnsupportedB
 * @Return does not compile
 */
mixin class UCoverageMixinUnsupportedB
{
	int SharedValue = 2;
}

/**
 * An actor that applies both unsupported mixin classes, which would also conflict.
 *
 * @Kind CompileReject
 * @Covers Mixin.MixinClassSyntaxRejected
 * @Inputs mixin UCoverageMixinUnsupportedA and mixin UCoverageMixinUnsupportedB
 * @Return does not compile
 */
UCLASS()
class ACoverageMixinUnsupportedMultipleConflictActor : AActor
{
	mixin UCoverageMixinUnsupportedA;
	mixin UCoverageMixinUnsupportedB;
}
/** @end */
