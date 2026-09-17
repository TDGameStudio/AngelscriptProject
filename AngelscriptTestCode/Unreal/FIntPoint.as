/**
 * @version v1
 * @summary FIntPoint host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FIntPoint
 *
 * inputs-zero-3-4
 * fintpoint-x-y-fintpoint
 * fintpoint-x
 * fintpoint-y
 * size
 * assignment
 * multiply-assign
 * divide-assign
 * add-assign
 * subtract-assign
 * index
 * equality
 * get-max
 * get-min
 */
/**
 * @begin inputs-zero-3-4
 * @summary Inputs: Default/zero, (3,4) so Size is 5, uniform 7,
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Inputs: Default/zero, (3,4) so Size is 5, uniform 7,
 * @covers FIntPoint.inputs-zero-3-4
 * @inputs FIntPoint values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Default/zero, (3,4) so Size is 5, uniform 7,

 copy of (3,4).
// Expected observations: Default is (0,0). Uniform 7 is (7,7). Copy preserves
// (3,4). Size of (3,4) is 5.
// Boundary/ownership: Size is integer length of the vector. Construction
// copies values.
// FIntPoint Value; default construction is (0, 0). No fixture.
bool ObserveSurface001Nominal()
{
	FIntPoint Value;
	return Value.X == 0 && Value.Y == 0;
}
/** @end */
/**
 * @begin fintpoint-x-y-fintpoint
 * @summary FIntPoint(X,Y), FIntPoint(), FIntPoint(F), and copy.
 * @topic Unreal
 */
/**
 * @function ObserveValueNominal
 * @summary FIntPoint(X,Y), FIntPoint(), FIntPoint(F), and copy.
 * @covers FIntPoint.fintpoint-x-y-fintpoint
 * @inputs FIntPoint values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Default/zero, (3,4) so Size is 5, uniform 7,

 copy of (3,4).
bool ObserveValueNominal()
{
	FIntPoint Explicit(3, 4);
	FIntPoint Zero;
	FIntPoint Uniform(7);
	FIntPoint Copied(Explicit);
	return Explicit.X == 3 && Uniform.X == 7 && Uniform.Y == 7 && Copied.Y == 4;
}
/** @end */
/**
 * @begin fintpoint-x
 * @summary FIntPoint.X
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary FIntPoint.X
 * @covers FIntPoint.fintpoint-x
 * @inputs FIntPoint values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Default/zero, (3,4) so Size is 5, uniform 7,

 field of (3,4) is 3. Query, no fixture.
bool ObserveSurface006Nominal()
{
	FIntPoint Point(3, 4);
	return Point.X == 3;
}
/** @end */
/**
 * @begin fintpoint-y
 * @summary FIntPoint.Y
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary FIntPoint.Y
 * @covers FIntPoint.fintpoint-y
 * @inputs FIntPoint values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Default/zero, (3,4) so Size is 5, uniform 7,

 field of (3,4) is 4. Query, no fixture.
bool ObserveSurface007Nominal()
{
	FIntPoint Point(3, 4);
	return Point.Y == 4;
}
/** @end */
/**
 * @begin size
 * @summary FIntPoint.
 * @topic Unreal
 */
/**
 * @function ObserveSizeNominal
 * @summary FIntPoint.
 * @covers FIntPoint.size
 * @inputs FIntPoint values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Default/zero, (3,4) so Size is 5, uniform 7,

Size of (3,4) is 5 and Size of (0,0) is 0. Integer Euclidean length.
bool ObserveSizeNominal()
{
	FIntPoint Point(3, 4);
	FIntPoint Zero(0, 0);
	return Point.Size() == 5 && Zero.Size() == 0;
}
/** @end */
/**
 * @begin assignment
 * @summary Expected observations: + is (3,5).
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Expected observations: + is (3,5).
 * @covers FIntPoint.assignment
 * @inputs FIntPoint values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: + is (3,5). *

 2 is (4,8). / 2 is (1,2). += mutates
// in place. Zero addition is stable. Integer division truncates.
// Boundary/ownership: Value-returning operators do not mutate Point.
bool ObserveAssignmentNominal()
{
	FIntPoint Point(2, 4);
	FIntPoint Other(1, 1);
	Point = Other;
	FIntPoint Sum = Point + Other;
	FIntPoint Difference = Point - Other;
	FIntPoint Negated = -Point;
	return Point.X == 1 && Point.Y == 1 && Sum.X == 2 && Difference.X == 0 && Negated.X == -1;
}
/** @end */
/**
 * @begin multiply-assign
 * @summary Boundary/ownership: Value-returning operators do not mutate Point.
 * @topic Unreal
 */
