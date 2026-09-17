/**
 * @version v1
 * @summary FVector host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FVector
 *
 * expected-observations
 * vector
 * surface-008
 * surface-009
 * surface-010
 * surface-018
 * cross-product
 * dot-product
 * all-components-equal
 * parallel
 * coincident
 * orthogonal
 * component-min
 * component-max
 * component-clamp
 * size
 * size-squared
 * size-2-d
 * size-squared-2-d
 * normalize
 * projection
 * grid-snap
 * bound-to-cube
 * bound-to-box
 * reciprocal
 * mirror-by-vector
 * vector-plane-project
 * rotate-angle-axis
 * cosine-angle-2-d
 * project-on-to
 * project-on-to-normal
 * unwind-euler
 * heading-angle
 * points-are-same
 * points-are-near
 * distance
 * dist-squared
 * dist-2-d
 * dist-xy
 * dist-squared-xy
 * dist-squared-2-d
 * rotation
 * init-from-string
 * struct-fvector
 * assignment
 * multiply-assign
 * divide-assign
 * add-assign
 * subtract-assign
 * to-direction-and-length
 * to-orientation-rotator
 * to-orientation-quat
 * to-string
 * add-bounded
 * append
 * FVector-NamespaceAndGlobalFunctions_01-expected-observations
 * container-api
 * FVector-NamespaceAndGlobalFunctions_01-container-api
 * container-api-2
 * container-api-3
 * container-api-4
 * container-api-5
 * container-api-6
 * addition
 * subtraction
 * vector-other-per-component
 * FVector-Operators_01-vector-other-per-component
 * vector-scale-2-4
 * FVector-Operators_01-vector-scale-2-4
 * index
 * equality
 * equals
 * get-max
 * get-abs-max
 * get-min
 * get-abs-min
 * get-abs
 * is-nearly-zero
 * is-zero
 * is-normalized
 * get-sign-vector
 * get-unsafe-normal
 * get-clamped-to-size
 * get-clamped-to-size-2-d
 * get-clamped-to-max-size
 * get-clamped-to-max-size-2-d
 * is-uniform
 * get-safe-normal
 * get-safe-normal-2-d
 * find-best-axis-vectors
 * contains-na-n
 * is-unit
 * arithmetic-operators
 * comparison-operators
 * construction
 * declarations-and-index-access
 * dot-and-cross
 * extended-operators-and-methods
 * member-access
 * methods
 * default-f-vector-property-applied
 * container-properties
 * declaration-defaults
 * script-member-and-local-usage
 * write-round-trip
 * vector-4-int-point-int-vector-expressions
 * function-default-parameters
 * function-parameters-in
 * function-parameters-in-out
 * function-parameters-out
 * function-parameters-value
 * function-return-values

 */
/**
 * @begin expected-observations
 * @summary Expected observations:
 * @topic Unreal
 */
/**
 * @function ObserveSurface002Nominal
 * @summary Expected observations:
 * @covers FVector.expected-observations
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 Default is (0,0,0). Uniform 7 fills all axes. Copy
// preserves (1,2,3). FVector3f conversion keeps 4/5/6. Fields match. Negation
// flips signs. Net-quantize properties are observed as FVector values.
// Boundary/ownership: Constructors copy values. FVector_NetQuantize* reflected
// properties route to FVector rather than a distinct script type.
// FVector_NetQuantize publishes as FVector: (1,2,3) stores XYZ. Value copy, no fixture.
bool ObserveSurface002Nominal()
{
	FVector Quantized(1, 2, 3);
	return Quantized.X == 1.0 && Quantized.Y == 2.0 && Quantized.Z == 3.0;
}
/** @end */
/**
 * @begin vector
 * @summary FVector(X,Y,Z), default, uniform, copy, FVector3f: default is zero.
 * @topic Unreal
 */
/**
 * @function ObserveVectorNominal
 * @summary FVector(X,Y,Z), default, uniform, copy, FVector3f: default is zero.
 * @covers FVector.vector
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveVectorNominal()
{
	FVector Explicit(1, 2, 3);
	FVector Zero;
	FVector Uniform(7);
	FVector Copied(Explicit);
	FVector FromFloat(FVector3f(4, 5, 6));
	return Explicit.Z == 3.0 &&
		Zero.IsZero() &&
		Uniform.Y == 7.0 &&
		Copied.X == 1.0 &&
		FromFloat.X == 4.0 &&
		FromFloat.Z == 6.0;
}
/** @end */
/**
 * @begin surface-008
 * @summary FVector.
 * @topic Unreal
 */
/**
 * @function ObserveSurface008Nominal
 * @summary FVector.
 * @covers FVector.surface-008
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

X of (1,2,3) is 1. Field read, no mutation.
bool ObserveSurface008Nominal()
{
	return FVector(1, 2, 3).X == 1.0;
}
/** @end */
/**
 * @begin surface-009
 * @summary FVector.
 * @topic Unreal
 */
/**
 * @function ObserveSurface009Nominal
 * @summary FVector.
 * @covers FVector.surface-009
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

Y of (1,2,3) is 2. Field read, no mutation.
bool ObserveSurface009Nominal()
{
	return FVector(1, 2, 3).Y == 2.0;
}
/** @end */
/**
 * @begin surface-010
 * @summary FVector.
 * @topic Unreal
 */
/**
 * @function ObserveSurface010Nominal
 * @summary FVector.
 * @covers FVector.surface-010
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

Z of (1,2,3) is 3. Field read, no mutation.
bool ObserveSurface010Nominal()
{
	return FVector(1, 2, 3).Z == 3.0;
}
/** @end */
/**
 * @begin surface-018
 * @summary Unary
 * @topic Unreal
 */
/**
 * @function ObserveSurface018Nominal
 * @summary Unary
 * @covers FVector.surface-018
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 minus of (1,2,3) is (-1,-2,-3). Returns a new vector.
bool ObserveSurface018Nominal()
{
	FVector Negated = -FVector(1, 2, 3);
	return Negated.X == -1.0 && Negated.Y == -2.0 && Negated.Z == -3.0;
}
/** @end */
/**
 * @begin cross-product
 * @summary Results are new values.
 * @topic Unreal
 */
/**
 * @function ObserveCrossProductNominal
 * @summary Results are new values.
 * @covers FVector.cross-product
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCrossProductNominal()
{
	FVector Cross = FVector(1, 0, 0).CrossProduct(FVector(0, 1, 0));
	return Cross.Equals(FVector(0, 0, 1));
}
/** @end */
/**
 * @begin dot-product
 * @summary Results are new values.
 * @topic Unreal
 */
/**
 * @function ObserveDotProductNominal
 * @summary Results are new values.
 * @covers FVector.dot-product
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDotProductNominal()
{
	float64 Orthogonal = FVector(1, 0, 0).DotProduct(FVector(0, 1, 0));
	float64 Aligned = FVector(1, 0, 0).DotProduct(FVector(1, 0, 0));
	return Orthogonal == 0.0 && Aligned == 1.0;
}
/** @end */
/**
 * @begin all-components-equal
 * @summary Results are new values.
 * @topic Unreal
 */
/**
 * @function ObserveAllComponentsEqualNominal
 * @summary Results are new values.
 * @covers FVector.all-components-equal
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAllComponentsEqualNominal()
{
	return FVector(1, 1, 1).AllComponentsEqual() && !FVector(1, 2, 1).AllComponentsEqual();
}
/** @end */
/**
 * @begin parallel
 * @summary Results are new values.
 * @topic Unreal
 */
/**
 * @function ObserveParallelNominal
 * @summary Results are new values.
 * @covers FVector.parallel
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveParallelNominal()
{
	return FVector::ForwardVector.Parallel(FVector::ForwardVector) &&
		FVector::ForwardVector.Parallel(FVector::BackwardVector) &&
		!FVector::ForwardVector.Parallel(FVector::RightVector);
}
/** @end */
/**
 * @begin coincident
 * @summary Results are new values.
 * @topic Unreal
 */
/**
 * @function ObserveCoincidentNominal
 * @summary Results are new values.
 * @covers FVector.coincident
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCoincidentNominal()
{
	return FVector::ForwardVector.Coincident(FVector::ForwardVector) &&
		!FVector::ForwardVector.Coincident(FVector::BackwardVector);
}
/** @end */
/**
 * @begin orthogonal
 * @summary Results are new values.
 * @topic Unreal
 */
/**
 * @function ObserveOrthogonalNominal
 * @summary Results are new values.
 * @covers FVector.orthogonal
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveOrthogonalNominal()
{
	return FVector::ForwardVector.Orthogonal(FVector::RightVector) &&
		!FVector::ForwardVector.Orthogonal(FVector::ForwardVector);
}
/** @end */
/**
 * @begin component-min
 * @summary Results are new values.
 * @topic Unreal
 */
/**
 * @function ObserveComponentMinNominal
 * @summary Results are new values.
 * @covers FVector.component-min
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveComponentMinNominal()
{
	FVector Min = FVector(2, 0, -1).ComponentMin(FVector(1, 1, 1));
	return Min.Equals(FVector(1, 0, -1));
}
/** @end */
/**
 * @begin component-max
 * @summary Results are new values.
 * @topic Unreal
 */
