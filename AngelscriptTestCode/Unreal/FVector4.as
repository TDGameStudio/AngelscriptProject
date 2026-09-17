/**
 * @version v1
 * @summary FVector4 host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FVector4
 *
 * vector
 * surface-006
 * surface-007
 * surface-008
 * surface-009
 * assignment
 * multiply-assign
 * index
 * equality
 */
/**
 * @begin vector
 * @summary Expected observations:
 * @topic Unreal
 */
/**
 * @function ObserveVectorNominal
 * @summary Expected observations:
 * @covers FVector4.vector
 * @inputs FVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 Default is (0,0,0,0). Copy preserves W 4. FVector
// conversion fills XYZ and the supplied W. FVector4f conversion keeps all
// four components. Fields match constructors.
// Boundary/ownership: Constructors copy values. Components are float64.
// FVector4(X,Y,Z,W), default, copy, FVector+W, and FVector4f constructors.
bool ObserveVectorNominal()
{
	FVector4 Explicit(1, 2, 3, 4);
	FVector4 Zero;
	FVector4 Copied(Explicit);
	FVector4 From3(FVector(5, 6, 7), 8);
	FVector4 FromFloat(FVector4f(9.0f, 10.0f, 11.0f, 12.0f));
	return Explicit.W == 4.0 &&
		Zero.X == 0.0 &&
		Zero.W == 0.0 &&
		Copied.Y == 2.0 &&
		From3.X == 5.0 &&
		From3.Z == 7.0 &&
		From3.W == 8.0 &&
		FromFloat.X == 9.0 &&
		FromFloat.W == 12.0;
}
/** @end */
/**
 * @begin surface-006
 * @summary FVector4.
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary FVector4.
 * @covers FVector4.surface-006
 * @inputs FVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

X of (1,2,3,4) is 1. Field read does not mutate.
bool ObserveSurface006Nominal()
{
	return FVector4(1, 2, 3, 4).X == 1.0;
}
/** @end */
/**
 * @begin surface-007
 * @summary FVector4.
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary FVector4.
 * @covers FVector4.surface-007
 * @inputs FVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

Y of (1,2,3,4) is 2. Field read does not mutate.
bool ObserveSurface007Nominal()
{
	return FVector4(1, 2, 3, 4).Y == 2.0;
}
/** @end */
/**
 * @begin surface-008
 * @summary FVector4.
 * @topic Unreal
 */
/**
 * @function ObserveSurface008Nominal
 * @summary FVector4.
 * @covers FVector4.surface-008
 * @inputs FVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

Z of (1,2,3,4) is 3. Field read does not mutate.
bool ObserveSurface008Nominal()
{
	return FVector4(1, 2, 3, 4).Z == 3.0;
}
/** @end */
/**
 * @begin surface-009
 * @summary FVector4.
 * @topic Unreal
 */
/**
 * @function ObserveSurface009Nominal
 * @summary FVector4.
 * @covers FVector4.surface-009
 * @inputs FVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

W of (1,2,3,4) is 4. Field read does not mutate.
bool ObserveSurface009Nominal()
{
	return FVector4(1, 2, 3, 4).W == 4.0;
}
/** @end */
/**
 * @begin assignment
 * @summary copies digits into a new FString.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary copies digits into a new FString.
 * @covers FVector4.assignment
 * @inputs FVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FVector4 Left(2, 4, 6, 8);
	FVector4 Right(1, 1, 1, 1);
	Left = Right;
	Left.W = 9.0;
	FVector4 Vector(2, 4, 6, 8);
	FVector4 Sum = Vector + Right;
	FVector4 Difference = Vector - Right;
	FVector4 Scaled = Vector * 2.0;
	FVector4 Quotient = Vector / 2.0;
	FVector4 Zero;
	FString Text = f"{Vector}";
	FString ZeroText = f"{Zero}";
	return Left.W == 9.0 &&
		Right.W == 1.0 &&
		Sum.X == 3.0 &&
		Sum.W == 9.0 &&
		Difference.X == 1.0 &&
		Scaled.W == 16.0 &&
		Quotient.W == 4.0 &&
		Text.Len() > 0 &&
		ZeroText.Len() > 0 &&
		Vector.W == 8.0;
}
/** @end */
/**
 * @begin multiply-assign
 * @summary copies digits into a new FString.
 * @topic Unreal
 */
/**
 * @function ObserveMultiplyAssignNominal
 * @summary copies digits into a new FString.
 * @covers FVector4.multiply-assign
 * @inputs FVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMultiplyAssignNominal()
{
	FVector4 Vector(2, 4, 6, 8);
	Vector *= 2.0;
	return Vector.X == 4.0 && Vector.W == 16.0;
}
/** @end */
/**
 * @begin index
 * @summary diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveIndexNominal
 * @summary diagnostic path.
 * @covers FVector4.index
 * @inputs FVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIndexNominal()
{
	FVector4 Vector(2, 4, 6, 8);
	float64 X = Vector[0];
	float64 W = Vector[3];
	Vector[1] = 9.0;
	return X == 2.0 && W == 8.0 && Vector.Y == 9.0;
}
/** @end */
/**
 * @begin equality
 * @summary diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary diagnostic path.
 * @covers FVector4.equality
 * @inputs FVector4 values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FVector4 Left(2, 4, 6, 8);
	FVector4 Right(2, 4, 6, 8);
	FVector4 Different(2, 4, 6, 9);
	return (Left == Right) && !(Left == Different);
}
/** @end */
