/**
 * @version v1
 * @summary Broadcasting a multicast event with the wrong argument count is rejected. FOnChangedBadArgCnt takes one int, so Broadcast() with no arguments fails.
 * @topic Feature
 */
/**
 * @version root
 * @summary Broadcasting a multicast event with the wrong argument count is rejected. FOnChangedBadArgCnt takes one int, so Broadcast() with no arguments fails.
 * @topic Negative
 */
/**
 * A multicast event that takes one int.
 *
 * @Kind CompileReject
 * @Covers Delegates.Binding
 * @Inputs int Val
 * @Return nothing when broadcast
 */
event void FOnChangedBadArgCnt(int Val);

class ADelBadArgCntActor : AActor
{
	UPROPERTY()
	FOnChangedBadArgCnt OnChanged;

	/**
	 * The isolated failing program: Broadcast with no arguments.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.Binding
	 * @Inputs none
	 * @Return does not compile; the event requires one int
	 */
	void Fire()
	{
		OnChanged.Broadcast();
	}
}
/** @end */