/**
 * @function ObserveComponentMaxNominal
 * @summary Results are new values.
 * @covers FVector.component-max
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveComponentMaxNominal()
{
	FVector Max = FVector(2, 0, -1).ComponentMax(FVector(1, 1, 1));
	return Max.Equals(FVector(2, 1, 1));
}
/** @end */
/**
 * @begin component-clamp
 * @summary Results are new values.
 * @topic Unreal
 */
/**
 * @function ObserveComponentClampNominal
 * @summary Results are new values.
 * @covers FVector.component-clamp
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveComponentClampNominal()
{
	FVector Clamped = FVector(2, 0, -1).ComponentClamp(FVector(0, 0, 0), FVector(1, 1, 1));
	return Clamped.Equals(FVector(1, 0, 0));
}
/** @end */
/**
 * @begin size
 * @summary Results are new values.
 * @topic Unreal
 */
/**
 * @function ObserveSizeNominal
 * @summary Results are new values.
 * @covers FVector.size
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSizeNominal()
{
	return FVector(3, 4, 0).Size() == 5.0 && FVector(0, 0, 0).Size() == 0.0;
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
 * @covers FVector.size-squared
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 SizeSquared of (3,4,12) is 169. Size2D of (3,4,12)
// is 5. Normalize of (3,0,0) yields unit X and true; zero stays zero and
// false. Projection of (2,4,2) is (1,2,1). GridSnap rounds to integers.
// Cube/box clamp components. Reciprocal of 2 is 0.5; zero uses BIG_NUMBER.
// Mirror of (1,1,0) across X is (-1,1,0).
// Boundary/ownership: Normalize mutates. Other helpers return copies.
// Reciprocal of zero is BIG_NUMBER, not an exception.
bool ObserveSizeSquaredNominal()
{
	return FVector(3, 4, 12).SizeSquared() == 169.0 && FVector(0, 0, 0).SizeSquared() == 0.0;
}
/** @end */
/**
 * @begin size-2-d
 * @summary Reciprocal of zero is BIG_NUMBER, not an exception.
 * @topic Unreal
 */
/**
 * @function ObserveSize2DNominal
 * @summary Reciprocal of zero is BIG_NUMBER, not an exception.
 * @covers FVector.size-2-d
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveSize2DNominal()
{
	return FVector(3, 4, 12).Size2D() == 5.0 && FVector(0, 0, 9).Size2D() == 0.0;
}
/** @end */
/**
 * @begin size-squared-2-d
 * @summary Reciprocal of zero is BIG_NUMBER, not an exception.
 * @topic Unreal
 */
/**
 * @function ObserveSizeSquared2DNominal
 * @summary Reciprocal of zero is BIG_NUMBER, not an exception.
 * @covers FVector.size-squared-2-d
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveSizeSquared2DNominal()
{
	return FVector(3, 4, 12).SizeSquared2D() == 25.0 && FVector(0, 0, 9).SizeSquared2D() == 0.0;
}
/** @end */
/**
 * @begin normalize
 * @summary Reciprocal of zero is BIG_NUMBER, not an exception.
 * @topic Unreal
 */
/**
 * @function ObserveNormalizeNominal
 * @summary Reciprocal of zero is BIG_NUMBER, not an exception.
 * @covers FVector.normalize
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveNormalizeNominal()
{
	FVector Vector(3, 0, 0);
	bool bNormalized = Vector.Normalize();
	FVector Zero;
	bool bZeroFailed = Zero.Normalize();
	return bNormalized && Vector.Equals(FVector(1, 0, 0)) && !bZeroFailed && Zero.IsZero();
}
/** @end */
/**
 * @begin projection
 * @summary Reciprocal of zero is BIG_NUMBER, not an exception.
 * @topic Unreal
 */
/**
 * @function ObserveProjectionNominal
 * @summary Reciprocal of zero is BIG_NUMBER, not an exception.
 * @covers FVector.projection
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveProjectionNominal()
{
	FVector Projected = FVector(2, 4, 2).Projection();
	return Projected.Equals(FVector(1, 2, 1));
}
/** @end */
/**
 * @begin grid-snap
 * @summary Reciprocal of zero is BIG_NUMBER, not an exception.
 * @topic Unreal
 */
/**
 * @function ObserveGridSnapNominal
 * @summary Reciprocal of zero is BIG_NUMBER, not an exception.
 * @covers FVector.grid-snap
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGridSnapNominal()
{
	FVector Snapped = FVector(1.2, 2.7, -1.4).GridSnap(1.0);
	return Snapped.Equals(FVector(1, 3, -1));
}
/** @end */
/**
 * @begin bound-to-cube
 * @summary Reciprocal of zero is BIG_NUMBER, not an exception.
 * @topic Unreal
 */
/**
 * @function ObserveBoundToCubeNominal
 * @summary Reciprocal of zero is BIG_NUMBER, not an exception.
 * @covers FVector.bound-to-cube
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveBoundToCubeNominal()
{
	FVector Cubed = FVector(10, 0, -20).BoundToCube(5.0);
	return Cubed.Equals(FVector(5, 0, -5));
}
/** @end */
/**
 * @begin bound-to-box
 * @summary Reciprocal of zero is BIG_NUMBER, not an exception.
 * @topic Unreal
 */
/**
 * @function ObserveBoundToBoxNominal
 * @summary Reciprocal of zero is BIG_NUMBER, not an exception.
 * @covers FVector.bound-to-box
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveBoundToBoxNominal()
{
	FVector Boxed = FVector(2, -1, 0.5).BoundToBox(FVector(0, 0, 0), FVector(1, 1, 1));
	return Boxed.Equals(FVector(1, 0, 0.5));
}
/** @end */
/**
 * @begin reciprocal
 * @summary Reciprocal of zero is BIG_NUMBER, not an exception.
 * @topic Unreal
 */
/**
 * @function ObserveReciprocalNominal
 * @summary Reciprocal of zero is BIG_NUMBER, not an exception.
 * @covers FVector.reciprocal
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveReciprocalNominal()
{
	FVector Reciprocal = FVector(2, 4, 0).Reciprocal();
	return Reciprocal.X == 0.5 && Reciprocal.Y == 0.25 && Reciprocal.Z == BIG_NUMBER;
}
/** @end */
/**
 * @begin mirror-by-vector
 * @summary Reciprocal of zero is BIG_NUMBER, not an exception.
 * @topic Unreal
 */
/**
 * @function ObserveMirrorByVectorNominal
 * @summary Reciprocal of zero is BIG_NUMBER, not an exception.
 * @covers FVector.mirror-by-vector
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveMirrorByVectorNominal()
{
	FVector Mirrored = FVector(1, 1, 0).MirrorByVector(FVector(1, 0, 0));
	return Mirrored.Equals(FVector(-1, 1, 0));
}
/** @end */
/**
 * @begin vector-plane-project
 * @summary returns a new vector.
 * @topic Unreal
 */
/**
 * @function ObserveVectorPlaneProjectNominal
 * @summary returns a new vector.
 * @covers FVector.vector-plane-project
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveVectorPlaneProjectNominal()
{
	FVector Projected = FVector(1, 2, 3).VectorPlaneProject(FVector(0, 0, 1));
	return Projected.Equals(FVector(1, 2, 0));
}
/** @end */
/**
 * @begin rotate-angle-axis
 * @summary returns a new vector.
 * @topic Unreal
 */
/**
 * @function ObserveRotateAngleAxisNominal
 * @summary returns a new vector.
 * @covers FVector.rotate-angle-axis
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveRotateAngleAxisNominal()
{
	FVector Rotated = FVector(1, 0, 0).RotateAngleAxis(90.0, FVector(0, 0, 1));
	return Rotated.Equals(FVector(0, 1, 0));
}
/** @end */
/**
 * @begin cosine-angle-2-d
 * @summary returns a new vector.
 * @topic Unreal
 */
/**
 * @function ObserveCosineAngle2DNominal
 * @summary returns a new vector.
 * @covers FVector.cosine-angle-2-d
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveCosineAngle2DNominal()
{
	float64 Aligned = FVector(1, 0, 5).CosineAngle2D(FVector(1, 0, 9));
	float64 Perp = FVector(1, 0, 0).CosineAngle2D(FVector(0, 1, 0));
	return Aligned == 1.0 && Perp == 0.0;
}
/** @end */
/**
 * @begin project-on-to
 * @summary returns a new vector.
 * @topic Unreal
 */
/**
 * @function ObserveProjectOnToNominal
 * @summary returns a new vector.
 * @covers FVector.project-on-to
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveProjectOnToNominal()
{
	FVector Projected = FVector(2, 2, 0).ProjectOnTo(FVector(1, 0, 0));
	return Projected.Equals(FVector(2, 0, 0));
}
/** @end */
/**
 * @begin project-on-to-normal
 * @summary returns a new vector.
 * @topic Unreal
 */
/**
 * @function ObserveProjectOnToNormalNominal
 * @summary returns a new vector.
 * @covers FVector.project-on-to-normal
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveProjectOnToNormalNominal()
{
	FVector Projected = FVector(2, 2, 0).ProjectOnToNormal(FVector(0, 1, 0));
	return Projected.Equals(FVector(0, 2, 0));
}
/** @end */
/**
 * @begin unwind-euler
 * @summary returns a new vector.
 * @topic Unreal
 */
/**
 * @function ObserveUnwindEulerNominal
 * @summary returns a new vector.
 * @covers FVector.unwind-euler
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveUnwindEulerNominal()
{
	FVector Euler(370, 0, -190);
	Euler.UnwindEuler();
	return Euler.Equals(FVector(10, 0, 170));
}
/** @end */
/**
 * @begin heading-angle
 * @summary returns a new vector.
 * @topic Unreal
 */
