/**
 * @version v1
 * @summary Calling a method marked `unsafe_during_construction` from a default statement is rejected. This file is the illegal program itself; do not move UnsafeValue off the default statement.
 * @topic Feature
 */
/**
 * @version root
 * @summary Calling a method marked `unsafe_during_construction` from a default statement is rejected. This file is the illegal program itself; do not move UnsafeValue off the default statement.
 * @topic Negative
 */
UCLASS()
class UUnsafeDefaultTarget : UObject
{
	UPROPERTY()
	int Value = 0;

	/**
	 * A method that is unsafe to call while the object is being constructed.
	 *
	 * @Kind CompileReject
	 * @Covers Default.UnsafeDuringConstruction
	 * @Inputs none
	 * @Return 7
	 */
	int UnsafeValue() unsafe_during_construction
	{
		return 7;
	}

	default Value = UnsafeValue();
}
/** @end */
