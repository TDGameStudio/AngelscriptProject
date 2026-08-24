// Theme: Feature.DefaultComponent. Isolated compile-fail: Attach parent is not a SceneComponent.
// C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
// CompileFixtureShouldFail. Expected diagnostic: "Attach parent Logic is not a SceneComponent for DefaultComponent Child".
// DiagnosticOnly. Do not change Logic to USceneComponent.

UCLASS()
class UCoverageUClassDefaultComponentAttachParentLogic : UActorComponent
{
}

UCLASS()
class ACoverageUClassDefaultComponentAttachToNonSceneParent : AActor
{
	UPROPERTY(DefaultComponent)
	UCoverageUClassDefaultComponentAttachParentLogic Logic;

	UPROPERTY(DefaultComponent, Attach=Logic)
	USceneComponent Child;
}
