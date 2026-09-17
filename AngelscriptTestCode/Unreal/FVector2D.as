/**
 * @version v1
 * @summary FVector2D host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FVector2D
 *
 * vector
 * surface-006
 * surface-007
 * surface-017
 * cross-product
 * dot-product
 * size
 * size-squared
 * normalize
 * distance
 * dist-squared
 * init-from-string
 * inputs-2-4-other
 * assignment
 * multiply-assign
 * divide-assign
 * add-assign
 * subtract-assign
 * to-string
 * append
 * inputs-each-published-constant
 * container-api
 * addition
 * subtraction
 * vector-other-per-component
 * FVector2D-Operators_01-vector-other-per-component
 * vector-scale-2-4
 * FVector2D-Operators_01-vector-scale-2-4
 * index
 * equality
 * FVector2D-Operators_02-addition
 * equals
 * get-max
 * get-abs-max
 * get-min
 * get-abs
 * is-nearly-zero
 * is-zero
 * get-safe-normal
 * contains-na-n
 * get-sign-vector
 * get-clamped-to-max-size
 * container-properties
 * declaration-defaults
 * write-round-trip
 * vector-2-d-arithmetic-operators
 * vector-2-d-comparison-operators
 * vector-2-d-construction
 * vector-2-d-dot-product
 * vector-2-d-member-access
 * function-default-parameters
 * function-parameters-in
 * function-parameters-in-out
 * function-parameters-out
 * function-parameters-value
 * function-return-values

 */
/**
 * @begin vector
 * @summary Expected observations:
 * @topic Unreal
 */
/**
 * @function ObserveVectorNominal
 * @summary Expected observations:
 * @covers FVector2D.vector
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 Default is (0,0). Copy preserves (3,4). FVector2f
// conversion keeps 7/8. Cross of (1,0) and (0,1) is 1. Dot of those is 0.
// Size of (3,4) is 5. Negation flips signs.
// Boundary/ownership: 2D CrossProduct is a scalar. Constructors copy values.
// FVector2D(X,Y), default, copy, FVector2f: default is zero; copy and conversion keep components.
bool ObserveVectorNominal()
{
	FVector2D Explicit(3, 4);
	FVector2D Zero;
	FVector2D Copied(Explicit);
	FVector2D FromFloat(FVector2f(7, 8));
	return Explicit.Y == 4.0 && Zero.IsZero() && Copied.X == 3.0 && FromFloat.X == 7.0 && FromFloat.Y == 8.0;
}
/** @end */
/**
 * @begin surface-006
 * @summary FVector2D.
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary FVector2D.
 * @covers FVector2D.surface-006
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

X of (3,4) is 3. Field read, no mutation.
bool ObserveSurface006Nominal()
{
	return FVector2D(3, 4).X == 3.0;
}
/** @end */
/**
 * @begin surface-007
 * @summary FVector2D.
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary FVector2D.
 * @covers FVector2D.surface-007
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

Y of (3,4) is 4. Field read, no mutation.
bool ObserveSurface007Nominal()
{
	return FVector2D(3, 4).Y == 4.0;
}
/** @end */
/**
 * @begin surface-017
 * @summary Unary
 * @topic Unreal
 */
/**
 * @function ObserveSurface017Nominal
 * @summary Unary
 * @covers FVector2D.surface-017
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 minus of (3,4) is (-3,-4). Returns a new vector.
bool ObserveSurface017Nominal()
{
	FVector2D Negated = -FVector2D(3, 4);
	return Negated.X == -3.0 && Negated.Y == -4.0;
}
/** @end */
/**
 * @begin cross-product
 * @summary 2D CrossProduct is a scalar: (1,0)x(0,1) is 1.
 * @topic Unreal
 */
/**
 * @function ObserveCrossProductNominal
 * @summary 2D CrossProduct is a scalar: (1,0)x(0,1) is 1.
 * @covers FVector2D.cross-product
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveCrossProductNominal()
{
	float64 Cross = FVector2D(1, 0).CrossProduct(FVector2D(0, 1));
	float64 Reverse = FVector2D(0, 1).CrossProduct(FVector2D(1, 0));
	return Cross == 1.0 && Reverse == -1.0;
}
/** @end */
/**
 * @begin dot-product
 * @summary DotProduct: orthogonal axes are 0.
 * @topic Unreal
 */
/**
 * @function ObserveDotProductNominal
 * @summary DotProduct: orthogonal axes are 0.
 * @covers FVector2D.dot-product
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveDotProductNominal()
{
	float64 Orthogonal = FVector2D(1, 0).DotProduct(FVector2D(0, 1));
	float64 Aligned = FVector2D(1, 0).DotProduct(FVector2D(1, 0));
	return Orthogonal == 0.0 && Aligned == 1.0;
}
/** @end */
/**
 * @begin size
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSizeNominal
 * @summary Observe the container API.
 * @covers FVector2D.size
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 Size of (3,4) is 5; zero size is 0.
bool ObserveSizeNominal()
{
	return FVector2D(3, 4).Size() == 5.0 && FVector2D(0, 0).Size() == 0.0;
}
/** @end */
/**
 * @begin size-squared
 * @summary Expected observations:
 * @topic Unreal
 */
/**
 * @function ObserveSizeSquaredNominal
 * @summary Expected observations:
 * @covers FVector2D.size-squared
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 SizeSquared of (3,4) is 25. Normalize of (3,0)
// yields (1,0). Normalize of zero yields zero. Distance is 5. DistSquared
// is 25. InitFromString true parses (1,2); empty returns false.
// Boundary/ownership: Normalize is void and mutates. InitFromString mutates.
// Distance helpers do not mutate.
bool ObserveSizeSquaredNominal()
{
	return FVector2D(3, 4).SizeSquared() == 25.0 && FVector2D(0, 0).SizeSquared() == 0.0;
}
/** @end */
/**
 * @begin normalize
 * @summary Distance helpers do not mutate.
 * @topic Unreal
 */