/**
 * @function ObserveHeadingAngleNominal
 * @summary returns a new vector.
 * @covers FVector.heading-angle
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveHeadingAngleNominal()
{
	return FVector::ForwardVector.HeadingAngle() == 0.0 && FVector::RightVector.HeadingAngle() == HALF_PI;
}
/** @end */
/**
 * @begin points-are-same
 * @summary returns a new vector.
 * @topic Unreal
 */
/**
 * @function ObservePointsAreSameNominal
 * @summary returns a new vector.
 * @covers FVector.points-are-same
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObservePointsAreSameNominal()
{
	return FVector(1, 2, 3).PointsAreSame(FVector(1, 2, 3)) && !FVector(1, 2, 3).PointsAreSame(FVector(10, 0, 0));
}
/** @end */
/**
 * @begin points-are-near
 * @summary returns a new vector.
 * @topic Unreal
 */
/**
 * @function ObservePointsAreNearNominal
 * @summary returns a new vector.
 * @covers FVector.points-are-near
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObservePointsAreNearNominal()
{
	return FVector(0, 0, 0).PointsAreNear(FVector(1, 1, 1), 2.0) &&
		!FVector(0, 0, 0).PointsAreNear(FVector(3, 0, 0), 2.0);
}
/** @end */
/**
 * @begin distance
 * @summary returns a new vector.
 * @topic Unreal
 */
/**
 * @function ObserveDistanceNominal
 * @summary returns a new vector.
 * @covers FVector.distance
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDistanceNominal()
{
	return FVector(0, 0, 0).Distance(FVector(3, 4, 12)) == 13.0 && FVector(1, 2, 3).Distance(FVector(1, 2, 3)) == 0.0;
}
/** @end */
/**
 * @begin dist-squared
 * @summary InitFromString
 * @topic Unreal
 */
/**
 * @function ObserveDistSquaredNominal
 * @summary InitFromString
 * @covers FVector.dist-squared
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// InitFromString

 true parses (1,2,3); empty returns false.
// Boundary/ownership: DistXY aliases Dist2D. DistSquared2D aliases
// DistSquaredXY. InitFromString mutates the receiver. Rotation returns a
// new FRotator.
bool ObserveDistSquaredNominal()
{
	return FVector(0, 0, 0).DistSquared(FVector(3, 4, 12)) == 169.0 && FVector(1, 1, 1).DistSquared(FVector(1, 1, 1)) == 0.0;
}
/** @end */
/**
 * @begin dist-2-d
 * @summary new FRotator.
 * @topic Unreal
 */
/**
 * @function ObserveDist2DNominal
 * @summary new FRotator.
 * @covers FVector.dist-2-d
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// InitFromString

bool ObserveDist2DNominal()
{
	return FVector(0, 0, 0).Dist2D(FVector(3, 4, 12)) == 5.0 && FVector(0, 0, 9).Dist2D(FVector(0, 0, 1)) == 0.0;
}
/** @end */
/**
 * @begin dist-xy
 * @summary new FRotator.
 * @topic Unreal
 */
/**
 * @function ObserveDistXYNominal
 * @summary new FRotator.
 * @covers FVector.dist-xy
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// InitFromString

bool ObserveDistXYNominal()
{
	return FVector(0, 0, 0).DistXY(FVector(3, 4, 12)) == 5.0;
}
/** @end */
/**
 * @begin dist-squared-xy
 * @summary new FRotator.
 * @topic Unreal
 */
/**
 * @function ObserveDistSquaredXYNominal
 * @summary new FRotator.
 * @covers FVector.dist-squared-xy
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// InitFromString

bool ObserveDistSquaredXYNominal()
{
	return FVector(0, 0, 0).DistSquaredXY(FVector(3, 4, 12)) == 25.0;
}
/** @end */
/**
 * @begin dist-squared-2-d
 * @summary new FRotator.
 * @topic Unreal
 */
/**
 * @function ObserveDistSquared2DNominal
 * @summary new FRotator.
 * @covers FVector.dist-squared-2-d
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// InitFromString

bool ObserveDistSquared2DNominal()
{
	return FVector(0, 0, 0).DistSquared2D(FVector(3, 4, 12)) == 25.0;
}
/** @end */
/**
 * @begin rotation
 * @summary new FRotator.
 * @topic Unreal
 */
/**
 * @function ObserveRotationNominal
 * @summary new FRotator.
 * @covers FVector.rotation
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// InitFromString

bool ObserveRotationNominal()
{
	FRotator Forward = FVector::ForwardVector.Rotation();
	FRotator Up = FVector::UpVector.Rotation();
	return Forward.Pitch == 0.0 && Forward.Yaw == 0.0 && Up.Pitch == 90.0;
}
/** @end */
/**
 * @begin init-from-string
 * @summary new FRotator.
 * @topic Unreal
 */
/**
 * @function ObserveInitFromStringNominal
 * @summary new FRotator.
 * @covers FVector.init-from-string
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// InitFromString

bool ObserveInitFromStringNominal()
{
	FVector Parsed;
	bool bValid = Parsed.InitFromString("X=1 Y=2 Z=3");
	FVector EmptyTarget(9, 9, 9);
	bool bEmpty = EmptyTarget.InitFromString("");
	return bValid && Parsed.Equals(FVector(1, 2, 3)) && !bEmpty;
}
/** @end */
/**
 * @begin struct-fvector
 * @summary struct FVector.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary struct FVector.
 * @covers FVector.struct-fvector
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
 Value is (0,0,0). Declaration, no fixture.
bool ObserveSurface001Nominal()
{
	FVector Value;
	return Value.X == 0.0 && Value.Y == 0.0 && Value.Z == 0.0;
}
/** @end */
/**
 * @begin assignment
 * @summary Vector = Other copies XYZ.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Vector = Other copies XYZ.
 * @covers FVector.assignment
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FVector Vector(2, 4, 6);
	FVector Other(1, 1, 1);
	Vector = Other;
	Vector.X = 9.0;
	return Vector.X == 9.0 && Other.X == 1.0 && Other.Z == 1.0;
}
/** @end */
/**
 * @begin multiply-assign
 * @summary Vector *= Scale then *= Other: (2,4,6)
 * @topic Unreal
 */
/**
 * @function ObserveMultiplyAssignNominal
 * @summary Vector *= Scale then *= Other: (2,4,6)
 * @covers FVector.multiply-assign
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
2 is (4,8,12); *0.5 restores (2,4,6). Mutates receiver.
bool ObserveMultiplyAssignNominal()
{
	FVector Vector(2, 4, 6);
	Vector *= 2.0;
	bool bScale = Vector.X == 4.0 && Vector.Y == 8.0 && Vector.Z == 12.0;
	Vector *= FVector(0.5, 0.5, 0.5);
	return bScale && Vector.X == 2.0 && Vector.Z == 6.0;
}
/** @end */
/**
 * @begin divide-assign
 * @summary Vector /= Scale then /= Other: (2,4,6)/
 * @topic Unreal
 */
/**
 * @function ObserveDivideAssignNominal
 * @summary Vector /= Scale then /= Other: (2,4,6)/
 * @covers FVector.divide-assign
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
2 is (1,2,3); /(1,2,3) is (1,1,1). Mutates receiver.
bool ObserveDivideAssignNominal()
{
	FVector Vector(2, 4, 6);
	Vector /= 2.0;
	bool bScale = Vector.X == 1.0 && Vector.Y == 2.0 && Vector.Z == 3.0;
	Vector /= FVector(1, 2, 3);
	return bScale && Vector.X == 1.0 && Vector.Y == 1.0 && Vector.Z == 1.0;
}
/** @end */
/**
 * @begin add-assign
 * @summary Vector += Other: (2,4,6)+(1,1,1) is (3,5,7).
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary Vector += Other: (2,4,6)+(1,1,1) is (3,5,7).
 * @covers FVector.add-assign
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal()
{
	FVector Vector(2, 4, 6);
	FVector Other(1, 1, 1);
	Vector += Other;
	return Vector.X == 3.0 && Vector.Z == 7.0 && Other.X == 1.0;
}
/** @end */
/**
 * @begin subtract-assign
 * @summary Vector -= Other then Text += Vector: (2,4,6)-(1,1,1) is (1,3,5).
 * @topic Unreal
 */
/**
 * @function ObserveSubtractAssignNominal
 * @summary Vector -= Other then Text += Vector: (2,4,6)-(1,1,1) is (1,3,5).
 * @covers FVector.subtract-assign
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSubtractAssignNominal()
{
	FVector Vector(2, 4, 6);
	Vector -= FVector(1, 1, 1);
	FString Text = "v:";
	Text += Vector;
	return Vector.X == 1.0 && Vector.Z == 5.0 && Text.Len() > 2;
}
/** @end */
/**
 * @begin to-direction-and-length
 * @summary Expected observations:
 * @topic Unreal
 */
