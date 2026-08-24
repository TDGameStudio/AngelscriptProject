// Theme: Feature.DefaultComponent. Isolated compile-fail: Attach without DefaultComponent.
// C++: AngelscriptCoverageUClassDefaultComponentTests.cpp::DefaultComponentInvalidSpecifierBoundaryMatrix
// CompileFixtureShouldFail. Expected diagnostic: "Attachments can only be specified on DefaultComponents".
// DiagnosticOnly. Do not add DefaultComponent; that would make the program compile.

UCLASS()
class ACoverageUClassDefaultComponentAttachWithoutDefault : AActor
{
	UPROPERTY(Attach=Root)
	USceneComponent Child;
}