/**
 * @function ObserveNormalizeNominal
 * @summary Distance helpers do not mutate.
 * @covers FVector2D.normalize
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveNormalizeNominal()
{
	FVector2D Vector(3, 0);
	Vector.Normalize();
	FVector2D Zero;
	Zero.Normalize();
	return Vector.Equals(FVector2D(1, 0)) && Zero.IsZero();
}
/** @end */
/**
 * @begin distance
 * @summary Distance helpers do not mutate.
 * @topic Unreal
 */
/**
 * @function ObserveDistanceNominal
 * @summary Distance helpers do not mutate.
 * @covers FVector2D.distance
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveDistanceNominal()
{
	return FVector2D(0, 0).Distance(FVector2D(3, 4)) == 5.0 && FVector2D(1, 1).Distance(FVector2D(1, 1)) == 0.0;
}
/** @end */
/**
 * @begin dist-squared
 * @summary Distance helpers do not mutate.
 * @topic Unreal
 */
/**
 * @function ObserveDistSquaredNominal
 * @summary Distance helpers do not mutate.
 * @covers FVector2D.dist-squared
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveDistSquaredNominal()
{
	return FVector2D(0, 0).DistSquared(FVector2D(3, 4)) == 25.0;
}
/** @end */
/**
 * @begin init-from-string
 * @summary Distance helpers do not mutate.
 * @topic Unreal
 */
/**
 * @function ObserveInitFromStringNominal
 * @summary Distance helpers do not mutate.
 * @covers FVector2D.init-from-string
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveInitFromStringNominal()
{
	FVector2D Parsed;
	bool bValid = Parsed.InitFromString("X=1 Y=2");
	FVector2D EmptyTarget(9, 9);
	bool bEmpty = EmptyTarget.InitFromString("");
	return bValid && Parsed.Equals(FVector2D(1, 2)) && !bEmpty;
}
/** @end */
/**
 * @begin inputs-2-4-other
 * @summary Inputs: (2,4), Other (1,1), Scale 2, Divisor 2,
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Inputs: (2,4), Other (1,1), Scale 2, Divisor 2,
 * @covers FVector2D.inputs-2-4-other
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: (2,4), Other (1,1), Scale 2, Divisor 2,

 component scale (0.5,0.5),
// text "v:".
// Expected observations: Assignment copies independently. *= 2 doubles.
// /= 2 halves. Component *= and /= scale each axis. += and -= mutate.
// Text += grows length.
// Boundary/ownership: Compound operators mutate Vector. Text append copies
// formatted digits.
// struct FVector2D; default Value is (0,0). Declaration, no fixture.
bool ObserveSurface001Nominal()
{
	FVector2D Value;
	return Value.X == 0.0 && Value.Y == 0.0;
}
/** @end */
/**
 * @begin assignment
 * @summary Vector = Other copies XY.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Vector = Other copies XY.
 * @covers FVector2D.assignment
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: (2,4), Other (1,1), Scale 2, Divisor 2,

bool ObserveAssignmentNominal()
{
	FVector2D Vector(2, 4);
	FVector2D Other(1, 1);
	Vector = Other;
	Vector.X = 9.0;
	return Vector.X == 9.0 && Other.X == 1.0 && Other.Y == 1.0;
}
/** @end */
/**
 * @begin multiply-assign
 * @summary Vector *= Scale then *= Other: (2,4)
 * @topic Unreal
 */
/**
 * @function ObserveMultiplyAssignNominal
 * @summary Vector *= Scale then *= Other: (2,4)
 * @covers FVector2D.multiply-assign
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: (2,4), Other (1,1), Scale 2, Divisor 2,

2 is (4,8); *0.5 restores (2,4). Mutates receiver.
bool ObserveMultiplyAssignNominal()
{
	FVector2D Vector(2, 4);
	Vector *= 2.0;
	bool bScale = Vector.X == 4.0 && Vector.Y == 8.0;
	Vector *= FVector2D(0.5, 0.5);
	return bScale && Vector.X == 2.0 && Vector.Y == 4.0;
}
/** @end */
/**
 * @begin divide-assign
 * @summary Vector /= Scale then /= Other: (2,4)/
 * @topic Unreal
 */
/**
 * @function ObserveDivideAssignNominal
 * @summary Vector /= Scale then /= Other: (2,4)/
 * @covers FVector2D.divide-assign
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: (2,4), Other (1,1), Scale 2, Divisor 2,

2 is (1,2); /(1,2) is (1,1). Mutates receiver.
bool ObserveDivideAssignNominal()
{
	FVector2D Vector(2, 4);
	Vector /= 2.0;
	bool bScale = Vector.X == 1.0 && Vector.Y == 2.0;
	Vector /= FVector2D(1, 2);
	return bScale && Vector.X == 1.0 && Vector.Y == 1.0;
}
/** @end */
/**
 * @begin add-assign
 * @summary Vector += Other: (2,4)+(1,1) is (3,5).
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary Vector += Other: (2,4)+(1,1) is (3,5).
 * @covers FVector2D.add-assign
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: (2,4), Other (1,1), Scale 2, Divisor 2,

bool ObserveAddAssignNominal()
{
	FVector2D Vector(2, 4);
	FVector2D Other(1, 1);
	Vector += Other;
	return Vector.X == 3.0 && Vector.Y == 5.0 && Other.X == 1.0;
}
/** @end */
/**
 * @begin subtract-assign
 * @summary Vector -= Other then Text += Vector: (2,4)-(1,1) is (1,3).
 * @topic Unreal
 */