/**
 * @function ObserveToDirectionAndLengthNominal
 * @summary Expected observations:
 * @covers FVector.to-direction-and-length
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 Direction of (3,4,0) is (0.6,0.8,0) for both
// overloads. Zero writes zero direction and length 0. Forward orientation
// rotator is identity. Up rotator pitch is 90. Forward quat W is 1. ToString
// is non-empty.
// Boundary/ownership: OutDir/OutLength are writebacks. Orientation helpers
// return new rotator/quat values. ToString returns a new FString.
bool ObserveToDirectionAndLengthNominal()
{
	FVector Dir;
	float64 Length64 = -1.0;
	FVector(3, 4, 0).ToDirectionAndLength(Dir, Length64);
	FVector Dir32;
	float32 Length32 = -1.0f;
	FVector(3, 4, 0).ToDirectionAndLength(Dir32, Length32);
	FVector ZeroDir = FVector::OneVector;
	float64 ZeroLength = -1.0;
	FVector::ZeroVector.ToDirectionAndLength(ZeroDir, ZeroLength);
	return Dir.Equals(FVector(0.6, 0.8, 0)) &&
		Length64 == 5.0 &&
		Dir32.Equals(FVector(0.6, 0.8, 0)) &&
		Length32 == 5.0f &&
		ZeroDir.IsZero() &&
		ZeroLength == 0.0;
}
/** @end */
/**
 * @begin to-orientation-rotator
 * @summary return new rotator/quat values.
 * @topic Unreal
 */
/**
 * @function ObserveToOrientationRotatorNominal
 * @summary return new rotator/quat values.
 * @covers FVector.to-orientation-rotator
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveToOrientationRotatorNominal()
{
	FRotator Forward = FVector::ForwardVector.ToOrientationRotator();
	FRotator Up = FVector::UpVector.ToOrientationRotator();
	return Forward.Pitch == 0.0 && Forward.Yaw == 0.0 && Up.Pitch == 90.0;
}
/** @end */
/**
 * @begin to-orientation-quat
 * @summary return new rotator/quat values.
 * @topic Unreal
 */
/**
 * @function ObserveToOrientationQuatNominal
 * @summary return new rotator/quat values.
 * @covers FVector.to-orientation-quat
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveToOrientationQuatNominal()
{
	FQuat Forward = FVector::ForwardVector.ToOrientationQuat();
	FQuat Up = FVector::UpVector.ToOrientationQuat();
	return Forward.W == 1.0 && Forward.X == 0.0 && Up.W != 0.0;
}
/** @end */
/**
 * @begin to-string
 * @summary return new rotator/quat values.
 * @topic Unreal
 */
/**
 * @function ObserveToStringNominal
 * @summary return new rotator/quat values.
 * @covers FVector.to-string
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveToStringNominal()
{
	FVector Vector(1, 2, 3);
	FString Text = Vector.ToString();
	FString ZeroText = FVector::ZeroVector.ToString();
	return Text.Len() > 0 && ZeroText.Len() > 0 && Vector.X == 1.0;
}
/** @end */
/**
 * @begin add-bounded
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveAddBoundedNominal
 * @summary Observe the container API.
 * @covers FVector.add-bounded
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: Seeded (0,0,0) plus (100,0,0) with Radius 10, default-radius add of
// (1,0,0), text "v:", vector (1,2,3), repeated append, Empty cleanup.
// Expected observations: Radius 10 clamps X to 10. Default radius keeps 1.
// First append grows length, second grows further, Empty restores 0. Vector
// is unchanged by Append.
// Boundary/ownership: AddBounded mutates the receiver then clamps to a
// symmetric cube. Append copies formatted text.
bool ObserveAddBoundedNominal()
{
	FVector Vector;
	Vector.AddBounded(FVector(100, 0, 0), 10.0);
	FVector DefaultRadius;
	DefaultRadius.AddBounded(FVector(1, 0, 0));
	return Vector.Equals(FVector(10, 0, 0)) && DefaultRadius.Equals(FVector(1, 0, 0));
}
/** @end */
/**
 * @begin append
 * @summary symmetric cube.
 * @topic Unreal
 */
/**
 * @function ObserveAppendNominal
 * @summary symmetric cube.
 * @covers FVector.append
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveAppendNominal()
{
	FString Text = "v:";
	FVector Vector(1, 2, 3);
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
 * @begin FVector-NamespaceAndGlobalFunctions_01-expected-observations
 * @summary Expected observations:
 * @topic Unreal
 */
/**
 * @function ObserveSurface087Nominal
 * @summary Expected observations:
 * @covers FVector.expected-observations
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 Zero is (0,0,0). One is (1,1,1). Up is (0,0,1).
// Down is (0,0,-1). Forward is (1,0,0). Backward is (-1,0,0). Right is
// (0,1,0). Left is (0,-1,0).
// Boundary/ownership: Constants are shared values, not factory functions.
// FVector::ZeroVector is (0,0,0). Shared constant.
bool ObserveSurface087Nominal()
{
	return FVector::ZeroVector.X == 0.0 && FVector::ZeroVector.Y == 0.0 && FVector::ZeroVector.Z == 0.0;
}
/** @end */
/**
 * @begin container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface088Nominal
 * @summary Observe the container API.
 * @covers FVector.container-api
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 FVector::OneVector is (1,1,1). Shared constant.
bool ObserveSurface088Nominal()
{
	return FVector::OneVector.X == 1.0 && FVector::OneVector.Y == 1.0 && FVector::OneVector.Z == 1.0;
}
/** @end */
/**
 * @begin FVector-NamespaceAndGlobalFunctions_01-container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface089Nominal
 * @summary Observe the container API.
 * @covers FVector.container-api
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 FVector::UpVector is (0,0,1). Shared constant.
bool ObserveSurface089Nominal()
{
	return FVector::UpVector.X == 0.0 && FVector::UpVector.Y == 0.0 && FVector::UpVector.Z == 1.0;
}
/** @end */
/**
 * @begin container-api-2
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface090Nominal
 * @summary Observe the container API.
 * @covers FVector.container-api
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 FVector::DownVector is (0,0,-1). Shared constant.
bool ObserveSurface090Nominal()
{
	return FVector::DownVector.X == 0.0 && FVector::DownVector.Y == 0.0 && FVector::DownVector.Z == -1.0;
}
/** @end */
/**
 * @begin container-api-3
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface091Nominal
 * @summary Observe the container API.
 * @covers FVector.container-api
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 FVector::ForwardVector is (1,0,0). Shared constant.
bool ObserveSurface091Nominal()
{
	return FVector::ForwardVector.X == 1.0 && FVector::ForwardVector.Y == 0.0 && FVector::ForwardVector.Z == 0.0;
}
/** @end */
/**
 * @begin container-api-4
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface092Nominal
 * @summary Observe the container API.
 * @covers FVector.container-api
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 FVector::BackwardVector is (-1,0,0). Shared constant.
bool ObserveSurface092Nominal()
{
	return FVector::BackwardVector.X == -1.0 && FVector::BackwardVector.Y == 0.0 && FVector::BackwardVector.Z == 0.0;
}
/** @end */
/**
 * @begin container-api-5
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface093Nominal
 * @summary Observe the container API.
 * @covers FVector.container-api
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 FVector::RightVector is (0,1,0). Shared constant.
bool ObserveSurface093Nominal()
{
	return FVector::RightVector.X == 0.0 && FVector::RightVector.Y == 1.0 && FVector::RightVector.Z == 0.0;
}
/** @end */
/**
 * @begin container-api-6
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface094Nominal
 * @summary Observe the container API.
 * @covers FVector.container-api
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 FVector::LeftVector is (0,-1,0). Shared constant.
bool ObserveSurface094Nominal()
{
	return FVector::LeftVector.X == 0.0 && FVector::LeftVector.Y == -1.0 && FVector::LeftVector.Z == 0.0;
}
/** @end */
/**
 * @begin addition
 * @summary Vector + Other and FString + Vector: (2,4,6)+(1,1,1) is (3,*,7).
 * @topic Unreal
 */
/**
 * @function ObserveAdditionNominal
 * @summary Vector + Other and FString + Vector: (2,4,6)+(1,1,1) is (3,*,7).
 * @covers FVector.addition
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAdditionNominal()
{
	FVector Vector(2, 4, 6);
	FVector Sum = Vector + FVector(1, 1, 1);
	FString Combined = FString("v:") + Vector;
	return Sum.X == 3.0 && Sum.Z == 7.0 && Combined.Len() > 2 && Vector.X == 2.0;
}
/** @end */
/**
 * @begin subtraction
 * @summary Vector - Other: (2,4,6)-(1,1,1) is (1,*,5).
 * @topic Unreal
 */
/**
 * @function ObserveSubtractionNominal
 * @summary Vector - Other: (2,4,6)-(1,1,1) is (1,*,5).
 * @covers FVector.subtraction
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSubtractionNominal()
{
	FVector Vector(2, 4, 6);
	FVector Difference = Vector - FVector(1, 1, 1);
	return Difference.X == 1.0 && Difference.Z == 5.0 && Vector.X == 2.0;
}
/** @end */
/**
 * @begin vector-other-per-component
 * @summary Vector * Other is per-component: (2,4,6)*(1,2,3) is (2,8,18).
 * @topic Unreal
 */
/**
 * @function ObserveSurface014Nominal
 * @summary Vector * Other is per-component: (2,4,6)*(1,2,3) is (2,8,18).
 * @covers FVector.vector-other-per-component
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface014Nominal()
{
	FVector Vector(2, 4, 6);
	FVector Product = Vector * FVector(1, 2, 3);
	return Product.X == 2.0 && Product.Y == 8.0 && Product.Z == 18.0 && Vector.Y == 4.0;
}
/** @end */
/**
 * @begin FVector-Operators_01-vector-other-per-component
 * @summary Vector / Other is per-component: (2,4,6)/(2,2,3) is (1,2,2).
 * @topic Unreal
 */
