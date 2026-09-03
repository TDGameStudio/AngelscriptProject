/**
 * MoveAssignFrom throws when the source is the destination. opAssign to self
 * is not this case and does not throw.
 *
 * @Theme Containers.TArray
 * @Subject TArray.MoveAssignFrom
 * @Harness RuntimeException
 * @Tag Containers.TArray.TArrayMoveAssignSelf
 * @Namespace TArrayTest
 */

namespace TArrayTest
{
	/**
	 * MoveAssignFrom the same array throws.
	 *
	 * @Kind RuntimeException
	 * @Covers TArray.MoveAssignFrom
	 * @Inputs [1]; MoveAssignFrom(self)
	 * @Return void; throws "Cannot move assign an array into itself."
	 * @Boundary source is destination
	 */
	UFUNCTION()
	void MoveAssignFromSelf()
	{
		TArray<int> Values;
		Values.Add(1);
		Values.MoveAssignFrom(Values);
	}
}