/**
 * @function ObserveSubtractAssignNominal
 * @summary Vector -= Other then Text += Vector: (2,4)-(1,1) is (1,3).
 * @covers FVector2D.subtract-assign
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: (2,4), Other (1,1), Scale 2, Divisor 2,

bool ObserveSubtractAssignNominal()
{
	FVector2D Vector(2, 4);
	Vector -= FVector2D(1, 1);
	FString Text = "v:";
	Text += Vector;
	return Vector.X == 1.0 && Vector.Y == 3.0 && Text.Len() > 2;
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
 * @covers FVector2D.to-string
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToStringNominal()
{
	FVector2D Vector(1, 2);
	FString Text = Vector.ToString();
	FString ZeroText = FVector2D(0, 0).ToString();
	return Text.Len() > 0 && ZeroText.Len() > 0 && Vector.X == 1.0;
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
 * @covers FVector2D.append
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAppendNominal()
{
	FString Text = "v:";
	FVector2D Vector(1, 2);
	int Before = Text.Len();
	Text.Append(Vector);
	int AfterFirst = Text.Len();
	Text.Append(Vector);
	int AfterSecond = Text.Len();
	Text.Empty();
	return AfterFirst > Before && AfterSecond > AfterFirst && Text.IsEmpty() && Vector.X == 1.0;
}
/** @end */
/**
 * @begin inputs-each-published-constant
 * @summary Inputs: Each published constant
 * @topic Unreal
 */
/**
 * @function ObserveSurface046Nominal
 * @summary Inputs: Each published constant
 * @covers FVector2D.inputs-each-published-constant
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Each published constant

 compared against (0,0) and (1,1).
// Expected observations: ZeroVector is (0,0). UnitVector is (1,1).
// Boundary/ownership: Constants are shared values, not factory functions.
// FVector2D::ZeroVector is (0,0). Shared constant.
bool ObserveSurface046Nominal()
{
	return FVector2D::ZeroVector.X == 0.0 && FVector2D::ZeroVector.Y == 0.0;
}
/** @end */
/**
 * @begin container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface047Nominal
 * @summary Observe the container API.
 * @covers FVector2D.container-api
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Each published constant

 FVector2D::UnitVector is (1,1). Shared constant.
bool ObserveSurface047Nominal()
{
	return FVector2D::UnitVector.X == 1.0 && FVector2D::UnitVector.Y == 1.0;
}
/** @end */
/**
 * @begin addition
 * @summary Expected observations: + is (3,5).
 * @topic Unreal
 */
/**
 * @function ObserveAdditionNominal
 * @summary Expected observations: + is (3,5).
 * @covers FVector2D.addition
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: + is (3,5). Component * is (2,8). *

 2 is (4,8).
// + Bias is (3,5). [0] is X. Index write mutates Y. Const index reads X.
// Boundary/ownership: Value-returning operators do not mutate Vector.
// Index 0/1 are X/Y. Out-of-range is the diagnostic path.
// Vector + Other and Vector + Bias: (2,4)+(1,1) and +1 are (3,5). Source X stays 2.
bool ObserveAdditionNominal()
{
	FVector2D Vector(2, 4);
	FVector2D Sum = Vector + FVector2D(1, 1);
	FVector2D Biased = Vector + 1.0;
	return Sum.X == 3.0 && Sum.Y == 5.0 && Biased.X == 3.0 && Biased.Y == 5.0 && Vector.X == 2.0;
}
/** @end */
/**
 * @begin subtraction
 * @summary Vector - Other and Vector - Bias: (2,4)-(1,1) and -
 * @topic Unreal
 */
/**
 * @function ObserveSubtractionNominal
 * @summary Vector - Other and Vector - Bias: (2,4)-(1,1) and -
 * @covers FVector2D.subtraction
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: + is (3,5). Component * is (2,8). *

1 are (1,3).
bool ObserveSubtractionNominal()
{
	FVector2D Vector(2, 4);
	FVector2D Difference = Vector - FVector2D(1, 1);
	FVector2D Biased = Vector - 1.0;
	return Difference.X == 1.0 && Difference.Y == 3.0 && Biased.X == 1.0 && Biased.Y == 3.0;
}
/** @end */
/**
 * @begin vector-other-per-component
 * @summary Vector * Other is per-component: (2,4)*(1,2) is (2,8).
 * @topic Unreal
 */
/**
 * @function ObserveSurface011Nominal
 * @summary Vector * Other is per-component: (2,4)*(1,2) is (2,8).
 * @covers FVector2D.vector-other-per-component
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: + is (3,5). Component * is (2,8). *

bool ObserveSurface011Nominal()
{
	FVector2D Vector(2, 4);
	FVector2D Product = Vector * FVector2D(1, 2);
	return Product.X == 2.0 && Product.Y == 8.0 && Vector.Y == 4.0;
}
/** @end */
/**
 * @begin FVector2D-Operators_01-vector-other-per-component
 * @summary Vector / Other is per-component: (2,4)/(2,2) is (1,2).
 * @topic Unreal
 */
