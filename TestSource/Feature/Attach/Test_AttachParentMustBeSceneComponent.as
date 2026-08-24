// Theme: Feature.Attach. NegativeDiagnostic: DefaultComponent Attach parent must be a scene component.
// C++: AngelscriptComponentMetadataValidationTests.cpp::AttachParentMustBeSceneComponent.
// Expected compile failure: "DefaultComponent attach parent should reject non-scene components"
// (ECompileResult::Error; generated actor is not published).
// Isolate the failing program. DiagnosticOnly.

UCLASS()
class AComponentVerifyClassNonSceneParentActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UPROPERTY(DefaultComponent)
	UAngelscriptVerifyClassPlainActorComponent PlainParent;

	UPROPERTY(DefaultComponent, Attach = PlainParent)
	UBillboardComponent Billboard;
}
