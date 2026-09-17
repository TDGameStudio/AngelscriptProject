/**
 * @version v1
 * @summary An unknown ReplicationCondition is a preprocessor error, so this program is rejected. C++ expects the diagnostic "Unknown ReplicationCondition DefinitelyUnknown on property UBadPropertyCarrier::TrackedValue." The illegal.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary An unknown ReplicationCondition is a preprocessor error, so this program is rejected. C++ expects the diagnostic "Unknown ReplicationCondition DefinitelyUnknown on property UBadPropertyCarrier::TrackedValue." The illegal.
 * @topic Negative
 */
UCLASS()
class UBadPropertyCarrier : UObject
{
	UPROPERTY(Replicated, ReplicationCondition=DefinitelyUnknown)
	int TrackedValue;
}
/** @end */
