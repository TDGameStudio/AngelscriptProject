/**
 * @version v1
 * @summary FVector2f host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FVector2f
 *
 * expected-observations
 * fvector2f-constructors-copy-fvector3f
 * surface-007
 * surface-008
 * cross-product
 * dot-product
 * size
 * size-squared
 * normalize
 * distance
 * dist-squared
 * init-from-string
 * assignment
 * multiply-assign
 * divide-assign
 * add-assign
 * subtract-assign
 * to-direction-and-length
 * inputs-each-published-constant
 * container-api
 * index
 * equality
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
 */
/**
 * @begin expected-observations
 * @summary Expected observations:
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Expected observations:
 * @covers FVector2f.expected-observations
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 Default is (0,0). Copy preserves (3,4). FVector3f
// conversion keeps XY and drops 9. FVector2D conversion keeps 5/6. Cross of
// (1,0) and (0,1) is 1. Dot of those is 0.
// Boundary/ownership: Components are float32. FVector3f conversion discards
// Z. Constructors copy values.
// FVector2f Value; default construction is (0,0). Declaration, no fixture.
bool ObserveSurface001Nominal()
{
	FVector2f Value;
	return Value.X == 0.0f && Value.Y == 0.0f;
}
/** @end */
/**
 * @begin fvector2f-constructors-copy-fvector3f
 * @summary FVector2f constructors: copy, FVector3f (drops Z), FVector2D.
 * @topic Unreal
 */
/**
 * @function ObserveValueNominal
 * @summary FVector2f constructors: copy, FVector3f (drops Z), FVector2D.
 * @covers FVector2f.fvector2f-constructors-copy-fvector3f
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveValueNominal()
{
	FVector2f Explicit(3.0f, 4.0f);
	FVector2f Zero;
	FVector2f Copied(Explicit);
	FVector2f From3(FVector3f(7.0f, 8.0f, 9.0f));
	FVector2f FromDouble(FVector2D(5, 6));
	return Explicit.Y == 4.0f &&
		Zero.IsZero() &&
		Copied.X == 3.0f &&
		From3.X == 7.0f &&
		From3.Y == 8.0f &&
		FromDouble.X == 5.0f &&
		FromDouble.Y == 6.0f;
}
/** @end */
/**
 * @begin surface-007
 * @summary FVector2f.
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary FVector2f.
 * @covers FVector2f.surface-007
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

X of (3,4) is 3. Field read, no mutation.
bool ObserveSurface007Nominal()
{
	return FVector2f(3.0f, 4.0f).X == 3.0f;
}
/** @end */
/**
 * @begin surface-008
 * @summary FVector2f.
 * @topic Unreal
 */
/**
 * @function ObserveSurface008Nominal
 * @summary FVector2f.
 * @covers FVector2f.surface-008
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

Y of (3,4) is 4. Field read, no mutation.
bool ObserveSurface008Nominal()
{
	return FVector2f(3.0f, 4.0f).Y == 4.0f;
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
 * @covers FVector2f.cross-product
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveCrossProductNominal()
{
	float32 Cross = FVector2f(1.0f, 0.0f).CrossProduct(FVector2f(0.0f, 1.0f));
	float32 Reverse = FVector2f(0.0f, 1.0f).CrossProduct(FVector2f(1.0f, 0.0f));
	return Cross == 1.0f && Reverse == -1.0f;
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
 * @covers FVector2f.dot-product
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveDotProductNominal()
{
	float32 Orthogonal = FVector2f(1.0f, 0.0f).DotProduct(FVector2f(0.0f, 1.0f));
	float32 Aligned = FVector2f(1.0f, 0.0f).DotProduct(FVector2f(1.0f, 0.0f));
	return Orthogonal == 0.0f && Aligned == 1.0f;
}
/** @end */
/**
 * @begin size
 * @summary Expected observations:
 * @topic Unreal
 */