/**
 * @function ObserveSurface012Nominal
 * @summary Vector / Other is per-component: (2,4)/(2,2) is (1,2).
 * @covers FVector2D.vector-other-per-component
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: + is (3,5). Component * is (2,8). *

bool ObserveSurface012Nominal()
{
	FVector2D Vector(2, 4);
	FVector2D Quotient = Vector / FVector2D(2, 2);
	return Quotient.X == 1.0 && Quotient.Y == 2.0;
}
/** @end */
/**
 * @begin vector-scale-2-4
 * @summary Vector * Scale: (2,4)
 * @topic Unreal
 */
/**
 * @function ObserveSurface013Nominal
 * @summary Vector * Scale: (2,4)
 * @covers FVector2D.vector-scale-2-4
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: + is (3,5). Component * is (2,8). *

2 is (4,8). Source X stays 2.
bool ObserveSurface013Nominal()
{
	FVector2D Vector(2, 4);
	FVector2D Scaled = Vector * 2.0;
	return Scaled.X == 4.0 && Scaled.Y == 8.0 && Vector.X == 2.0;
}
/** @end */
/**
 * @begin FVector2D-Operators_01-vector-scale-2-4
 * @summary Vector / Scale: (2,4)/
 * @topic Unreal
 */
/**
 * @function ObserveSurface014Nominal
 * @summary Vector / Scale: (2,4)/
 * @covers FVector2D.vector-scale-2-4
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: + is (3,5). Component * is (2,8). *

2 is (1,2).
bool ObserveSurface014Nominal()
{
	FVector2D Vector(2, 4);
	FVector2D Quotient = Vector / 2.0;
	return Quotient.X == 1.0 && Quotient.Y == 2.0;
}
/** @end */
/**
 * @begin index
 * @summary Vector[Index]: [0] is X, [1] is Y, write [1] mutates Y.
 * @topic Unreal
 */
/**
 * @function ObserveIndexNominal
 * @summary Vector[Index]: [0] is X, [1] is Y, write [1] mutates Y.
 * @covers FVector2D.index
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: + is (3,5). Component * is (2,8). *

bool ObserveIndexNominal()
{
	FVector2D Vector(2, 4);
	const FVector2D ConstVector(2, 4);
	float64 X = Vector[0];
	float64 Y = Vector[1];
	Vector[1] = 9.0;
	float64 ConstX = ConstVector[0];
	return X == 2.0 && Y == 4.0 && Vector.Y == 9.0 && ConstX == 2.0 && ConstVector.Y == 4.0;
}
/** @end */
/**
 * @begin equality
 * @summary Boundary/ownership: Equality is exact.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary Boundary/ownership: Equality is exact.
 * @covers FVector2D.equality
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FVector2D Left(2, 4);
	FVector2D Right(2, 4);
	FVector2D Different(2, 5);
	return (Left == Right) && !(Left == Different);
}
/** @end */
/**
 * @begin FVector2D-Operators_02-addition
 * @summary Boundary/ownership: Equality is exact.
 * @topic Unreal
 */
/**
 * @function ObserveAdditionNominal
 * @summary Boundary/ownership: Equality is exact.
 * @covers FVector2D.addition
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAdditionNominal()
{
	FVector2D Vector(2, 4);
	FString Combined = FString("v:") + Vector;
	return Combined.Len() > 2 && Vector.X == 2.0;
}
/** @end */
/**
 * @begin equals
 * @summary Expected observations:
 * @topic Unreal
 */
/**
 * @function ObserveEqualsNominal
 * @summary Expected observations:
 * @covers FVector2D.equals
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 GetMax of (2,-8) is 2. GetAbsMax is 8. GetMin is
// -8. GetAbs is (2,8). Tiny is nearly zero. (3,4) safe-normal is (0.6,0.8).
// Zero safe-normal is zero. Finite is not NaN. Sign of (1,-2) is (1,-1).
// Boundary/ownership: Equals uses tolerance. GetSafeNormal returns zero
// below Tolerance. Queries do not mutate.
bool ObserveEqualsNominal()
{
	FVector2D Left(1, 2);
	FVector2D Right(1, 2);
	FVector2D Perturbed(1.0 + KINDA_SMALL_NUMBER * 0.5, 2);
	FVector2D Far(2, 2);
	return Left.Equals(Right) && Left.Equals(Perturbed) && !Left.Equals(Far, 0.0);
}
/** @end */
/**
 * @begin get-max
 * @summary below Tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveGetMaxNominal
 * @summary below Tolerance.
 * @covers FVector2D.get-max
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetMaxNominal()
{
	return FVector2D(2, -8).GetMax() == 2.0 && FVector2D(0, 0).GetMax() == 0.0;
}
/** @end */
/**
 * @begin get-abs-max
 * @summary below Tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveGetAbsMaxNominal
 * @summary below Tolerance.
 * @covers FVector2D.get-abs-max
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetAbsMaxNominal()
{
	return FVector2D(2, -8).GetAbsMax() == 8.0 && FVector2D(0, 0).GetAbsMax() == 0.0;
}
/** @end */
/**
 * @begin get-min
 * @summary below Tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveGetMinNominal
 * @summary below Tolerance.
 * @covers FVector2D.get-min
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetMinNominal()
{
	return FVector2D(2, -8).GetMin() == -8.0 && FVector2D(0, 0).GetMin() == 0.0;
}
/** @end */
/**
 * @begin get-abs
 * @summary below Tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveGetAbsNominal
 * @summary below Tolerance.
 * @covers FVector2D.get-abs
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetAbsNominal()
{
	FVector2D Abs = FVector2D(-1, 2).GetAbs();
	return Abs.X == 1.0 && Abs.Y == 2.0;
}
/** @end */
/**
 * @begin is-nearly-zero
 * @summary below Tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveIsNearlyZeroNominal
 * @summary below Tolerance.
 * @covers FVector2D.is-nearly-zero
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveIsNearlyZeroNominal()
{
	FVector2D Tiny(KINDA_SMALL_NUMBER * 0.5, 0);
	return FVector2D(0, 0).IsNearlyZero() && Tiny.IsNearlyZero() && !FVector2D(1, 0).IsNearlyZero();
}
/** @end */
/**
 * @begin is-zero
 * @summary below Tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveIsZeroNominal
 * @summary below Tolerance.
 * @covers FVector2D.is-zero
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveIsZeroNominal()
{
	return FVector2D(0, 0).IsZero() && !FVector2D(0, 1).IsZero();
}
/** @end */
/**
 * @begin get-safe-normal
 * @summary below Tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveGetSafeNormalNominal
 * @summary below Tolerance.
 * @covers FVector2D.get-safe-normal
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetSafeNormalNominal()
{
	FVector2D Unit = FVector2D(3, 4).GetSafeNormal();
	FVector2D Zero = FVector2D(0, 0).GetSafeNormal();
	return Unit.Equals(FVector2D(0.6, 0.8)) && Zero.IsZero();
}
/** @end */
/**
 * @begin contains-na-n
 * @summary below Tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveContainsNaNNominal
 * @summary below Tolerance.
 * @covers FVector2D.contains-na-n
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveContainsNaNNominal()
{
	float64 Zero = 0.0;
	FVector2D NonFinite(Zero / Zero, 0);
	return !FVector2D(1, 2).ContainsNaN() && NonFinite.ContainsNaN();
}
/** @end */
/**
 * @begin get-sign-vector
 * @summary below Tolerance.
 * @topic Unreal
 */
