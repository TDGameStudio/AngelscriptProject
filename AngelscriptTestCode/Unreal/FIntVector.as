/**
 * @version v1
 * @summary FIntVector host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FIntVector
 *
 * vector
 * surface-006
 * surface-007
 * surface-008
 * unary-fintvector-3-4
 * size
 * surface-001
 * assignment
 * multiply-assign
 * divide-assign
 * add-assign
 * subtract-assign
 * to-string
 * append
 * addition
 * subtraction
 * surface-013
 * surface-014
 * index
 * equality
 * get-max
 * get-min
 * is-zero
 */
/**
 * @begin vector
 * @summary axes.
 * @topic Unreal
 */
/**
 * @function ObserveVectorNominal
 * @summary axes.
 * @covers FIntVector.vector
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// axes. Negation flips signs.

 Size of (3,4,12) is 13.
// Boundary/ownership: Size is integer length. Constructors copy values.
// FIntVector(X,Y,Z), default zero, uniform F, and copy. Inputs (3,4,12) and 7.
bool ObserveVectorNominal()
{
	FIntVector Explicit(3, 4, 12);
	FIntVector Zero;
	FIntVector Uniform(7);
	FIntVector Copied(Explicit);
	return Explicit.Z == 12 && Zero.IsZero() && Uniform.Y == 7 && Copied.X == 3;
}
/** @end */
/**
 * @begin surface-006
 * @summary FIntVector.
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary FIntVector.
 * @covers FIntVector.surface-006
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// axes. Negation flips signs.

X of (3,4,12) is 3. Query, no fixture.
bool ObserveSurface006Nominal()
{
	return FIntVector(3, 4, 12).X == 3;
}
/** @end */
/**
 * @begin surface-007
 * @summary FIntVector.
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary FIntVector.
 * @covers FIntVector.surface-007
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// axes. Negation flips signs.

Y of (3,4,12) is 4. Query, no fixture.
bool ObserveSurface007Nominal()
{
	return FIntVector(3, 4, 12).Y == 4;
}
/** @end */
/**
 * @begin surface-008
 * @summary FIntVector.
 * @topic Unreal
 */
/**
 * @function ObserveSurface008Nominal
 * @summary FIntVector.
 * @covers FIntVector.surface-008
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// axes. Negation flips signs.

Z of (3,4,12) is 12. Query, no fixture.
bool ObserveSurface008Nominal()
{
	return FIntVector(3, 4, 12).Z == 12;
}
/** @end */
/**
 * @begin unary-fintvector-3-4
 * @summary Unary -FIntVector(3,4,12) is (-3,-4,-12).
 * @topic Unreal
 */
/**
 * @function ObserveSurface012Nominal
 * @summary Unary -FIntVector(3,4,12) is (-3,-4,-12).
 * @covers FIntVector.unary-fintvector-3-4
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// axes. Negation flips signs.

bool ObserveSurface012Nominal()
{
	FIntVector Negated = -FIntVector(3, 4, 12);
	return Negated.X == -3 && Negated.Z == -12;
}
/** @end */
/**
 * @begin size
 * @summary FIntVector.
 * @topic Unreal
 */
/**
 * @function ObserveSizeNominal
 * @summary FIntVector.
 * @covers FIntVector.size
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// axes. Negation flips signs.

Size of (3,4,12) is 13 and Size of zero is 0. Integer Euclidean length.
bool ObserveSizeNominal()
{
	return FIntVector(3, 4, 12).Size() == 13 && FIntVector(0, 0, 0).Size() == 0;
}
/** @end */
/**
 * @begin surface-001
 * @summary FIntVector default
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary FIntVector default
 * @covers FIntVector.surface-001
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
 construction is (0,0,0). Type declaration, no fixture.
bool ObserveSurface001Nominal()
{
	FIntVector Vector;
	return Vector.X == 0 && Vector.Y == 0 && Vector.Z == 0;
}
/** @end */
/**
 * @begin assignment
 * @summary Vector =
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Vector =
 * @covers FIntVector.assignment
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
 Other copies (1,1,1) into (2,4,6). Assignment mutates Left.
bool ObserveAssignmentNominal()
{
	FIntVector Vector(2, 4, 6);
	FIntVector Other(1, 1, 1);
	Vector = Other;
	return Vector.X == 1 && Vector.Z == 1;
}
/** @end */
/**
 * @begin multiply-assign
 * @summary Vector *=
 * @topic Unreal
 */
