/**
 * @version v1
 * @summary FIntVector4 host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FIntVector4
 *
 * vector
 * surface-005
 * surface-006
 * surface-007
 * surface-008
 * assignment
 * multiply-assign
 * divide-assign
 * add-assign
 * subtract-assign
 * FIntVector4-ConstructionAndAssignment_02-assignment
 * index
 * equality
 */
/**
 * @begin vector
 * @summary FIntVector4(X,Y,Z,W), default zero, uniform F, and copy.
 * @topic Unreal
 */
/**
 * @function ObserveVectorNominal
 * @summary FIntVector4(X,Y,Z,W), default zero, uniform F, and copy.
 * @covers FIntVector4.vector
 * @inputs FIntVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveVectorNominal()
{
	FIntVector4 Explicit(1, 2, 3, 4);
	FIntVector4 Zero;
	FIntVector4 Uniform(7);
	FIntVector4 Copied(Explicit);
	return Explicit.W == 4 && Zero.X == 0 && Uniform.Z == 7 && Copied.Y == 2;
}
/** @end */
/**
 * @begin surface-005
 * @summary FIntVector4.
 * @topic Unreal
 */
/**
 * @function ObserveSurface005Nominal
 * @summary FIntVector4.
 * @covers FIntVector4.surface-005
 * @inputs FIntVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
X of (1,2,3,4) is 1. Query, no fixture.
bool ObserveSurface005Nominal()
{
	return FIntVector4(1, 2, 3, 4).X == 1;
}
/** @end */
/**
 * @begin surface-006
 * @summary FIntVector4.
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary FIntVector4.
 * @covers FIntVector4.surface-006
 * @inputs FIntVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
Y of (1,2,3,4) is 2. Query, no fixture.
bool ObserveSurface006Nominal()
{
	return FIntVector4(1, 2, 3, 4).Y == 2;
}
/** @end */
/**
 * @begin surface-007
 * @summary FIntVector4.
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary FIntVector4.
 * @covers FIntVector4.surface-007
 * @inputs FIntVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
Z of (1,2,3,4) is 3. Query, no fixture.
bool ObserveSurface007Nominal()
{
	return FIntVector4(1, 2, 3, 4).Z == 3;
}
/** @end */
/**
 * @begin surface-008
 * @summary FIntVector4.
 * @topic Unreal
 */
/**
 * @function ObserveSurface008Nominal
 * @summary FIntVector4.
 * @covers FIntVector4.surface-008
 * @inputs FIntVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
W of (1,2,3,4) is 4. Query, no fixture.
bool ObserveSurface008Nominal()
{
	return FIntVector4(1, 2, 3, 4).W == 4;
}
/** @end */
/**
 * @begin assignment
 * @summary truncates.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary truncates.
 * @covers FIntVector4.assignment
 * @inputs FIntVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FIntVector4 Left(2, 4, 6, 8);
	FIntVector4 Right(1, 1, 1, 1);
	Left = Right;
	FIntVector4 Sum = Left + Right;
	FIntVector4 Difference = Left - Right;
	FIntVector4 Negated = -Left;
	return Left.W == 1 && Sum.X == 2 && Difference.X == 0 && Negated.X == -1;
}
/** @end */
/**
 * @begin multiply-assign
 * @summary truncates.
 * @topic Unreal
 */
/**
 * @function ObserveMultiplyAssignNominal
 * @summary truncates.
 * @covers FIntVector4.multiply-assign
 * @inputs FIntVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMultiplyAssignNominal()
{
	FIntVector4 Vector(2, 4, 6, 8);
	FIntVector4 Scaled = Vector * 2;
	Vector *= 2;
	return Scaled.W == 16 && Vector.W == 16;
}
/** @end */
/**
 * @begin divide-assign
 * @summary truncates.
 * @topic Unreal
 */
/**
 * @function ObserveDivideAssignNominal
 * @summary truncates.
 * @covers FIntVector4.divide-assign
 * @inputs FIntVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDivideAssignNominal()
{
	FIntVector4 Vector(2, 4, 6, 8);
	FIntVector4 Quotient = Vector / 2;
	Vector /= 2;
	return Quotient.W == 4 && Vector.W == 4;
}
/** @end */
/**
 * @begin add-assign
 * @summary truncates.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary truncates.
 * @covers FIntVector4.add-assign
 * @inputs FIntVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal()
{
	FIntVector4 Vector(2, 4, 6, 8);
	Vector += FIntVector4(1, 1, 1, 1);
	return Vector.W == 9;
}
/** @end */
/**
 * @begin subtract-assign
 * @summary truncates.
 * @topic Unreal
 */
/**
 * @function ObserveSubtractAssignNominal
 * @summary truncates.
 * @covers FIntVector4.subtract-assign
 * @inputs FIntVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSubtractAssignNominal()
{
	FIntVector4 Vector(2, 4, 6, 8);
	Vector -= FIntVector4(1, 1, 1, 1);
	return Vector.W == 7;
}
/** @end */
/**
 * @begin FIntVector4-ConstructionAndAssignment_02-assignment
 * @summary Boundary/ownership: Formatter copies digits into a new FString.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Boundary/ownership: Formatter copies digits into a new FString.
 * @covers FIntVector4.assignment
 * @inputs FIntVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FIntVector4 Vector(1, 2, 3, 4);
	FString Text = f"{Vector}";
	FString ZeroText = f"{FIntVector4()}";
	return Text.Len() > 0 && ZeroText.Len() > 0 && Vector.W == 4;
}
/** @end */
/**
 * @begin index
 * @summary Boundary/ownership: Out-of-range index is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveIndexNominal
 * @summary Boundary/ownership: Out-of-range index is the diagnostic path.
 * @covers FIntVector4.index
 * @inputs FIntVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIndexNominal()
{
	FIntVector4 Vector(2, 4, 6, 8);
	return Vector[0] == 2 && Vector[3] == 8;
}
/** @end */
/**
 * @begin equality
 * @summary Boundary/ownership: Out-of-range index is the diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary Boundary/ownership: Out-of-range index is the diagnostic path.
 * @covers FIntVector4.equality
 * @inputs FIntVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FIntVector4 Left(2, 4, 6, 8);
	FIntVector4 Right(2, 4, 6, 8);
	FIntVector4 Different(2, 4, 6, 9);
	return (Left == Right) && !(Left == Different);
}
/** @end */