/**
 * @function ObserveSurface015Nominal
 * @summary Vector / Other is per-component: (2,4,6)/(2,2,3) is (1,2,2).
 * @covers FVector.vector-other-per-component
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface015Nominal()
{
	FVector Vector(2, 4, 6);
	FVector Quotient = Vector / FVector(2, 2, 3);
	return Quotient.X == 1.0 && Quotient.Y == 2.0 && Quotient.Z == 2.0;
}
/** @end */
/**
 * @begin vector-scale-2-4
 * @summary Vector * Scale: (2,4,6)
 * @topic Unreal
 */
/**
 * @function ObserveSurface016Nominal
 * @summary Vector * Scale: (2,4,6)
 * @covers FVector.vector-scale-2-4
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
2 is (4,*,12). Source X stays 2.
bool ObserveSurface016Nominal()
{
	FVector Vector(2, 4, 6);
	FVector Scaled = Vector * 2.0;
	return Scaled.X == 4.0 && Scaled.Z == 12.0 && Vector.X == 2.0;
}
/** @end */
/**
 * @begin FVector-Operators_01-vector-scale-2-4
 * @summary Vector / Scale: (2,4,6)/
 * @topic Unreal
 */
/**
 * @function ObserveSurface017Nominal
 * @summary Vector / Scale: (2,4,6)/
 * @covers FVector.vector-scale-2-4
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
2 is (1,2,3).
bool ObserveSurface017Nominal()
{
	FVector Vector(2, 4, 6);
	FVector Quotient = Vector / 2.0;
	return Quotient.X == 1.0 && Quotient.Y == 2.0 && Quotient.Z == 3.0;
}
/** @end */
/**
 * @begin index
 * @summary Vector[Index]: [0] is X, [2] is Z, write [1] mutates Y.
 * @topic Unreal
 */
/**
 * @function ObserveIndexNominal
 * @summary Vector[Index]: [0] is X, [2] is Z, write [1] mutates Y.
 * @covers FVector.index
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIndexNominal()
{
	FVector Vector(2, 4, 6);
	const FVector ConstVector(2, 4, 6);
	float64 X = Vector[0];
	float64 Z = Vector[2];
	Vector[1] = 9.0;
	float64 ConstZ = ConstVector[2];
	return X == 2.0 && Z == 6.0 && Vector.Y == 9.0 && ConstZ == 6.0 && ConstVector.Y == 4.0;
}
/** @end */
/**
 * @begin equality
 * @summary Vector == Other is exact: copies compare true.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary Vector == Other is exact: copies compare true.
 * @covers FVector.equality
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FVector Left(2, 4, 6);
	FVector Right(2, 4, 6);
	FVector Different(2, 4, 7);
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
 * @covers FVector.equals
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 GetMax of (2,-8,4) is 4. GetAbsMax is 8. GetMin is
// -8. GetAbsMin is 2. GetAbs drops signs. Zero is exactly zero; a tiny
// vector is nearly zero. Unit X is normalized. Sign vector of (1,-2,0) is
// (1,-1,1).
// Boundary/ownership: Equals uses tolerance unlike operator==. Queries do
// not mutate the receiver. Zero components sign as +1.
bool ObserveEqualsNominal()
{
	FVector Left(1, 2, 3);
	FVector Right(1, 2, 3);
	FVector Perturbed(1.0 + KINDA_SMALL_NUMBER * 0.5, 2, 3);
	FVector Far(2, 2, 3);
	return Left.Equals(Right) && Left.Equals(Perturbed) && !Left.Equals(Far, 0.0);
}
/** @end */
/**
 * @begin get-max
 * @summary not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetMaxNominal
 * @summary not mutate the receiver.
 * @covers FVector.get-max
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetMaxNominal()
{
	return FVector(2, -8, 4).GetMax() == 4.0 && FVector(0, 0, 0).GetMax() == 0.0;
}
/** @end */
/**
 * @begin get-abs-max
 * @summary not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetAbsMaxNominal
 * @summary not mutate the receiver.
 * @covers FVector.get-abs-max
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetAbsMaxNominal()
{
	return FVector(2, -8, 4).GetAbsMax() == 8.0 && FVector(0, 0, 0).GetAbsMax() == 0.0;
}
/** @end */
/**
 * @begin get-min
 * @summary not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetMinNominal
 * @summary not mutate the receiver.
 * @covers FVector.get-min
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetMinNominal()
{
	return FVector(2, -8, 4).GetMin() == -8.0 && FVector(0, 0, 0).GetMin() == 0.0;
}
/** @end */
/**
 * @begin get-abs-min
 * @summary not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetAbsMinNominal
 * @summary not mutate the receiver.
 * @covers FVector.get-abs-min
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetAbsMinNominal()
{
	return FVector(2, -8, 4).GetAbsMin() == 2.0 && FVector(-1, -1, -1).GetAbsMin() == 1.0;
}
/** @end */
/**
 * @begin get-abs
 * @summary not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetAbsNominal
 * @summary not mutate the receiver.
 * @covers FVector.get-abs
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetAbsNominal()
{
	FVector Abs = FVector(-1, 2, -3).GetAbs();
	return Abs.X == 1.0 && Abs.Y == 2.0 && Abs.Z == 3.0;
}
/** @end */
/**
 * @begin is-nearly-zero
 * @summary not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveIsNearlyZeroNominal
 * @summary not mutate the receiver.
 * @covers FVector.is-nearly-zero
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveIsNearlyZeroNominal()
{
	FVector Tiny(KINDA_SMALL_NUMBER * 0.5, 0, 0);
	return FVector(0, 0, 0).IsNearlyZero() && Tiny.IsNearlyZero() && !FVector(1, 0, 0).IsNearlyZero();
}
/** @end */
/**
 * @begin is-zero
 * @summary not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveIsZeroNominal
 * @summary not mutate the receiver.
 * @covers FVector.is-zero
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveIsZeroNominal()
{
	return FVector(0, 0, 0).IsZero() && !FVector(0, 0, 1).IsZero();
}
/** @end */
/**
 * @begin is-normalized
 * @summary not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveIsNormalizedNominal
 * @summary not mutate the receiver.
 * @covers FVector.is-normalized
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveIsNormalizedNominal()
{
	return FVector(1, 0, 0).IsNormalized() && !FVector(2, 0, 0).IsNormalized() && !FVector(0, 0, 0).IsNormalized();
}
/** @end */
/**
 * @begin get-sign-vector
 * @summary not mutate the receiver.
 * @topic Unreal
 */
/**
 * @function ObserveGetSignVectorNominal
 * @summary not mutate the receiver.
 * @covers FVector.get-sign-vector
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetSignVectorNominal()
{
	FVector Signs = FVector(1, -2, 0).GetSignVector();
	return Signs.X == 1.0 && Signs.Y == -1.0 && Signs.Z == 1.0;
}
/** @end */
/**
 * @begin get-unsafe-normal
 * @summary Expected observations: Unsafe
 * @topic Unreal
 */
