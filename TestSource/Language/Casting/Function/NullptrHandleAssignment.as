/**
 * nullptr initializes and overwrites an object handle. Both forms produce a
 * handle that compares equal to nullptr, so assigning over a live handle
 * clears it rather than leaving a stale reference.
 *
 * @Theme Language.Casting
 * @Subject Casting.NullptrHandleAssignment
 * @Harness Function
 * @Tag Language.Casting.NullptrHandleAssignment
 * @Namespace CastingTest
 * @Provenance C++: AngelscriptSyntaxCastingTests.cpp::Nullptr_Mixed
 */

namespace CastingTest
{
	/**
	 * Observe that nullptr initializes an actor handle to null.
	 *
	 * @Kind Observe
	 * @Covers Casting.Nullptr
	 * @Inputs Declare AActor A = nullptr
	 * @Return the null handle
	 */
	UFUNCTION()
	AActor NullInitializesHandle()
	{
		AActor A = nullptr;
		return A;
	}

	/**
	 * Observe the overwrite boundary: assigning nullptr over a live handle
	 * clears it.
	 *
	 * @Kind Observe
	 * @Covers Casting.Nullptr
	 * @Param A Source actor handle, runner-owned when non-null
	 * @Inputs Assign nullptr over the incoming handle
	 * @Return nullptr after the overwrite
	 * @Boundary overwriting a live handle
	 */
	UFUNCTION()
	AActor NullOverwritesHandle(AActor A)
	{
		A = nullptr;
		return A;
	}
}