/**
 * @function ObserveSizeNominal
 * @summary Expected observations:
 * @covers FVector2f.size
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 Size of (3,4) is 5. SizeSquared is 25. Normalize of
// (3,0) yields (1,0). Normalize of zero yields zero. Distance is 5.
// DistSquared is 25. InitFromString true parses (1,2); empty returns false.
// Boundary/ownership: Normalize is void and mutates. InitFromString mutates.
// Components are float32.
bool ObserveSizeNominal()
{
	return FVector2f(3.0f, 4.0f).Size() == 5.0f && FVector2f(0.0f, 0.0f).Size() == 0.0f;
}
/** @end */
/**
 * @begin size-squared
 * @summary Components are float32.
 * @topic Unreal
 */
/**
 * @function ObserveSizeSquaredNominal
 * @summary Components are float32.
 * @covers FVector2f.size-squared
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveSizeSquaredNominal()
{
	return FVector2f(3.0f, 4.0f).SizeSquared() == 25.0f && FVector2f(0.0f, 0.0f).SizeSquared() == 0.0f;
}
/** @end */
/**
 * @begin normalize
 * @summary Components are float32.
 * @topic Unreal
 */
/**
 * @function ObserveNormalizeNominal
 * @summary Components are float32.
 * @covers FVector2f.normalize
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveNormalizeNominal()
{
	FVector2f Vector(3.0f, 0.0f);
	Vector.Normalize();
	FVector2f Zero;
	Zero.Normalize();
	return Vector.Equals(FVector2f(1.0f, 0.0f)) && Zero.IsZero();
}
/** @end */
/**
 * @begin distance
 * @summary Components are float32.
 * @topic Unreal
 */
/**
 * @function ObserveDistanceNominal
 * @summary Components are float32.
 * @covers FVector2f.distance
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveDistanceNominal()
{
	return FVector2f(0.0f, 0.0f).Distance(FVector2f(3.0f, 4.0f)) == 5.0f &&
		FVector2f(1.0f, 1.0f).Distance(FVector2f(1.0f, 1.0f)) == 0.0f;
}
/** @end */
/**
 * @begin dist-squared
 * @summary Components are float32.
 * @topic Unreal
 */
/**
 * @function ObserveDistSquaredNominal
 * @summary Components are float32.
 * @covers FVector2f.dist-squared
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveDistSquaredNominal()
{
	return FVector2f(0.0f, 0.0f).DistSquared(FVector2f(3.0f, 4.0f)) == 25.0f;
}
/** @end */
/**
 * @begin init-from-string
 * @summary Components are float32.
 * @topic Unreal
 */
/**
 * @function ObserveInitFromStringNominal
 * @summary Components are float32.
 * @covers FVector2f.init-from-string
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveInitFromStringNominal()
{
	FVector2f Parsed;
	bool bValid = Parsed.InitFromString("X=1 Y=2");
	FVector2f EmptyTarget(9.0f, 9.0f);
	bool bEmpty = EmptyTarget.InitFromString("");
	return bValid && Parsed.Equals(FVector2f(1.0f, 2.0f)) && !bEmpty;
}
/** @end */
/**
 * @begin assignment
 * @summary + is (3,5).
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary + is (3,5).
 * @covers FVector2f.assignment
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// + is (3,5). Component * is (2,8). *

 2 is (4,8). / 2 is (1,2). Negation
// flips signs. Original Vector is unchanged by value-returning operators.
// Boundary/ownership: Components are float32. Compound mutation is not used
// here. Assignment does not alias Other.
bool ObserveAssignmentNominal()
{
	FVector2f Vector(2.0f, 4.0f);
	FVector2f Other(1.0f, 1.0f);
	Vector = Other;
	Vector.X = 9.0f;
	FVector2f Source(2.0f, 4.0f);
	FVector2f Sum = Source + Other;
	FVector2f BiasedSum = Source + 1.0f;
	FVector2f Difference = Source - Other;
	FVector2f BiasedDifference = Source - 1.0f;
	FVector2f ComponentProduct = Source * FVector2f(1.0f, 2.0f);
	FVector2f Scaled = Source * 2.0f;
	FVector2f ComponentQuotient = Source / FVector2f(2.0f, 2.0f);
	FVector2f Quotient = Source / 2.0f;
	FVector2f Negated = -Source;
	return Vector.X == 9.0f &&
		Other.X == 1.0f &&
		Sum.X == 3.0f &&
		BiasedSum.Y == 5.0f &&
		Difference.X == 1.0f &&
		BiasedDifference.Y == 3.0f &&
		ComponentProduct.Y == 8.0f &&
		Scaled.X == 4.0f &&
		ComponentQuotient.X == 1.0f &&
		Quotient.Y == 2.0f &&
		Negated.X == -2.0f &&
		Source.X == 2.0f;
}
/** @end */
/**
 * @begin multiply-assign
 * @summary float32.
 * @topic Unreal
 */