/**
 * @function ObserveGetSignVectorNominal
 * @summary below Tolerance.
 * @covers FVector2D.get-sign-vector
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetSignVectorNominal()
{
	FVector2D Signs = FVector2D(1, -2).GetSignVector();
	return Signs.X == 1.0 && Signs.Y == -1.0;
}
/** @end */
/**
 * @begin get-clamped-to-max-size
 * @summary clamp.
 * @topic Unreal
 */
/**
 * @function ObserveGetClampedToMaxSizeNominal
 * @summary clamp.
 * @covers FVector2D.get-clamped-to-max-size
 * @inputs FVector2D values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetClampedToMaxSizeNominal()
{
	FVector2D Long = FVector2D(10, 0).GetClampedToMaxSize(5.0);
	FVector2D Short = FVector2D(1, 0).GetClampedToMaxSize(5.0);
	FVector2D Zero = FVector2D(0, 0).GetClampedToMaxSize(5.0);
	return Long.Equals(FVector2D(5, 0)) && Short.Equals(FVector2D(1, 0)) && Zero.IsZero();
}
/** @end */
/**
 * @begin container-properties
 * @summary WorldStory: BeginPlay fills the array with three axis vectors and the map with two populated entries and a zero vector.
 * @topic Unreal
 */
/**
 * @function BeginPlay
 * @summary WorldStory: BeginPlay fills the array with three axis vectors and the map with two populated entries and a zero vector.
 * @covers FVector2D.ContainerProperties
 * @inputs none
 * @return three entries in each container
 */
UCLASS()
class ACoverageFVector2DContainerActor : AActor
{
	UPROPERTY()
	TArray<FVector2D> VectorArray;

	UPROPERTY()
	TMap<int, FVector2D> IntToVectorMap;

	/**
	 * WorldStory: BeginPlay fills the array with three axis vectors and the map with two
	 * populated entries and a zero vector.
	 *
	 * @Kind WorldStory
	 * @Covers FVector2D.ContainerProperties
	 * @Inputs none
	 * @Return three entries in each container
	 */
	UFUNCTION(BlueprintOverride)

	void BeginPlay()
	{
		VectorArray.Add(FVector2D(1, 0));
		VectorArray.Add(FVector2D(0, 1));
		VectorArray.Add(FVector2D(1, 1));

		IntToVectorMap.Add(1, FVector2D(10, 20));
		IntToVectorMap.Add(2, FVector2D(30, 40));
		IntToVectorMap.Add(3, FVector2D::ZeroVector);
	}
/** @end */
/**
 * @begin declaration-defaults
 * @summary Observe that the zero-vector default reads as the origin.
 * @topic Unreal
 */
/**
 * @function ZeroVecNominal
 * @summary Observe that the zero-vector default reads as the origin.
 * @covers FVector2D.DeclarationDefaults
 * @inputs none
 * @return true when both components of ZeroVec are 0
 */
UCLASS()
class ACoverageFVector2DDefaultsActor : AActor
{
	UPROPERTY()
	FVector2D ZeroVec = FVector2D::ZeroVector;

	UPROPERTY()
	FVector2D OneVec = FVector2D(1, 1);

	UPROPERTY()
	FVector2D CustomVec = FVector2D(5, 10);

	UPROPERTY()
	FVector2D NoDefaultVec;

	UPROPERTY()
	FVector2D UnitXVec = FVector2D(1, 0);

	bool ZeroVecNominal()
	{
		if (ZeroVec.X != 0.0)
		{
			return false;
		}
		return ZeroVec.Y == 0.0;
	}
/** @end */
/**
 * @begin write-round-trip
 * @summary Observe that an untouched property is empty.
 * @topic Unreal
 */
/**
 * @function DefaultEmpty
 * @summary Observe that an untouched property is empty.
 * @covers FVector2D.WriteRoundTrip
 * @inputs none
 * @return true when both components are 0
 */
UCLASS()
class ACoverageFVector2DWriteActor : AActor
{
	UPROPERTY()
	FVector2D VectorValue;