/**
 * @function ObserveMultiplyAssignNominal
 * @summary Vector *=
 * @covers FIntVector.multiply-assign
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
 2 doubles (2,4,6) to (4,8,12). In-place scale.
bool ObserveMultiplyAssignNominal()
{
	FIntVector Vector(2, 4, 6);
	Vector *= 2;
	return Vector.X == 4 && Vector.Z == 12;
}
/** @end */
/**
 * @begin divide-assign
 * @summary Vector /=
 * @topic Unreal
 */
/**
 * @function ObserveDivideAssignNominal
 * @summary Vector /=
 * @covers FIntVector.divide-assign
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
 2 halves (2,4,6) to (1,2,3) with integer division.
bool ObserveDivideAssignNominal()
{
	FIntVector Vector(2, 4, 6);
	Vector /= 2;
	return Vector.X == 1 && Vector.Y == 2 && Vector.Z == 3;
}
/** @end */
/**
 * @begin add-assign
 * @summary Vector += (1,1,1) yields (3,5,7).
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary Vector += (1,1,1) yields (3,5,7).
 * @covers FIntVector.add-assign
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal()
{
	FIntVector Vector(2, 4, 6);
	Vector += FIntVector(1, 1, 1);
	return Vector.X == 3 && Vector.Z == 7;
}
/** @end */
/**
 * @begin subtract-assign
 * @summary Vector -= (1,1,1) yields (1,3,5).
 * @topic Unreal
 */
/**
 * @function ObserveSubtractAssignNominal
 * @summary Vector -= (1,1,1) yields (1,3,5).
 * @covers FIntVector.subtract-assign
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSubtractAssignNominal()
{
	FIntVector Vector(2, 4, 6);
	Vector -= FIntVector(1, 1, 1);
	FString Text = "v:";
	Text += Vector;
	return Vector.X == 1 && Text.Len() > 2;
}
/** @end */
/**
 * @begin to-string
 * @summary Boundary/ownership: ToString returns a new FString.
 * @topic Unreal
 */
/**
 * @function ObserveToStringNominal
 * @summary Boundary/ownership: ToString returns a new FString.
 * @covers FIntVector.to-string
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToStringNominal()
{
	FIntVector Vector(1, 2, 3);
	FString Text = Vector.ToString();
	FString ZeroText = FIntVector(0, 0, 0).ToString();
	return Text.Len() > 0 && ZeroText.Len() > 0 && Vector.X == 1;
}
/** @end */
/**
 * @begin append
 * @summary Boundary/ownership: Append copies formatted text.
 * @topic Unreal
 */
/**
 * @function ObserveAppendNominal
 * @summary Boundary/ownership: Append copies formatted text.
 * @covers FIntVector.append
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAppendNominal()
{
	FString Text = "v:";
	FIntVector Vector(1, 2, 3);
	int Before = Text.Len();
	Text.Append(Vector);
	int AfterFirst = Text.Len();
	Text.Append(Vector);
	int AfterSecond = Text.Len();
	Text.Empty();
	return AfterFirst > Before && AfterSecond > AfterFirst && Text.IsEmpty() && Vector.X == 1;
}
/** @end */
/**
 * @begin addition
 * @summary Vector +
 * @topic Unreal
 */
/**
 * @function ObserveAdditionNominal
 * @summary Vector +
 * @covers FIntVector.addition
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
 Other is (3,5,7). FString + Vector is longer than "v:". Source unchanged.
bool ObserveAdditionNominal()
{
	FIntVector Vector(2, 4, 6);
	FIntVector Sum = Vector + FIntVector(1, 1, 1);
	FString Combined = FString("v:") + Vector;
	return Sum.X == 3 && Sum.Z == 7 && Combined.Len() > 2 && Vector.X == 2;
}
/** @end */
/**
 * @begin subtraction
 * @summary Vector -
 * @topic Unreal
 */
