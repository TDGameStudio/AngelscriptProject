// Theme: Feature.Mixin. Isolated compile-fail: mixin class syntax is unsupported.
// C++: AngelscriptCoverageMixinTests.cpp::MixinClassSyntaxRejected CompileAndExpectFailure.
// Expected diagnostic: "Expected data type".
// DiagnosticOnly. Do not rewrite mixin class into free mixins; that would make the program compile.

mixin class UCoverageMixinUnsupportedA
{
	int SharedValue = 1;
}

mixin class UCoverageMixinUnsupportedB
{
	int SharedValue = 2;
}

UCLASS()
class ACoverageMixinUnsupportedMultipleConflictActor : AActor
{
	mixin UCoverageMixinUnsupportedA;
	mixin UCoverageMixinUnsupportedB;
}
