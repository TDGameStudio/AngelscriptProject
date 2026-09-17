/**
 * @version v1
 * @summary FIntVector2 host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FIntVector2
 *
 * vector
 * surface-005
 * surface-006
 * assignment
 * index
 * equality
 */
/**
 * @begin vector
 * @summary FIntVector2(X,Y), default zero, uniform F, and copy.
 * @topic Unreal
 */
/**
 * @function ObserveVectorNominal
 * @summary FIntVector2(X,Y), default zero, uniform F, and copy.
 * @covers FIntVector2.vector
 * @inputs FIntVector2 values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveVectorNominal()
{
	FIntVector2 Explicit(3, 4);
	FIntVector2 Zero;
	FIntVector2 Uniform(7);
	FIntVector2 Copied(Explicit);
	return Explicit.X == 3 && Zero.X == 0 && Uniform.Y == 7 && Copied.Y == 4;
}
/** @end */
/**
 * @begin surface-005
 * @summary FIntVector2.
 * @topic Unreal
 */
/**
 * @function ObserveSurface005Nominal
 * @summary FIntVector2.
 * @covers FIntVector2.surface-005
 * @inputs FIntVector2 values exercised by this observe
 * @return true when the observe comparison holds
 */
X of (3,4) is 3. Query, no fixture.
bool ObserveSurface005Nominal()
{
	return FIntVector2(3, 4).X == 3;
}
/** @end */
/**
 * @begin surface-006
 * @summary FIntVector2.
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary FIntVector2.
 * @covers FIntVector2.surface-006
 * @inputs FIntVector2 values exercised by this observe
 * @return true when the observe comparison holds
 */
Y of (3,4) is 4. Query, no fixture.
bool ObserveSurface006Nominal()
{
	return FIntVector2(3, 4).Y == 4;
}
/** @end */
/**
 * @begin assignment
 * @summary Boundary/ownership: Assignment copies the two integer components.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Boundary/ownership: Assignment copies the two integer components.
 * @covers FIntVector2.assignment
 * @inputs FIntVector2 values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FIntVector2 Left(2, 4);
	FIntVector2 Right(5, 6);
	Left = Right;
	Right.X = 0;
	FString Text = f"{Left}";
	return Left.X == 5 && Left.Y == 6 && Text.Len() > 0;
}
/** @end */
/**
 * @begin index
 * @summary diagnostic.
 * @topic Unreal
 */
/**
 * @function ObserveIndexNominal
 * @summary diagnostic.
 * @covers FIntVector2.index
 * @inputs FIntVector2 values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIndexNominal()
{
	FIntVector2 Vector(2, 4);
	return Vector[0] == 2 && Vector[1] == 4;
}
/** @end */
/**
 * @begin equality
 * @summary diagnostic.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary diagnostic.
 * @covers FIntVector2.equality
 * @inputs FIntVector2 values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FIntVector2 Left(2, 4);
	FIntVector2 Right(2, 4);
	FIntVector2 Different(2, 5);
	return (Left == Right) && !(Left == Different);
}
/** @end */
