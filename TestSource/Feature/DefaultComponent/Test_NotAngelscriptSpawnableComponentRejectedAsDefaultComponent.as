// Theme: Feature.DefaultComponent. Isolated compile-fail.
// C++: AngelscriptComponentMetadataValidationTests.cpp::NotAngelscriptSpawnableComponentRejectedAsDefaultComponent
// Expected diagnostic: NotAngelscriptSpawnable component should be rejected as a DefaultComponent.
// Compile result Error; generated actor is not published.
// DiagnosticOnly. Isolation=none.

UCLASS()
class AComponentVerifyClassNotSpawnableActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UAngelscriptVerifyClassNotSpawnableSceneComponent BlockedRoot;
}
