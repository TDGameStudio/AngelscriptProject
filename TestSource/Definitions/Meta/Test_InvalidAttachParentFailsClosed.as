// Theme: Definitions.Meta. Isolated compile-fail: DefaultComponent Attach parent must exist.
// C++: InvalidAttachParentFailsClosed; bCompiled false, ECompileResult::Error.
// Expected diagnostic: invalid attach parent MissingParent.
// Isolate this failing program; do not add MissingParent.
// DiagnosticOnly.

UCLASS()
class UComponentInvalidAttachParentRoot : USceneComponent
{
}

UCLASS()
class AComponentInvalidAttachParent : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UComponentInvalidAttachParentRoot RootScene;

	UPROPERTY(DefaultComponent, Attach = MissingParent)
	UBillboardComponent Billboard;
}