/**
 * @function ObserveGetUnsafeNormalNominal
 * @summary Expected observations: Unsafe
 * @covers FVector.get-unsafe-normal
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

 normal of (0,0,2) is (0,0,1). Size clamp of
// (10,0,0) into [2,5] is length 5. 2D clamps preserve Z. Uniform (2,2,2) is
// true. Safe normal of zero is ZeroVector or ResultIfZero. Best axes are
// unit and orthogonal to UpVector. Finite vectors are not NaN.
// Boundary/ownership: GetSafeNormal does not mutate. Out Axis1/Axis2 are
// writebacks. GetUnsafeNormal of zero may be non-finite.
bool ObserveGetUnsafeNormalNominal()
{
	FVector Normal = FVector(0, 0, 2).GetUnsafeNormal();
	return Normal.Equals(FVector(0, 0, 1));
}
/** @end */
/**
 * @begin get-clamped-to-size
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetClampedToSizeNominal
 * @summary writebacks.
 * @covers FVector.get-clamped-to-size
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

bool ObserveGetClampedToSizeNominal()
{
	FVector Long = FVector(10, 0, 0).GetClampedToSize(2.0, 5.0);
	FVector Short = FVector(1, 0, 0).GetClampedToSize(2.0, 5.0);
	return Long.Equals(FVector(5, 0, 0)) && Short.Equals(FVector(2, 0, 0));
}
/** @end */
/**
 * @begin get-clamped-to-size-2-d
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetClampedToSize2DNominal
 * @summary writebacks.
 * @covers FVector.get-clamped-to-size-2-d
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

bool ObserveGetClampedToSize2DNominal()
{
	FVector Clamped = FVector(10, 0, 7).GetClampedToSize2D(0.0, 5.0);
	return Clamped.Equals(FVector(5, 0, 7));
}
/** @end */
/**
 * @begin get-clamped-to-max-size
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetClampedToMaxSizeNominal
 * @summary writebacks.
 * @covers FVector.get-clamped-to-max-size
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

bool ObserveGetClampedToMaxSizeNominal()
{
	FVector Long = FVector(10, 0, 0).GetClampedToMaxSize(5.0);
	FVector Short = FVector(1, 0, 0).GetClampedToMaxSize(5.0);
	return Long.Equals(FVector(5, 0, 0)) && Short.Equals(FVector(1, 0, 0));
}
/** @end */
/**
 * @begin get-clamped-to-max-size-2-d
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetClampedToMaxSize2DNominal
 * @summary writebacks.
 * @covers FVector.get-clamped-to-max-size-2-d
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

bool ObserveGetClampedToMaxSize2DNominal()
{
	FVector Clamped = FVector(10, 0, 7).GetClampedToMaxSize2D(5.0);
	return Clamped.Equals(FVector(5, 0, 7));
}
/** @end */
/**
 * @begin is-uniform
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveIsUniformNominal
 * @summary writebacks.
 * @covers FVector.is-uniform
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

bool ObserveIsUniformNominal()
{
	return FVector(2, 2, 2).IsUniform() && !FVector(2, 2, 3).IsUniform();
}
/** @end */
/**
 * @begin get-safe-normal
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetSafeNormalNominal
 * @summary writebacks.
 * @covers FVector.get-safe-normal
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

bool ObserveGetSafeNormalNominal()
{
	FVector Unit = FVector(0, 0, 2).GetSafeNormal();
	FVector ZeroDefault = FVector::ZeroVector.GetSafeNormal();
	FVector ZeroFallback = FVector::ZeroVector.GetSafeNormal(SMALL_NUMBER, FVector::OneVector);
	return Unit.Equals(FVector(0, 0, 1)) && ZeroDefault.IsZero() && ZeroFallback == FVector::OneVector;
}
/** @end */
/**
 * @begin get-safe-normal-2-d
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetSafeNormal2DNominal
 * @summary writebacks.
 * @covers FVector.get-safe-normal-2-d
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

bool ObserveGetSafeNormal2DNominal()
{
	FVector UnitXY = FVector(3, 4, 9).GetSafeNormal2D();
	FVector ZeroXY = FVector(0, 0, 5).GetSafeNormal2D();
	FVector Fallback = FVector(0, 0, 5).GetSafeNormal2D(SMALL_NUMBER, FVector::OneVector);
	return UnitXY.Equals(FVector(0.6, 0.8, 0)) && ZeroXY.IsZero() && Fallback == FVector::OneVector;
}
/** @end */
/**
 * @begin find-best-axis-vectors
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveFindBestAxisVectorsNominal
 * @summary writebacks.
 * @covers FVector.find-best-axis-vectors
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

bool ObserveFindBestAxisVectorsNominal()
{
	FVector Axis1;
	FVector Axis2;
	FVector::UpVector.FindBestAxisVectors(Axis1, Axis2);
	return Axis1.IsNormalized() &&
		Axis2.IsNormalized() &&
		Axis1.Orthogonal(FVector::UpVector) &&
		Axis2.Orthogonal(FVector::UpVector) &&
		Axis1.Orthogonal(Axis2);
}
/** @end */
/**
 * @begin contains-na-n
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveContainsNaNNominal
 * @summary writebacks.
 * @covers FVector.contains-na-n
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

bool ObserveContainsNaNNominal()
{
	FVector MaybeNonFinite = FVector::ZeroVector.GetUnsafeNormal();
	return !FVector(1, 2, 3).ContainsNaN() && MaybeNonFinite.ContainsNaN();
}
/** @end */
/**
 * @begin is-unit
 * @summary not.
 * @topic Unreal
 */
/**
 * @function ObserveIsUnitNominal
 * @summary not.
 * @covers FVector.is-unit
 * @inputs FVector values exercised by this observe
 * @return true when the observe comparison holds
 */
// not. A large tolerance

 can treat (2,0,0) as unit when squared length is
// near one only under that wide window if the API uses |SizeSquared-1|.
// Boundary/ownership: Query does not mutate. Default tolerance is
// KINDA_SMALL_NUMBER.
bool ObserveIsUnitNominal()
{
	return FVector(1, 0, 0).IsUnit() &&
		!FVector(2, 0, 0).IsUnit() &&
		!FVector(0, 0, 0).IsUnit() &&
		FVector(1, 0, 0).IsUnit(1.0);
}
/** @end */
/**
 * @begin arithmetic-operators
 * @summary Divide a vector in place.
 * @topic Unreal
 */
/**
 * @function OpAddNominal
 * @summary Divide a vector in place.
 * @covers FVector.ArithmeticOperators
 * @inputs none
 * @return FVector(5, 10, 15)
 */
 equals FVector(5, 7, 9)
 */
UFUNCTION()
bool OpAddNominal()
{
	return OpAdd().Equals(FVector(5, 7, 9));
}
/** @end */
/**
 * @begin comparison-operators
 * @summary Compare two identical vectors for equality.
 * @topic Unreal
 */
/**
 * @function OpEquals_True
 * @summary Compare two identical vectors for equality.
 * @covers FVector.ComparisonOperators
 * @inputs none
 * @return true
 */
bool OpEquals_True()
{
	FVector a = FVector(1, 2, 3);
	FVector b = FVector(1, 2, 3);
	return a == b;
}
/** @end */
/**
 * @begin construction
 * @summary Observe that the default constructor yields the zero vector.
 * @topic Unreal
 */
/**
 * @function DefaultNominal
 * @summary Observe that the default constructor yields the zero vector.
 * @covers FVector.Construction
 * @inputs none
 * @return true when the default equals the zero vector
 */
bool DefaultNominal()
{
	return ConstructDefault().Equals(FVector::ZeroVector);
}
/** @end */
/**
 * @begin declarations-and-index-access
 * @summary Read a member off an unconstructed plain struct, which raises a null pointer access.
 * @topic Unreal
 */
/**
 * @function PlainClassMemberValueRaisesBoundary
 * @summary Read a member off an unconstructed plain struct, which raises a null pointer access.
 * @covers FVector.DeclarationsAndIndexAccess
 * @inputs none
 * @return nothing reachable; throws before a value can be produced
 */
const FVector GlobalConstVector = FVector::ZeroVector;

/**
 * A plain script struct holding a vector, used to show that reading a member off an
 * unconstructed one is a runtime boundary rather than a compile error.
 *
 * @Covers FVector.DeclarationsAndIndexAccess
 * @Inputs none
 * @Return a holder whose Value is set during construction
 */
class FPlainVectorHolder
{
	FVector Value;

	/**
	 * Populate the held vector.
	 *
	 * @Kind Helper
	 * @Covers FVector.DeclarationsAndIndexAccess
	 * @Inputs none
	 * @Return Value set

int PlainClassMemberValueRaisesBoundary()
{
	FPlainVectorHolder Holder;
	return Holder.Value.X + Holder.Value.Y + Holder.Value.Z;
}
/** @end */
/**
 * @begin dot-and-cross
 * @summary Observe that orthogonal vectors have a zero dot product.
 * @topic Unreal
 */
/**
 * @function DotProductNominal
 * @summary Observe that orthogonal vectors have a zero dot product.
 * @covers FVector.DotAndCross
 * @inputs none
 * @return true when the dot product is 0
 */
bool DotProductNominal()
{
	return Math::IsNearlyEqual(DotProduct(), 0.0);
}
/** @end */
/**
 * @begin extended-operators-and-methods
 * @summary Normalize a vector in place and report whether it succeeded.
 * @topic Unreal
 */
/**
 * @function NormalizeMutates
 * @summary Normalize a vector in place and report whether it succeeded.
 * @covers FVector.ExtendedOperatorsAndMethods
 * @inputs none
 * @return true when Normalize reported success and the vector became the unit X axis
 */
bool NormalizeMutates()
{
	FVector v = FVector(10, 0, 0);
	bool bNormalized = v.Normalize();

	if (!bNormalized)
	{
		return false;
	}
	return v.Equals(FVector(1, 0, 0), 0.001);
}
/** @end */
/**
 * @begin member-access
 * @summary Observe that reading X yields the expected value.
 * @topic Unreal
 */
/**
 * @function GetXNominal
 * @summary Observe that reading X yields the expected value.
 * @covers FVector.MemberAccess
 * @inputs none
 * @return true when X reads 10
 */
bool GetXNominal()
{
	return Math::IsNearlyEqual(GetX(), 10.0);
}
/** @end */
/**
 * @begin methods
 * @summary Ask whether the zero vector is zero.
 * @topic Unreal
 */
/**
 * @function VectorIsZero
 * @summary Ask whether the zero vector is zero.
 * @covers FVector.Methods
 * @inputs none
 * @return true
 */
bool VectorIsZero()
{
	FVector v = FVector::ZeroVector;
	return v.IsZero();
}
/** @end */
/**
 * @begin default-f-vector-property-applied
 * @summary Check each component against the applied default, naming the first one that missed.
 * @topic Unreal
 */
/**
 * @function VerifyVector
 * @summary Check each component against the applied default, naming the first one that missed.
 * @covers FVector.DefaultFVectorPropertyApplied
 * @inputs none
 * @return 42 when all three match; 1, 2 or 3 naming the component that did not
 */
UCLASS()
class UDefaultVectorCarrier : UObject
{
	UPROPERTY()
	FVector MyVector;

	default MyVector = FVector(1.0f, 2.0f, 3.0f);

