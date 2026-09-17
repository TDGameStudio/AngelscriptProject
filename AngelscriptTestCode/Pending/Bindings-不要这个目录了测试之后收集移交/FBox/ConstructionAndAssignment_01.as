/**
 * @version v1
 * @summary Observe FBox union and point-expansion operators plus formatter interpolation. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FBox union and point-expansion operators plus formatter interpolation. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// FBox Expanded = Box + Point; Box += Point; FString Text = f"{Box}";
// Inputs: Left (0,0,0)-(1,1,1), Right (1,1,1)-(2,2,2), Point (3,3,3), and a
// copied original for independence.
// Expected observations: Union max becomes (2,2,2). += mutates Left. Point
// expansion includes 3. f"{Box}" is non-empty. Original copy stays (1,1,1).
// Boundary/ownership: + returns a new box. += mutates the left operand.

namespace TS_FBox_ConstructionAndAssignment_01
{
	bool Observe_Assignment_Nominal()
	{
		FBox Left(FVector(0, 0, 0), FVector(1, 1, 1));
		FBox Right(FVector(1, 1, 1), FVector(2, 2, 2));
		FBox Original = Left;
		FBox Union = Left + Right;
		FString Text = f"{Union}";
		return Union.Max.X == 2.0 && Original.Max.X == 1.0 && Text.Len() > 0;
	}

	bool Observe_AddAssign_Nominal()
	{
		FBox Left(FVector(0, 0, 0), FVector(1, 1, 1));
		FBox Right(FVector(1, 1, 1), FVector(2, 2, 2));
		Left += Right;
		FBox Box(FVector(0, 0, 0), FVector(1, 1, 1));
		FVector Point(3, 3, 3);
		FBox Expanded = Box + Point;
		Box += Point;
		return Left.Max.X == 2.0 && Right.Max.X == 2.0 && Expanded.Max.X == 3.0 && Box.Max.X == 3.0;
	}
}
/** @end */
