/**
 * @version v1
 * @summary Observe FVector2f in-place compound arithmetic.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector2f in-place compound arithmetic.
 * @topic Baseline
 */
// Vector /= Other; Vector += Other; Vector -= Other.
// Inputs: (2,4), Scale 2, Other (0.5,0.5) then (1,1) and (2,2).
// Expected observations: *= 2 doubles. Component *= 0.5 restores. /= 2
// halves. Component /= (1,2) yields (2,2) from (2,4). += and -= mutate.
// Boundary/ownership: Compound operators mutate Vector. Components are
// float32.

namespace TS_FVector2f_ConstructionAndAssignment_02
{
	bool Observe_MultiplyAssign_Nominal()
	{
		FVector2f Vector(2.0f, 4.0f);
		Vector *= 2.0f;
		bool bScale = Vector.X == 4.0f && Vector.Y == 8.0f;
		Vector *= FVector2f(0.5f, 0.5f);
		return bScale && Vector.X == 2.0f && Vector.Y == 4.0f;
	}

	bool Observe_DivideAssign_Nominal()
	{
		FVector2f Vector(2.0f, 4.0f);
		Vector /= 2.0f;
		bool bScale = Vector.X == 1.0f && Vector.Y == 2.0f;
		FVector2f Other(2.0f, 4.0f);
		Other /= FVector2f(1.0f, 2.0f);
		return bScale && Other.X == 2.0f && Other.Y == 2.0f;
	}

	bool Observe_AddAssign_Nominal()
	{
		FVector2f Vector(2.0f, 4.0f);
		FVector2f Other(1.0f, 1.0f);
		Vector += Other;
		return Vector.X == 3.0f && Vector.Y == 5.0f && Other.X == 1.0f;
	}

	bool Observe_SubtractAssign_Nominal()
	{
		FVector2f Vector(2.0f, 4.0f);
		Vector -= FVector2f(1.0f, 1.0f);
		return Vector.X == 1.0f && Vector.Y == 3.0f;
	}
}
/** @end */