/**
 * @function ObserveMultiplyAssignNominal
 * @summary float32.
 * @covers FVector2f.multiply-assign
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMultiplyAssignNominal()
{
	FVector2f Vector(2.0f, 4.0f);
	Vector *= 2.0f;
	bool bScale = Vector.X == 4.0f && Vector.Y == 8.0f;
	Vector *= FVector2f(0.5f, 0.5f);
	return bScale && Vector.X == 2.0f && Vector.Y == 4.0f;
}
/** @end */
/**
 * @begin divide-assign
 * @summary float32.
 * @topic Unreal
 */
/**
 * @function ObserveDivideAssignNominal
 * @summary float32.
 * @covers FVector2f.divide-assign
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDivideAssignNominal()
{
	FVector2f Vector(2.0f, 4.0f);
	Vector /= 2.0f;
	bool bScale = Vector.X == 1.0f && Vector.Y == 2.0f;
	FVector2f Other(2.0f, 4.0f);
	Other /= FVector2f(1.0f, 2.0f);
	return bScale && Other.X == 2.0f && Other.Y == 2.0f;
}
/** @end */
/**
 * @begin add-assign
 * @summary float32.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary float32.
 * @covers FVector2f.add-assign
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal()
{
	FVector2f Vector(2.0f, 4.0f);
	FVector2f Other(1.0f, 1.0f);
	Vector += Other;
	return Vector.X == 3.0f && Vector.Y == 5.0f && Other.X == 1.0f;
}
/** @end */
/**
 * @begin subtract-assign
 * @summary float32.
 * @topic Unreal
 */
/**
 * @function ObserveSubtractAssignNominal
 * @summary float32.
 * @covers FVector2f.subtract-assign
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSubtractAssignNominal()
{
	FVector2f Vector(2.0f, 4.0f);
	Vector -= FVector2f(1.0f, 1.0f);
	return Vector.X == 1.0f && Vector.Y == 3.0f;
}
/** @end */
/**
 * @begin to-direction-and-length
 * @summary produce a zero direction rather than an exception.
 * @topic Unreal
 */
/**
 * @function ObserveToDirectionAndLengthNominal
 * @summary produce a zero direction rather than an exception.
 * @covers FVector2f.to-direction-and-length
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveToDirectionAndLengthNominal()
{
	FVector2f Source(3.0f, 4.0f);
	FVector2f Dir;
	float32 Length = -1.0f;
	Source.ToDirectionAndLength(Dir, Length);
	FVector2f ZeroDir = FVector2f::UnitVector;
	float32 ZeroLength = -1.0f;
	FVector2f::ZeroVector.ToDirectionAndLength(ZeroDir, ZeroLength);
	return Dir.Equals(FVector2f(0.6f, 0.8f)) && Length == 5.0f && ZeroDir.IsZero() && ZeroLength == 0.0f && Source.X == 3.0f;
}
/** @end */
/**
 * @begin inputs-each-published-constant
 * @summary Inputs: Each published constant
 * @topic Unreal
 */
