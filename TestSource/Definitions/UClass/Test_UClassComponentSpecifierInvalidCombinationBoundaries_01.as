// Theme: Definitions.UClass. Isolated compile-fail: Attach without DefaultComponent.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: Attachments can only be specified on DefaultComponents.
// DiagnosticOnly. Do not add DefaultComponent; that would make the program compile.

UCLASS()
class ACoverageUClassAttachWithoutDefaultActor : AActor
{
	UPROPERTY(Attach=Root)
	USceneComponent Child;
}
