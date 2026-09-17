/**
 * @version v1
 * @summary Broadcasting a multicast event with the wrong argument type is rejected. FOnChangedBadArgType takes an int, so Broadcast of a string fails.
 * @topic Feature
 */
/**
 * @version root
 * @summary Broadcasting a multicast event with the wrong argument type is rejected. FOnChangedBadArgType takes an int, so Broadcast of a string fails.
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
event void FOnChangedBadArgType(int Val);

class ADelBadArgTypeActor : AActor
{
	UPROPERTY()
	FOnChangedBadArgType OnChanged;

	/**
	 * The isolated failing program: Broadcast of a string against an int.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.Binding
	 * @Inputs none
	 * @Return does not compile; the event requires an int
	 */
	void Fire()
	{
		OnChanged.Broadcast("hello");
	}
}
/** @end */