/**
 * @function ObserveSubtractionNominal
 * @summary Vector -
 * @covers FIntVector.subtraction
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
 Other is (1,3,5). Value-returning subtraction.
bool ObserveSubtractionNominal()
{
	FIntVector Vector(2, 4, 6);
	FIntVector Difference = Vector - FIntVector(1, 1, 1);
	return Difference.X == 1 && Difference.Z == 5;
}
/** @end */
/**
 * @begin surface-013
 * @summary Vector
 * @topic Unreal
 */
/**
 * @function ObserveSurface013Nominal
 * @summary Vector
 * @covers FIntVector.surface-013
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
 2 is (4,8,12). Value-returning scale.
bool ObserveSurface013Nominal()
{
	FIntVector Vector(2, 4, 6);
	FIntVector Scaled = Vector * 2;
	return Scaled.X == 4 && Scaled.Z == 12;
}
/** @end */
/**
 * @begin surface-014
 * @summary Vector /
 * @topic Unreal
 */
/**
 * @function ObserveSurface014Nominal
 * @summary Vector /
 * @covers FIntVector.surface-014
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
 2 is (1,2,3) with integer division.
bool ObserveSurface014Nominal()
{
	FIntVector Vector(2, 4, 6);
	FIntVector Quotient = Vector / 2;
	return Quotient.Y == 2 && Quotient.Z == 3;
}
/** @end */
/**
 * @begin index
 * @summary Vector[0] is X and Vector[2] is Z.
 * @topic Unreal
 */
/**
 * @function ObserveIndexNominal
 * @summary Vector[0] is X and Vector[2] is Z.
 * @covers FIntVector.index
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIndexNominal()
{
	FIntVector Vector(2, 4, 6);
	return Vector[0] == 2 && Vector[2] == 6;
}
/** @end */
/**
 * @begin equality
 * @summary Copies compare true; differing Z compares false.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary Copies compare true; differing Z compares false.
 * @covers FIntVector.equality
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FIntVector Left(2, 4, 6);
	FIntVector Right(2, 4, 6);
	FIntVector Different(2, 4, 7);
	return (Left == Right) && !(Left == Different);
}
/** @end */
/**
 * @begin get-max
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveGetMaxNominal
 * @summary Observe the container API.
 * @covers FIntVector.get-max
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 only for (0,0,0). Negative components participate in min.
// Boundary/ownership: Queries return scalars and do not mutate the vector.
bool ObserveGetMaxNominal()
{
	FIntVector Vector(2, 8, 4);
	FIntVector Zero(0, 0, 0);
	return Vector.GetMax() == 8 && Zero.GetMax() == 0;
}
/** @end */
/**
 * @begin get-min
 * @summary Boundary/ownership: Queries return scalars and do not mutate the vector.
 * @topic Unreal
 */
/**
 * @function ObserveGetMinNominal
 * @summary Boundary/ownership: Queries return scalars and do not mutate the vector.
 * @covers FIntVector.get-min
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetMinNominal()
{
	FIntVector Vector(2, 8, 4);
	FIntVector Negative(-3, 1, 2);
	return Vector.GetMin() == 2 && Negative.GetMin() == -3;
}
/** @end */
/**
 * @begin is-zero
 * @summary Boundary/ownership: Queries return scalars and do not mutate the vector.
 * @topic Unreal
 */
/**
 * @function ObserveIsZeroNominal
 * @summary Boundary/ownership: Queries return scalars and do not mutate the vector.
 * @covers FIntVector.is-zero
 * @inputs FIntVector values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIsZeroNominal()
{
	return FIntVector(0, 0, 0).IsZero() && !FIntVector(0, 0, 1).IsZero();
}
/** @end */