	int VerifyVector()
	{
		if (MyVector.X < 0.9f || MyVector.X > 1.1f)
			return 1;
		if (MyVector.Y < 1.9f || MyVector.Y > 2.1f)
			return 2;
		if (MyVector.Z < 2.9f || MyVector.Z > 3.1f)
			return 3;
		return 42;
	}
/** @end */
/**
 * @begin container-properties
 * @summary WorldStory: BeginPlay fills the array with the three basis vectors and the map with the three named directions.
 * @topic Unreal
 */
/**
 * @function BeginPlay
 * @summary WorldStory: BeginPlay fills the array with the three basis vectors and the map with the three named directions.
 * @covers FVector.ContainerProperties
 * @inputs none
 * @return three entries in each container
 */
UCLASS()
class ACoverageFVectorContainerActor : AActor
{
	UPROPERTY()
	TArray<FVector> VectorArray;

	UPROPERTY()
	TMap<int, FVector> IntToVectorMap;

	/**
	 * WorldStory: BeginPlay fills the array with the three basis vectors and the map with
	 * the three named directions.
	 *
	 * @Kind WorldStory
	 * @Covers FVector.ContainerProperties
	 * @Inputs none
	 * @Return three entries in each container
	 */
	UFUNCTION(BlueprintOverride)

