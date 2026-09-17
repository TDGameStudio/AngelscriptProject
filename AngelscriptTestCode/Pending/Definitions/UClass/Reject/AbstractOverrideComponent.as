/**
 * @version v1
 * @summary OverrideComponent that uses an Abstract scene class is rejected. Abstract component classes cannot be used as overrides.
 * @topic Definitions
 */
/**
 * @version root
 * @summary OverrideComponent that uses an Abstract scene class is rejected. Abstract component classes cannot be used as overrides.
 * @topic Negative
 */
UCLASS(Abstract)
class UCoverageUClassAbstractOverrideSceneComponent : USceneComponent
{
}

UCLASS()
class ACoverageUClassAbstractOverrideBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;
}

UCLASS()
class ACoverageUClassAbstractOverrideChildActor : ACoverageUClassAbstractOverrideBaseActor
{
	UPROPERTY(OverrideComponent=Root)
	UCoverageUClassAbstractOverrideSceneComponent Replacement;
}
/** @end */
