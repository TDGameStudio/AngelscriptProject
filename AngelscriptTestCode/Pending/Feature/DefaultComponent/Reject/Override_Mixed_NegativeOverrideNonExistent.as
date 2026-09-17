/**
 * @version v1
 * @summary OverrideComponent of a name that does not exist is rejected. The override target must be a parent default component; this file is the illegal program.
 * @topic Feature
 */
/**
 * @version root
 * @summary OverrideComponent of a name that does not exist is rejected. The override target must be a parent default component; this file is the illegal program.
 * @topic Negative
 */
class ADefCompBaseBadActor : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent Root;
}

class ADefCompChildBadActor : ADefCompBaseBadActor
{
	UPROPERTY(OverrideComponent = NonExistent)
	UStaticMeshComponent Mesh;
}
/** @end */