	void BeginPlay()
	{
		VectorArray.Add(FVector(1, 0, 0));
		VectorArray.Add(FVector(0, 1, 0));
		VectorArray.Add(FVector(0, 0, 1));

		IntToVectorMap.Add(1, FVector::ForwardVector);
		IntToVectorMap.Add(2, FVector::RightVector);
		IntToVectorMap.Add(3, FVector::UpVector);
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
 * @covers FVector.DeclarationDefaults
 * @inputs none
 * @return true when all three components of ZeroVec are 0
 */
UCLASS()
class ACoverageFVectorDefaultsActor : AActor
{
	UPROPERTY()
	FVector ZeroVec = FVector::ZeroVector;

	UPROPERTY()
	FVector OneVec = FVector::OneVector;

	UPROPERTY()
	FVector CustomVec = FVector(1, 2, 3);

	UPROPERTY()
	FVector NoDefaultVec;

	UPROPERTY()
	FVector UpVec = FVector::UpVector;

	bool ZeroVecNominal()
	{
		if (ZeroVec.X != 0.0)
		{
			return false;
		}
		if (ZeroVec.Y != 0.0)
		{
			return false;
		}
		return ZeroVec.Z == 0.0;
	}
/** @end */
/**
 * @begin script-member-and-local-usage
 * @summary Read every local and const flavour of vector, naming the first that does not match.
 * @topic Unreal
 */
/**
 * @function ReadLocalAndConstVectors
 * @summary Read every local and const flavour of vector, naming the first that does not match.
 * @covers FVector.ScriptMemberAndLocalUsage
 * @inputs none
 * @return 0 when all four match; 1 through 4 naming the one that did not
 */
const FVector GlobalForward = FVector::ForwardVector;

UCLASS()
class ACoverageFVectorScriptMemberActor : AActor
{
	FVector RawMember = FVector(4, 5, 6);

	UPROPERTY()
	FVector ReflectedMember = FVector::RightVector;

	int ReadLocalAndConstVectors()
	{
		FVector DefaultLocal;
		FVector CustomLocal = FVector(1, 2, 3);
		const FVector ConstLocal = FVector::UpVector;

		if (DefaultLocal != FVector::ZeroVector)
			return 1;
		if (CustomLocal != FVector(1, 2, 3))
			return 2;
		if (ConstLocal != FVector(0, 0, 1))
			return 3;
		if (GlobalForward != FVector(1, 0, 0))
			return 4;
		return 0;
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
 * @covers FVector.WriteRoundTrip
 * @inputs none
 * @return true when all three components are 0
 */
UCLASS()
class ACoverageFVectorWriteActor : AActor
{
	UPROPERTY()
	FVector VectorValue;

	bool DefaultEmpty()
	{
		if (VectorValue.X != 0.0)
		{
			return false;
		}
		if (VectorValue.Y != 0.0)
		{
			return false;
		}
		return VectorValue.Z == 0.0;
	}
/** @end */
/**
 * @begin vector-4-int-point-int-vector-expressions
 * @summary Add to and scale a four-component vector, then halve it back.
 * @topic Unreal
 */
/**
 * @function TestIntPointConstruction
 * @summary Add to and scale a four-component vector, then halve it back.
 * @covers FVector.Vector4IntPointIntVectorExpressions
 * @inputs none
 * @return FVector4(2, 3, 4, 5)
 */
Return FIntPoint(3, 4)
 */
UFUNCTION()
FIntPoint TestIntPointConstruction()
{
	return FIntPoint(3, 4);
}
/** @end */
/**
 * @begin function-default-parameters
 * @summary A defaulted vector parameter, exercised both with and without the caller supplying it. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The.
 * @topic Unreal
 */
namespace FVectorTest
{
	/**
	 * Add two vectors, where the second defaults to the one vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionDefaultParameters
	 * @Inputs a vector and an optional second vector
	 * @Return the sum of the two
	 * @Param a the first vector
	 * @Param b the second vector, defaulting to the one vector
	 */
	UFUNCTION()
	FVector AddWithDefault(FVector a, FVector b = FVector::OneVector)
	{
		return a + b;
	}

	/**
	 * Add to a vector relying on the parameter default.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionDefaultParameters
	 * @Inputs a vector
	 * @Return the vector plus the one vector
	 * @Param a the vector to add to
	 */
	UFUNCTION()
	FVector AddUsingDefault(FVector a)
	{
		return AddWithDefault(a);
	}

	/**
	 * Observe that an explicitly supplied second argument is used.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when the sum equals FVector(5, 7, 9)
	 */
	UFUNCTION()
	bool AddWithDefaultExplicit()
	{
		return AddWithDefault(FVector(1, 2, 3), FVector(4, 5, 6)).Equals(FVector(5, 7, 9));
	}

	/**
	 * Observe that the parameter default is applied when the caller omits it.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionDefaultParameters
	 * @Inputs none
	 * @Return true when the sum equals FVector(2, 3, 4)
	 */
	UFUNCTION()
	bool AddUsingDefaultNominal()
	{
		return AddUsingDefault(FVector(1, 2, 3)).Equals(FVector(2, 3, 4));
	}

	/**
	 * Observe that adding an empty vector to the default yields the one vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionDefaultParameters
	 * @Inputs a default-constructed vector
	 * @Return true when the sum equals the one vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AddUsingDefaultEmptyZero()
	{
		return AddUsingDefault(FVector()).Equals(FVector::OneVector);
	}

	/**
	 * Observe that mutating the returned sum leaves the caller's argument alone.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionDefaultParameters
	 * @Inputs a vector and the mutated sum built from it
	 * @Return true when the argument still reads FVector(1, 2, 3)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AddUsingDefaultCopyIndependence()
	{
		FVector Arg1 = FVector(1, 2, 3);
		FVector Result = AddUsingDefault(Arg1);
		Result.X = 0.0;
		return Arg1.Equals(FVector(1, 2, 3));
	}
}
/** @end */
/**
 * @begin function-parameters-in
 * @summary A FVector passed by read-only reference, where the callee reads through the caller's value without taking a copy. C++ executes the entrypoint and checks the value it produces, so the name is part of the contract and is.
 * @topic Unreal
 */
namespace FVectorTest
{
	/**
	 * Measure the length of a vector passed by read-only reference.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersIn
	 * @Inputs a vector
	 * @Return the length of the vector
	 * @Param v the vector to measure
	 */
	UFUNCTION()
	float AcceptVectorIn(FVector&in v)
	{
		return v.Size();
	}

	/**
	 * Observe that the measured length matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersIn
	 * @Inputs none
	 * @Return true when the length is 5
	 */
	UFUNCTION()
	bool AcceptVectorInNominal()
	{
		FVector Input = FVector(3, 4, 0);
		return Math::IsNearlyEqual(AcceptVectorIn(Input), 5.0, 0.001);
	}

	/**
	 * Observe that an empty argument measures zero.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersIn
	 * @Inputs a default-constructed vector
	 * @Return true when the length is 0
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptVectorInDefaultEmpty()
	{
		FVector Empty = FVector();
		return Math::IsNearlyEqual(AcceptVectorIn(Empty), 0.0, 0.001);
	}

	/**
	 * Observe that reading through the reference leaves the caller's vector alone.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersIn
	 * @Inputs a vector read through the reference
	 * @Return true when the argument still reads FVector(3, 4, 0) and the size is 5
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AcceptVectorInCopyIndependence()
	{
		FVector Input = FVector(3, 4, 0);
		float Size = AcceptVectorIn(Input);

		if (!Input.Equals(FVector(3, 4, 0)))
		{
			return false;
		}
		return Math::IsNearlyEqual(Size, 5.0, 0.001);
	}
}
/** @end */
/**
 * @begin function-parameters-in-out
 * @summary A FVector passed by mutable reference and scaled in place. C++ executes the entrypoint and checks the value written back, so the name is part of the contract and is kept verbatim. The observers cover the empty argument.
 * @topic Unreal
 */
namespace FVectorTest
{
	/**
	 * Scale a vector in place through a mutable reference.
	 *
	 * @Kind Action
	 * @Covers FVector.FunctionParametersInOut
	 * @Inputs a vector and a scale factor
	 * @Return the vector scaled in place
	 * @Param v the vector to scale
	 * @Param scale the factor to scale by
	 */
	UFUNCTION()
	void ScaleVector(FVector&inout v, float scale)
	{
		v = v * scale;
	}

	/**
	 * Observe that the caller's vector is scaled in place.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersInOut
	 * @Inputs none
	 * @Return true when the value reads FVector(2, 4, 6)
	 */
	UFUNCTION()
	bool ScaleVectorNominal()
	{
		FVector Value = FVector(1, 2, 3);
		ScaleVector(Value, 2.0);
		return Value.Equals(FVector(2, 4, 6), 0.001);
	}

	/**
	 * Observe that scaling an empty vector stays at the origin.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersInOut
	 * @Inputs a default-constructed vector
	 * @Return true when the value still equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ScaleVectorDefaultEmpty()
	{
		FVector Empty = FVector();
		ScaleVector(Empty, 2.0);
		return Empty.Equals(FVector::ZeroVector, 0.001);
	}

	/**
	 * Observe that scaling one vector leaves a separate copy untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersInOut
	 * @Inputs a vector and a separate copy of it
	 * @Return true when the scaled one reads (2, 4, 6) and the copy still reads (1, 2, 3)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ScaleVectorCopyIndependence()
	{
		FVector Value = FVector(1, 2, 3);
		FVector Other = Value;
		ScaleVector(Value, 2.0);

		if (!Value.Equals(FVector(2, 4, 6), 0.001))
		{
			return false;
		}
		return Other.Equals(FVector(1, 2, 3), 0.001);
	}
}
/** @end */
/**
 * @begin function-parameters-out
 * @summary FVectors written through out parameters, where the callee fills in the caller's variable. C++ executes each entrypoint and checks the values written, so those names are part of the contract and are kept verbatim. The.
 * @topic Unreal
 */
namespace FVectorTest
{
	/**
	 * Write a fixed vector into an out parameter.
	 *
	 * @Kind Action
	 * @Covers FVector.FunctionParametersOut
	 * @Inputs none
	 * @Return the out parameter filled with FVector(10, 20, 30)
	 * @Param v the vector to write into
	 */
	UFUNCTION()
	void WriteVector(FVector&out v)
	{
		v = FVector(10, 20, 30);
	}

	/**
	 * Write two named directions into two out parameters.
	 *
	 * @Kind Action
	 * @Covers FVector.FunctionParametersOut
	 * @Inputs none
	 * @Return the first out parameter as the forward vector, the second as the up vector
	 * @Param a the first vector to write into
	 * @Param b the second vector to write into
	 */
	UFUNCTION()
	void WriteMultipleVectors(FVector&out a, FVector&out b)
	{
		a = FVector::ForwardVector;
		b = FVector::UpVector;
	}

	/**
	 * Observe that the single out parameter receives the written value.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the out value equals FVector(10, 20, 30)
	 */
	UFUNCTION()
	bool WriteVectorNominal()
	{
		FVector OutValue;
		WriteVector(OutValue);
		return OutValue.Equals(FVector(10, 20, 30));
	}

	/**
	 * Observe that both out parameters receive their own direction.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersOut
	 * @Inputs none
	 * @Return true when the first reads the forward vector and the second the up vector
	 */
	UFUNCTION()
	bool WriteMultipleVectorsNominal()
	{
		FVector OutA;
		FVector OutB;
		WriteMultipleVectors(OutA, OutB);

		if (!OutA.Equals(FVector::ForwardVector))
		{
			return false;
		}
		return OutB.Equals(FVector::UpVector);
	}

	/**
	 * Observe that an out parameter starts empty before it is written.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersOut
	 * @Inputs an uninitialised out value
	 * @Return true when it equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool WriteVectorDefaultEmpty()
	{
		FVector Empty;
		return Empty.Equals(FVector::ZeroVector);
	}

	/**
	 * Observe that mutating one out value leaves the other untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersOut
	 * @Inputs two out values, the first mutated afterwards
	 * @Return true when the second still reads the up vector
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool WriteMultipleVectorsCopyIndependence()
	{
		FVector OutA;
		FVector OutB;
		WriteMultipleVectors(OutA, OutB);
		OutA.X = 0.0;
		return OutB.Equals(FVector::UpVector);
	}
}
/** @end */
/**
 * @begin function-parameters-value
 * @summary FVectors passed by value, where the callee receives its own copy. C++ executes each entrypoint and checks the value it produces, so those names are part of the contract and are kept verbatim. The observers cover the.
 * @topic Unreal
 */
namespace FVectorTest
{
	/**
	 * Double every component of a vector passed by value.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersValue
	 * @Inputs a vector
	 * @Return the vector with every component doubled
	 * @Param v the vector to scale
	 */
	UFUNCTION()
	FVector AcceptVector(FVector v)
	{
		return v * 2.0;
	}

	/**
	 * Measure the distance between two vectors passed by value.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersValue
	 * @Inputs two vectors
	 * @Return the distance between them
	 * @Param a the first vector
	 * @Param b the second vector
	 */
	UFUNCTION()
	float AcceptTwoVectors(FVector a, FVector b)
	{
		return a.Distance(b);
	}

	/**
	 * Observe that the doubling matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersValue
	 * @Inputs none
	 * @Return true when the result equals FVector(2, 4, 6)
	 */
	UFUNCTION()
	bool AcceptVectorNominal()
	{
		return AcceptVector(FVector(1, 2, 3)).Equals(FVector(2, 4, 6));
	}

	/**
	 * Observe that the distance matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersValue
	 * @Inputs none
	 * @Return true when the distance is 5
	 */
	UFUNCTION()
	bool AcceptTwoVectorsNominal()
	{
		return Math::IsNearlyEqual(AcceptTwoVectors(FVector(0, 0, 0), FVector(3, 4, 0)), 5.0, 0.001);
	}

	/**
	 * Observe that doubling an empty vector stays at the origin.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersValue
	 * @Inputs a default-constructed vector
	 * @Return true when the result equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AcceptVectorDefaultEmpty()
	{
		return AcceptVector(FVector()).Equals(FVector::ZeroVector);
	}

	/**
	 * Observe that mutating the returned vector leaves the caller's argument alone.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionParametersValue
	 * @Inputs a vector and the mutated result of passing it in
	 * @Return true when the argument still reads FVector(1, 2, 3)
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AcceptVectorCopyIndependence()
	{
		FVector Input = FVector(1, 2, 3);
		FVector Result = AcceptVector(Input);
		Result.X = 0.0;
		return Input.Equals(FVector(1, 2, 3));
	}
}
/** @end */
/**
 * @begin function-return-values
 * @summary Vectors returned from functions: a constant, a literal and a computed sum. C++ executes each entrypoint and compares the result with the native equivalent, so those names are part of the contract and are kept verbatim.
 * @topic Unreal
 */
namespace FVectorTest
{
	/**
	 * Return a vector constant.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionReturnValues
	 * @Inputs none
	 * @Return the forward vector
	 */
	UFUNCTION()
	FVector ReturnForwardVector()
	{
		return FVector::ForwardVector;
	}

	/**
	 * Return a literal vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionReturnValues
	 * @Inputs none
	 * @Return FVector(5, 10, 15)
	 */
	UFUNCTION()
	FVector ReturnCustomVector()
	{
		return FVector(5, 10, 15);
	}

	/**
	 * Return a vector computed from two others.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionReturnValues
	 * @Inputs none
	 * @Return FVector(5, 7, 9)
	 */
	UFUNCTION()
	FVector ReturnComputedVector()
	{
		FVector a = FVector(1, 2, 3);
		FVector b = FVector(4, 5, 6);
		return a + b;
	}

	/**
	 * Observe that the constant return matches the forward vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals the forward vector
	 */
	UFUNCTION()
	bool ReturnForwardVectorNominal()
	{
		return ReturnForwardVector().Equals(FVector::ForwardVector);
	}

	/**
	 * Observe that the literal return matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals FVector(5, 10, 15)
	 */
	UFUNCTION()
	bool ReturnCustomVectorNominal()
	{
		return ReturnCustomVector().Equals(FVector(5, 10, 15));
	}

	/**
	 * Observe that the computed return matches the expected value.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionReturnValues
	 * @Inputs none
	 * @Return true when the result equals FVector(5, 7, 9)
	 */
	UFUNCTION()
	bool ReturnComputedVectorNominal()
	{
		return ReturnComputedVector().Equals(FVector(5, 7, 9));
	}

	/**
	 * Observe that an empty vector equals the zero vector.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionReturnValues
	 * @Inputs a default-constructed vector
	 * @Return true when it equals the zero vector
	 * @Boundary default value
	 */
	UFUNCTION()
	bool ReturnCustomVectorDefaultEmpty()
	{
		FVector Empty = FVector();
		return Empty.Equals(FVector::ZeroVector);
	}

	/**
	 * Observe that mutating a copy leaves the returned vector untouched.
	 *
	 * @Kind Observe
	 * @Covers FVector.FunctionReturnValues
	 * @Inputs the returned vector and a mutated copy of it
	 * @Return true when the returned one still reads (5, 10, 15) and the copy reads 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool ReturnCustomVectorCopyIndependence()
	{
		FVector Original = ReturnCustomVector();
		FVector Copy = Original;
		Copy.X = 0.0;

		if (!Original.Equals(FVector(5, 10, 15)))
		{
			return false;
		}
		return Copy.X == 0.0;
	}
}
/** @end */