/**
 * @function ObserveSurface048Nominal
 * @summary Inputs: Each published constant
 * @covers FVector2f.inputs-each-published-constant
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Each published constant

 compared against (0,0) and (1,1).
// Expected observations: ZeroVector is (0,0). UnitVector is (1,1).
// Boundary/ownership: Constants are shared values, not factory functions.
// FVector2f::ZeroVector is (0,0). Shared constant, not a factory.
bool ObserveSurface048Nominal()
{
	return FVector2f::ZeroVector.X == 0.0f && FVector2f::ZeroVector.Y == 0.0f;
}
/** @end */
/**
 * @begin container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface049Nominal
 * @summary Observe the container API.
 * @covers FVector2f.container-api
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Each published constant

 FVector2f::UnitVector is (1,1). Shared constant, not a factory.
bool ObserveSurface049Nominal()
{
	return FVector2f::UnitVector.X == 1.0f && FVector2f::UnitVector.Y == 1.0f;
}
/** @end */
/**
 * @begin index
 * @summary Boundary/ownership: Index 0/1 are X/Y.
 * @topic Unreal
 */
/**
 * @function ObserveIndexNominal
 * @summary Boundary/ownership: Index 0/1 are X/Y.
 * @covers FVector2f.index
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIndexNominal()
{
	FVector2f Vector(2.0f, 4.0f);
	float32 X = Vector[0];
	Vector[1] = 9.0f;
	float32 Y = Vector[1];
	return X == 2.0f && Y == 9.0f && Vector.Y == 9.0f;
}
/** @end */
/**
 * @begin equality
 * @summary Boundary/ownership: Index 0/1 are X/Y.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary Boundary/ownership: Index 0/1 are X/Y.
 * @covers FVector2f.equality
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FVector2f Left(2.0f, 4.0f);
	FVector2f Right(2.0f, 4.0f);
	FVector2f Different(2.0f, 5.0f);
	return (Left == Right) && !(Left == Different);
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
 * @covers FVector2f.equals
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 GetMax of (2,-8) is 2. GetAbsMax is 8. GetMin is
// -8. GetAbs is (2,8). Tiny is nearly zero. (3,4) safe-normal is (0.6,0.8).
// Finite is not NaN. Sign of (1,-2) is (1,-1).
// Boundary/ownership: Equals uses __KINDA_SMALL_NUMBER_flt. GetSafeNormal
// uses __SMALL_NUMBER_flt. Queries do not mutate.
bool ObserveEqualsNominal()
{
	FVector2f Left(1.0f, 2.0f);
	FVector2f Right(1.0f, 2.0f);
	FVector2f Perturbed(1.0f + __KINDA_SMALL_NUMBER_flt * 0.5f, 2.0f);
	FVector2f Far(2.0f, 2.0f);
	return Left.Equals(Right) && Left.Equals(Perturbed) && !Left.Equals(Far, 0.0f);
}
/** @end */
/**
 * @begin get-max
 * @summary uses __SMALL_NUMBER_flt.
 * @topic Unreal
 */
/**
 * @function ObserveGetMaxNominal
 * @summary uses __SMALL_NUMBER_flt.
 * @covers FVector2f.get-max
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetMaxNominal()
{
	return FVector2f(2.0f, -8.0f).GetMax() == 2.0f && FVector2f(0.0f, 0.0f).GetMax() == 0.0f;
}
/** @end */
/**
 * @begin get-abs-max
 * @summary uses __SMALL_NUMBER_flt.
 * @topic Unreal
 */
/**
 * @function ObserveGetAbsMaxNominal
 * @summary uses __SMALL_NUMBER_flt.
 * @covers FVector2f.get-abs-max
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetAbsMaxNominal()
{
	return FVector2f(2.0f, -8.0f).GetAbsMax() == 8.0f && FVector2f(0.0f, 0.0f).GetAbsMax() == 0.0f;
}
/** @end */
/**
 * @begin get-min
 * @summary uses __SMALL_NUMBER_flt.
 * @topic Unreal
 */
/**
 * @function ObserveGetMinNominal
 * @summary uses __SMALL_NUMBER_flt.
 * @covers FVector2f.get-min
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetMinNominal()
{
	return FVector2f(2.0f, -8.0f).GetMin() == -8.0f && FVector2f(0.0f, 0.0f).GetMin() == 0.0f;
}
/** @end */
/**
 * @begin get-abs
 * @summary uses __SMALL_NUMBER_flt.
 * @topic Unreal
 */
