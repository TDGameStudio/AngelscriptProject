/**
 * @version v1
 * @summary OverrideComponent type that does not inherit the base component is rejected. The replacement must be a subclass of the overridden component type.
 * @topic Definitions
 */
/**
 * @version root
 * @summary OverrideComponent type that does not inherit the base component is rejected. The replacement must be a subclass of the overridden component type.
 * @topic Negative
 */
UCLASS()
class ACoverageUClassOverrideWrongTypeBaseActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UStaticMeshComponent Mesh;
}

UCLASS()
class ACoverageUClassOverrideWrongTypeChildActor : ACoverageUClassOverrideWrongTypeBaseActor
{
	UPROPERTY(OverrideComponent=Mesh)
	USceneComponent Replacement;
}
/** @end */
