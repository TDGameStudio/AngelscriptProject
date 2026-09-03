/**
 * A NotAngelscriptSpawnable component is rejected as a DefaultComponent. The
 * generated actor is not published; this file is the illegal program itself.
 *
 * @Theme Feature.DefaultComponent
 * @Subject DefaultComponent.NotAngelscriptSpawnableComponentRejectedAsDefaultComponent
 * @Harness CompileReject
 * @Tag Feature.DefaultComponent.NotAngelscriptSpawnableComponentRejectedAsDefaultComponent
 * @Kind CompileReject
 * @Covers DefaultComponent.NotAngelscriptSpawnableComponentRejectedAsDefaultComponent
 * @Inputs UPROPERTY(DefaultComponent, RootComponent) UAngelscriptVerifyClassNotSpawnableSceneComponent BlockedRoot
 * @Return does not compile; NotAngelscriptSpawnable component should be rejected as a DefaultComponent
 * @Provenance Theme: Feature.DefaultComponent. Isolated compile-fail.
 * @Provenance C++: AngelscriptComponentMetadataValidationTests.cpp::NotAngelscriptSpawnableComponentRejectedAsDefaultComponent
 * @Provenance Expected diagnostic: NotAngelscriptSpawnable component should be rejected as a DefaultComponent.
 * @Provenance Compile result Error; generated actor is not published.
 * @Provenance DiagnosticOnly. Isolation=none. Do not replace BlockedRoot with a spawnable type.
 */

UCLASS()
class AComponentVerifyClassNotSpawnableActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UAngelscriptVerifyClassNotSpawnableSceneComponent BlockedRoot;
}