/**
 * @function ObserveMultiplyAssignNominal
 * @summary Boundary/ownership: Value-returning operators do not mutate Point.
 * @covers FIntPoint.multiply-assign
 * @inputs FIntPoint values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: + is (3,5). *

bool ObserveMultiplyAssignNominal()
{
	FIntPoint Point(2, 4);
	FIntPoint Scaled = Point * 2;
	Point *= 2;
	return Scaled.X == 4 && Point.X == 4 && Point.Y == 8;
}
/** @end */
/**
 * @begin divide-assign
 * @summary Boundary/ownership: Value-returning operators do not mutate Point.
 * @topic Unreal
 */
/**
 * @function ObserveDivideAssignNominal
 * @summary Boundary/ownership: Value-returning operators do not mutate Point.
 * @covers FIntPoint.divide-assign
 * @inputs FIntPoint values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: + is (3,5). *

bool ObserveDivideAssignNominal()
{
	FIntPoint Point(2, 4);
	FIntPoint Quotient = Point / 2;
	Point /= 2;
	return Quotient.X == 1 && Point.X == 1 && Point.Y == 2;
}
/** @end */
/**
 * @begin add-assign
 * @summary Boundary/ownership: Value-returning operators do not mutate Point.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary Boundary/ownership: Value-returning operators do not mutate Point.
 * @covers FIntPoint.add-assign
 * @inputs FIntPoint values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: + is (3,5). *

bool ObserveAddAssignNominal()
{
	FIntPoint Point(2, 4);
	Point += FIntPoint(1, 1);
	return Point.X == 3 && Point.Y == 5;
}
/** @end */
/**
 * @begin subtract-assign
 * @summary Boundary/ownership: Value-returning operators do not mutate Point.
 * @topic Unreal
 */
/**
 * @function ObserveSubtractAssignNominal
 * @summary Boundary/ownership: Value-returning operators do not mutate Point.
 * @covers FIntPoint.subtract-assign
 * @inputs FIntPoint values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: + is (3,5). *

bool ObserveSubtractAssignNominal()
{
	FIntPoint Point(2, 4);
	Point -= FIntPoint(1, 1);
	return Point.X == 1 && Point.Y == 3;
}
/** @end */
/**
 * @begin index
 * @summary Observe Observe_Index_Nominal on FIntPoint.
 * @topic Unreal
 */
/**
 * @function ObserveIndexNominal
 * @summary Observe Observe_Index_Nominal on FIntPoint.
 * @covers FIntPoint.index
 * @inputs FIntPoint values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIndexNominal()
{
	FIntPoint Point(2, 4);
	return Point[0] == 2 && Point[1] == 4;
}
/** @end */
/**
 * @begin equality
 * @summary Observe Observe_Equality_Nominal on FIntPoint.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary Observe Observe_Equality_Nominal on FIntPoint.
 * @covers FIntPoint.equality
 * @inputs FIntPoint values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FIntPoint Point(2, 4);
	FIntPoint Other(2, 4);
	FIntPoint Different(2, 5);
	return (Point == Other) && !(Point == Different);
}
/** @end */
/**
 * @begin get-max
 * @summary Boundary/ownership: These return component values, not indices.
 * @topic Unreal
 */
/**
 * @function ObserveGetMaxNominal
 * @summary Boundary/ownership: These return component values, not indices.
 * @covers FIntPoint.get-max
 * @inputs FIntPoint values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetMaxNominal()
{
	FIntPoint Point(2, 4);
	FIntPoint Swapped(4, 2);
	FIntPoint Zero(0, 0);
	return Point.GetMax() == 4 && Swapped.GetMax() == 4 && Zero.GetMax() == 0;
}
/** @end */
/**
 * @begin get-min
 * @summary Boundary/ownership: These return component values, not indices.
 * @topic Unreal
 */
/**
 * @function ObserveGetMinNominal
 * @summary Boundary/ownership: These return component values, not indices.
 * @covers FIntPoint.get-min
 * @inputs FIntPoint values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetMinNominal()
{
	FIntPoint Point(2, 4);
	FIntPoint Swapped(4, 2);
	FIntPoint Zero(0, 0);
	return Point.GetMin() == 2 && Swapped.GetMin() == 2 && Zero.GetMin() == 0;
}
/** @end */