	bool DefaultEmpty()
	{
		if (VectorValue.X != 0.0)
		{
			return false;
		}
		return VectorValue.Y == 0.0;
	}
/** @end */
/**
 * @begin vector-2-d-arithmetic-operators
 * @summary Divide a vector in place.
 * @topic Unreal
 */
/**
 * @function OpAddNominal
 * @summary Divide a vector in place.
 * @covers FVector2D.ArithmeticOperators
 * @inputs none
 * @return FVector2D(5.0, 10.0)
 */
 equals FVector2D(4.5, 6.5)
 */
UFUNCTION()
bool OpAddNominal()
{
	return OpAdd().Equals(FVector2D(4.5, 6.5));
}
/** @end */
/**
 * @begin vector-2-d-comparison-operators
 * @summary Compare two identical vectors for equality.
 * @topic Unreal
 */
/**
 * @function OpEquals_True
 * @summary Compare two identical vectors for equality.
 * @covers FVector2D.ComparisonOperators
 * @inputs none
 * @return true
 */
bool OpEquals_True()
{
	FVector2D a = FVector2D(1.5, 2.5);
	FVector2D b = FVector2D(1.5, 2.5);
	return a == b;
}
/** @end */
/**
 * @begin vector-2-d-construction
 * @summary Observe that the default constructor yields the zero vector.
 * @topic Unreal
 */
/**
 * @function DefaultNominal
 * @summary Observe that the default constructor yields the zero vector.
 * @covers FVector2D.Construction
 * @inputs none
 * @return true when the default equals the zero vector
 */
bool DefaultNominal()
{
	return ConstructDefault().Equals(FVector2D::ZeroVector);
}
/** @end */
/**
 * @begin vector-2-d-dot-product
 * @summary Observe that orthogonal vectors have a zero dot product.
 * @topic Unreal
 */
/**
 * @function DotProductOrthogonalNominal
 * @summary Observe that orthogonal vectors have a zero dot product.
 * @covers FVector2D.DotProduct
 * @inputs none
 * @return true when the dot product is 0
 */
bool DotProductOrthogonalNominal()
{
	return Math::IsNearlyEqual(DotProductOrthogonal(), 0.0);
}
/** @end */
/**
 * @begin vector-2-d-member-access
 * @summary Observe that reading X yields the expected value.
 * @topic Unreal
 */
/**
 * @function GetXNominal
 * @summary Observe that reading X yields the expected value.
 * @covers FVector2D.MemberAccess
 * @inputs none
 * @return true when X reads 10.5
 */
bool GetXNominal()
{
	return Math::IsNearlyEqual(GetX(), 10.5);
}
/** @end */
/**
 * @begin function-default-parameters
 * @summary A defaulted vector parameter, exercised both with and without the caller supplying it. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The.
 * @topic Unreal
 */
namespace FVector2DTest
{
	/**
	 * Add two vectors, where the second defaults to the unit vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionDefaultParameters
	 * @Inputs a vector and an optional second vector
	 * @Return the sum of the two
	 * @Param a the first vector
	 * @Param b the second vector, defaulting to the unit vector
	 */
	UFUNCTION()
	FVector2D AddWithDefault(FVector2D a, FVector2D b = FVector2D::UnitVector)
	{
		return a + b;
	}

	/**
	 * Add to a vector relying on the parameter default.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionDefaultParameters
	 * @Inputs a vector
	 * @Return the vector plus the unit vector
	 * @Param a the vector to add to
	 */
	UFUNCTION()
	FVector2D AddUsingDefault(FVector2D a)
	{
		return AddWithDefault(a);
	}

	/**
	 * Observe that an explicitly supplied second argument is used.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when the sum equals FVector2D(15, 30)
	 */
	UFUNCTION()
	bool AddWithDefaultExplicit()
	{
		return AddWithDefault(FVector2D(10, 20), FVector2D(5, 10)).Equals(FVector2D(15, 30));
	}

	/**
	 * Observe that the parameter default is applied when the caller omits it.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when the sum equals FVector2D(11, 21)
	 */
	UFUNCTION()
	bool AddUsingDefaultNominal()
	{
		return AddUsingDefault(FVector2D(10, 20)).Equals(FVector2D(11, 21));
	}

	/**
	 * Observe that adding an empty vector to the default yields the unit vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionDefaultParameters
	 * @Inputs a default-constructed vector
	 * @Return true when the sum equals the unit vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AddUsingDefaultEmptyZero()
	{
		return AddUsingDefault(FVector2D()).Equals(FVector2D::UnitVector);
	}

	/**
	 * Observe that mutating the returned sum leaves the caller's argument alone.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionDefaultParameters
	 * @Inputs a vector and the mutated sum built from it
	 * @Return true when the argument still reads FVector2D(10, 20)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AddUsingDefaultCopyIndependence()
	{
		FVector2D Arg1 = FVector2D(10, 20);
		FVector2D Result = AddUsingDefault(Arg1);
		Result.X = 0.0;
		return Arg1.Equals(FVector2D(10, 20));
	}
}
/** @end */
/**
 * @begin function-parameters-in
 * @summary A FVector2D passed by read-only reference, where the callee reads through the caller's value without taking a copy. C++ executes the entrypoint and checks the value it produces, so the name is part of the contract and is.
 * @topic Unreal
 */
namespace FVector2DTest
{
	/**
	 * Measure the length of a vector passed by read-only reference.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersIn
	 * @Inputs a vector
	 * @Return the length of the vector
	 * @Param v the vector to measure
	 */
	UFUNCTION()
	float AcceptVectorIn(FVector2D&in v)
	{
		return v.Size();
	}