/**
 * @function ObserveGetAbsNominal
 * @summary uses __SMALL_NUMBER_flt.
 * @covers FVector2f.get-abs
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetAbsNominal()
{
	FVector2f Abs = FVector2f(-1.0f, 2.0f).GetAbs();
	return Abs.X == 1.0f && Abs.Y == 2.0f;
}
/** @end */
/**
 * @begin is-nearly-zero
 * @summary uses __SMALL_NUMBER_flt.
 * @topic Unreal
 */
/**
 * @function ObserveIsNearlyZeroNominal
 * @summary uses __SMALL_NUMBER_flt.
 * @covers FVector2f.is-nearly-zero
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveIsNearlyZeroNominal()
{
	FVector2f Tiny(__KINDA_SMALL_NUMBER_flt * 0.5f, 0.0f);
	return FVector2f(0.0f, 0.0f).IsNearlyZero() && Tiny.IsNearlyZero() && !FVector2f(1.0f, 0.0f).IsNearlyZero();
}
/** @end */
/**
 * @begin is-zero
 * @summary uses __SMALL_NUMBER_flt.
 * @topic Unreal
 */
/**
 * @function ObserveIsZeroNominal
 * @summary uses __SMALL_NUMBER_flt.
 * @covers FVector2f.is-zero
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveIsZeroNominal()
{
	return FVector2f(0.0f, 0.0f).IsZero() && !FVector2f(0.0f, 1.0f).IsZero();
}
/** @end */
/**
 * @begin get-safe-normal
 * @summary uses __SMALL_NUMBER_flt.
 * @topic Unreal
 */
/**
 * @function ObserveGetSafeNormalNominal
 * @summary uses __SMALL_NUMBER_flt.
 * @covers FVector2f.get-safe-normal
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetSafeNormalNominal()
{
	FVector2f Unit = FVector2f(3.0f, 4.0f).GetSafeNormal();
	FVector2f Zero = FVector2f(0.0f, 0.0f).GetSafeNormal();
	return Unit.Equals(FVector2f(0.6f, 0.8f)) && Zero.IsZero();
}
/** @end */
/**
 * @begin contains-na-n
 * @summary uses __SMALL_NUMBER_flt.
 * @topic Unreal
 */
/**
 * @function ObserveContainsNaNNominal
 * @summary uses __SMALL_NUMBER_flt.
 * @covers FVector2f.contains-na-n
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveContainsNaNNominal()
{
	float32 Zero = 0.0f;
	FVector2f NonFinite(Zero / Zero, 0.0f);
	return !FVector2f(1.0f, 2.0f).ContainsNaN() && NonFinite.ContainsNaN();
}
/** @end */
/**
 * @begin get-sign-vector
 * @summary uses __SMALL_NUMBER_flt.
 * @topic Unreal
 */
/**
 * @function ObserveGetSignVectorNominal
 * @summary uses __SMALL_NUMBER_flt.
 * @covers FVector2f.get-sign-vector
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetSignVectorNominal()
{
	FVector2f Signs = FVector2f(1.0f, -2.0f).GetSignVector();
	return Signs.X == 1.0f && Signs.Y == -1.0f;
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
 * @covers FVector2f.get-clamped-to-max-size
 * @inputs FVector2f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetClampedToMaxSizeNominal()
{
	FVector2f Long = FVector2f(10.0f, 0.0f).GetClampedToMaxSize(5.0f);
	FVector2f Short = FVector2f(1.0f, 0.0f).GetClampedToMaxSize(5.0f);
	FVector2f Zero = FVector2f(0.0f, 0.0f).GetClampedToMaxSize(5.0f);
	return Long.Equals(FVector2f(5.0f, 0.0f)) && Short.Equals(FVector2f(1.0f, 0.0f)) && Zero.IsZero();
}
/** @end */
