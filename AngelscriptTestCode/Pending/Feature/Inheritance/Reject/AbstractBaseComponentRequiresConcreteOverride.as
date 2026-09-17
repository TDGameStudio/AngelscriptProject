/**
 * @version v1
 * @summary A concrete actor that inherits an abstract DefaultComponent without an OverrideComponent is rejected. The missing override is the isolated failure; adding one would make the program compile.
 * @topic Feature
 */
/**
 * @version root
 * @summary A concrete actor that inherits an abstract DefaultComponent without an OverrideComponent is rejected. The missing override is the isolated failure; adding one would make the program compile.
 * @topic Negative
 */
UCLASS(Abstract)
class AComponentVerifyClassAbstractBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UAngelscriptVerifyClassAbstractSceneComponent AbstractRoot;
}

UCLASS()
class AComponentVerifyClassConcreteMissingOverrideActor : AComponentVerifyClassAbstractBaseActor
{
}
/** @end */
