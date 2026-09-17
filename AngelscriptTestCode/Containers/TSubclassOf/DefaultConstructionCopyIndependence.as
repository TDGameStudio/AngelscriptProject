/**
 * @version v1
 * @summary Setting one default TSubclassOf leaves a second holder null.
 * @topic Containers
 *
 * DefaultConstructionCopyIndependence
 */
/**
 * @begin DefaultConstructionCopyIndependence
 * @summary Setting one default TSubclassOf leaves a second holder null.
 * @topic Containers
 */
UCLASS()
class UDefaultCopyIndependenceObject : UObject
{
}

bool DefaultConstructionCopyIndependence()
{
	TSubclassOf<UObject> First;
	TSubclassOf<UObject> Second;
	First = UDefaultCopyIndependenceObject::StaticClass();
	return First.IsValid() && !Second.IsValid();
}
/** @end */