	/**
	 * Observe that the measured length matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersIn
	 * @Inputs none
	 * @Return true when the length is 5
	 */
	UFUNCTION()
	bool AcceptVectorInNominal()
	{
		FVector2D Input = FVector2D(3, 4);
		return Math::IsNearlyEqual(AcceptVectorIn(Input), 5.0, 0.001);
	}

	/**
	 * Observe that an empty argument measures zero.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersIn
	 * @Inputs a default-constructed vector
	 * @Return true when the length is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptVectorInDefaultEmpty()
	{
		FVector2D Empty = FVector2D();
		return Math::IsNearlyEqual(AcceptVectorIn(Empty), 0.0, 0.001);
	}

	/**
	 * Observe that reading through the reference leaves the caller's vector alone.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersIn
	 * @Inputs a vector read through the reference
	 * @Return true when the argument still reads FVector2D(3, 4) and the size is 5
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AcceptVectorInCopyIndependence()
	{
		FVector2D Input = FVector2D(3, 4);
		float Size = AcceptVectorIn(Input);

		if (!Input.Equals(FVector2D(3, 4)))
		{
			return false;
		}
		return Math::IsNearlyEqual(Size, 5.0, 0.001);
	}
}
/** @end */
/**
 * @begin function-parameters-in-out
 * @summary A FVector2D passed by mutable reference and scaled in place. C++ executes the entrypoint and checks the value written back, so the name is part of the contract and is kept verbatim. The observers cover the empty argument.
 * @topic Unreal
 */
namespace FVector2DTest
{
	/**
	 * Scale a vector in place through a mutable reference.
	 *
	 * @Kind Action
	 * @Covers FVector2D.FunctionParametersInOut
	 * @Inputs a vector and a scale factor
	 * @Return the vector scaled in place
	 * @Param v the vector to scale
	 * @Param scale the factor to scale by
	 */
	UFUNCTION()
	void ScaleVector(FVector2D&inout v, float scale)
	{
		v = v * scale;
	}

	/**
	 * Observe that the caller's vector is scaled in place.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersInOut
	 * @Inputs none
	 * @Return true when the value reads FVector2D(30, 60)
	 */
	UFUNCTION()
	bool ScaleVectorNominal()
	{
		FVector2D Value = FVector2D(10, 20);
		ScaleVector(Value, 3.0);
		return Value.Equals(FVector2D(30, 60), 0.001);
	}

	/**
	 * Observe that scaling an empty vector stays at the origin.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersInOut
	 * @Inputs a default-constructed vector
	 * @Return true when the value still equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ScaleVectorDefaultEmpty()
	{
		FVector2D Empty = FVector2D();
		ScaleVector(Empty, 3.0);
		return Empty.Equals(FVector2D::ZeroVector, 0.001);
	}

	/**
	 * Observe that scaling one vector leaves a separate copy untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersInOut
	 * @Inputs a vector and a separate copy of it
	 * @Return true when the scaled one reads (30, 60) and the copy still reads (10, 20)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ScaleVectorCopyIndependence()
	{
		FVector2D Value = FVector2D(10, 20);
		FVector2D Other = Value;
		ScaleVector(Value, 3.0);

		if (!Value.Equals(FVector2D(30, 60), 0.001))
		{
			return false;
		}
		return Other.Equals(FVector2D(10, 20), 0.001);
	}
}
/** @end */
/**
 * @begin function-parameters-out
 * @summary FVector2Ds written through out parameters, where the callee fills in the caller's variable. C++ executes each entrypoint and checks the values written, so those names are part of the contract and are kept verbatim. The.
 * @topic Unreal
 */
namespace FVector2DTest
{
	/**
	 * Write a fixed vector into an out parameter.
	 *
	 * @Kind Action
	 * @Covers FVector2D.FunctionParametersOut
	 * @Inputs none
	 * @Return the out parameter filled with FVector2D(100, 200)
	 * @Param v the vector to write into
	 */
	UFUNCTION()
	void WriteVector(FVector2D&out v)
	{
		v = FVector2D(100, 200);
	}

	/**
	 * Write two axis vectors into two out parameters.
	 *
	 * @Kind Action
	 * @Covers FVector2D.FunctionParametersOut
	 * @Inputs none
	 * @Return the first out parameter as (1, 0), the second as (0, 1)
	 * @Param a the first vector to write into
	 * @Param b the second vector to write into
	 */
	UFUNCTION()
	void WriteMultipleVectors(FVector2D&out a, FVector2D&out b)
	{
		a = FVector2D(1, 0);
		b = FVector2D(0, 1);
	}

	/**
	 * Observe that the single out parameter receives the written value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the out value equals FVector2D(100, 200)
	 */
	UFUNCTION()
	bool WriteVectorNominal()
	{
		FVector2D OutValue;
		WriteVector(OutValue);
		return OutValue.Equals(FVector2D(100, 200));
	}

	/**
	 * Observe that both out parameters receive their own axis.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the first reads (1, 0) and the second (0, 1)
	 */
	UFUNCTION()
	bool WriteMultipleVectorsNominal()
	{
		FVector2D OutA;
		FVector2D OutB;
		WriteMultipleVectors(OutA, OutB);

		if (!OutA.Equals(FVector2D(1, 0)))
		{
			return false;
		}
		return OutB.Equals(FVector2D(0, 1));
	}

