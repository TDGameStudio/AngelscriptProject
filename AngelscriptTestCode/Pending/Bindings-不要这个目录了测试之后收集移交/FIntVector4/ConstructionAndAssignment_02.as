/**
 * @version v1
 * @summary Observe FIntVector4 formatter interpolation after assignment.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FIntVector4 formatter interpolation after assignment.
 * @topic Baseline
 */
// identity is preserved in the formatted value's source vector.
// Boundary/ownership: Formatter copies digits into a new FString.

namespace TS_FIntVector4_ConstructionAndAssignment_02
{
	bool Observe_Assignment_Nominal()
	{
		FIntVector4 Vector(1, 2, 3, 4);
		FString Text = f"{Vector}";
		FString ZeroText = f"{FIntVector4()}";
		return Text.Len() > 0 && ZeroText.Len() > 0 && Vector.W == 4;
	}
}
/** @end */
