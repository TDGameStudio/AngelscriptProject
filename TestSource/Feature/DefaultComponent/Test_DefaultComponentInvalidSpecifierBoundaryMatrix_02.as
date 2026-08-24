// Theme: Feature.DefaultComponent. Isolated compile-fail: AttachSocket without DefaultComponent.
// C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
// CompileFixtureShouldFail. Expected diagnostic: "Attachments can only be specified on DefaultComponents".
// DiagnosticOnly. Do not add DefaultComponent.

UCLASS()
class ACoverageUClassDefaultComponentAttachSocketWithoutDefault : AActor
{
	UPROPERTY(AttachSocket="LooseSocket")
	USceneComponent Child;
}