	/**
	 * Observe that an out parameter starts empty before it is written.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersOut
	 * @Inputs an uninitialised out value
	 * @Return true when it equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool WriteVectorDefaultEmpty()
	{
		FVector2D Empty;
		return Empty.Equals(FVector2D::ZeroVector);
	}

	/**
	 * Observe that mutating one out value leaves the other untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersOut
	 * @Inputs two out values, the first mutated afterwards
	 * @Return true when the second still reads (0, 1)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool WriteMultipleVectorsCopyIndependence()
	{
		FVector2D OutA;
		FVector2D OutB;
		WriteMultipleVectors(OutA, OutB);
		OutA.X = 0.0;
		return OutB.Equals(FVector2D(0, 1));
	}
}
/** @end */
/**
 * @begin function-parameters-value
 * @summary FVector2Ds passed by value, where the callee receives its own copy. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The observers cover the.
 * @topic Unreal
 */
namespace FVector2DTest
{
	/**
	 * Double every component of a vector passed by value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersValue
	 * @Inputs a vector
	 * @Return the vector with every component doubled
	 * @Param v the vector to scale
	 */
	UFUNCTION()
	FVector2D AcceptVector(FVector2D v)
	{
		return v * 2.0;
	}

	/**
	 * Measure the distance between two vectors passed by value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersValue
	 * @Inputs two vectors
	 * @Return the distance between them
	 * @Param a the first vector
	 * @Param b the second vector
	 */
	UFUNCTION()
	float AcceptTwoVectors(FVector2D a, FVector2D b)
	{
		return a.Distance(b);
	}

	/**
	 * Observe that the doubling matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersValue
	 * @Inputs none
	 * @Return true when the result equals FVector2D(10, 20)
	 */
	UFUNCTION()
	bool AcceptVectorNominal()
	{
		return AcceptVector(FVector2D(5, 10)).Equals(FVector2D(10, 20));
	}

	/**
	 * Observe that the distance matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersValue
	 * @Inputs none
	 * @Return true when the distance is 5
	 */
	UFUNCTION()
	bool AcceptTwoVectorsNominal()
	{
		return Math::IsNearlyEqual(AcceptTwoVectors(FVector2D(0, 0), FVector2D(3, 4)), 5.0, 0.001);
	}

	/**
	 * Observe that doubling an empty vector stays at the origin.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersValue
	 * @Inputs a default-constructed vector
	 * @Return true when the result equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptVectorDefaultEmpty()
	{
		return AcceptVector(FVector2D()).Equals(FVector2D::ZeroVector);
	}

	/**
	 * Observe that mutating the returned vector leaves the caller's argument alone.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionParametersValue
	 * @Inputs a vector and the mutated result of passing it in
	 * @Return true when the argument still reads FVector2D(5, 10)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AcceptVectorCopyIndependence()
	{
		FVector2D Input = FVector2D(5, 10);
		FVector2D Result = AcceptVector(Input);
		Result.X = 0.0;
		return Input.Equals(FVector2D(5, 10));
	}
}
/** @end */
/**
 * @begin function-return-values
 * @summary Vectors returned from functions: a constant, a literal and a computed sum. C++ executes each entrypoint and compares the result with the native equivalent, so those names are part of the contract and are kept verbatim.
 * @topic Unreal
 */
namespace FVector2DTest
{
	/**
	 * Return a vector constant.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionReturnValues
	 * @Inputs none
	 * @Return the zero vector
	 */
	UFUNCTION()
	FVector2D ReturnZeroVector()
	{
		return FVector2D::ZeroVector;
	}

	/**
	 * Return a literal vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionReturnValues
	 * @Inputs none
	 * @Return FVector2D(50, 75)
	 */
	UFUNCTION()
	FVector2D ReturnCustomVector()
	{
		return FVector2D(50, 75);
	}

	/**
	 * Return a vector computed from two others.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionReturnValues
	 * @Inputs none
	 * @Return FVector2D(15, 30)
	 */
	UFUNCTION()
	FVector2D ReturnComputedVector()
	{
		FVector2D a = FVector2D(10, 20);
		FVector2D b = FVector2D(5, 10);
		return a + b;
	}

	/**
	 * Observe that the constant return matches the zero vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals the zero vector
	 */
	UFUNCTION()
	bool ReturnZeroVectorNominal()
	{
		return ReturnZeroVector().Equals(FVector2D::ZeroVector);
	}

	/**
	 * Observe that the literal return matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals FVector2D(50, 75)
	 */
	UFUNCTION()
	bool ReturnCustomVectorNominal()
	{
		return ReturnCustomVector().Equals(FVector2D(50, 75));
	}

	/**
	 * Observe that the computed return matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals FVector2D(15, 30)
	 */
	UFUNCTION()
	bool ReturnComputedVectorNominal()
	{
		return ReturnComputedVector().Equals(FVector2D(15, 30));
	}

	/**
	 * Observe that an empty vector equals the zero vector.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionReturnValues
	 * @Inputs a default-constructed vector
	 * @Return true when it equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ReturnZeroVectorDefaultEmpty()
	{
		FVector2D Empty = FVector2D();
		return Empty.Equals(FVector2D::ZeroVector);
	}

	/**
	 * Observe that mutating a copy leaves the returned vector untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector2D.FunctionReturnValues
	 * @Inputs the returned vector and a mutated copy of it
	 * @Return true when the returned one still reads (50, 75) and the copy reads 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ReturnCustomVectorCopyIndependence()
	{
		FVector2D Original = ReturnCustomVector();
		FVector2D Copy = Original;
		Copy.X = 0.0;

		if (!Original.Equals(FVector2D(50, 75)))
		{
			return false;
		}
		return Copy.X == 0.0;
	}
}
/** @end */
