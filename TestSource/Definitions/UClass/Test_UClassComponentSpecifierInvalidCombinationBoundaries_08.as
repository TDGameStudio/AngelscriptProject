// Theme: Definitions.UClass. Isolated compile-fail: OverrideComponent also marked Attach.
// C++: AngelscriptCoverageUClassTests.cpp::UClassComponentSpecifierInvalidCombinationBoundaries CompileUClassFixtureShouldFail.
// Expected diagnostic: Attachments can only be specified on DefaultComponents.
// DiagnosticOnly. Do not drop Attach from the override; that would make the program compile.

UCLASS()
class ACoverageUClassOverrideWithAttachBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;

	UPROPERTY(DefaultComponent, Attach=Root)
	USceneComponent Child;
}

UCLASS()
class ACoverageUClassOverrideWithAttachChildActor : ACoverageUClassOverrideWithAttachBaseActor
{
	UPROPERTY(OverrideComponent=Child, Attach=Root)
	USceneComponent Replacement;
}
