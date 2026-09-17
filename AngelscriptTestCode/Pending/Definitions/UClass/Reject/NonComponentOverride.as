/**
 * @version v1
 * @summary OverrideComponent on a plain UObject is rejected. The replacement type must be a component.
 * @topic Definitions
 */
/**
 * @version root
 * @summary OverrideComponent on a plain UObject is rejected. The replacement type must be a component.
 * @topic Negative
 */
UCLASS()
class UCoverageUClassPlainOverrideObject : UObject
{
}

UCLASS()
class ACoverageUClassNonComponentOverrideBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;
}

UCLASS()
class ACoverageUClassNonComponentOverrideChildActor : ACoverageUClassNonComponentOverrideBaseActor
{
	UPROPERTY(OverrideComponent=Root)
	UCoverageUClassPlainOverrideObject Replacement;
}
/** @end */
