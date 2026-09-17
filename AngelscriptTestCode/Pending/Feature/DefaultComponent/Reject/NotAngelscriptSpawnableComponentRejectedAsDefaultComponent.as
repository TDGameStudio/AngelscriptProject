/**
 * @version v1
 * @summary A NotAngelscriptSpawnable component is rejected as a DefaultComponent. The generated actor is not published; this file is the illegal program itself.
 * @topic Feature
 */
/**
 * @version root
 * @summary A NotAngelscriptSpawnable component is rejected as a DefaultComponent. The generated actor is not published; this file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class AComponentVerifyClassNotSpawnableActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UAngelscriptVerifyClassNotSpawnableSceneComponent BlockedRoot;
}
/** @end */
