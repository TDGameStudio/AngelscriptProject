/**
 * @version v1
 * @summary FVector3f host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FVector3f
 *
 * vector
 * surface-005
 * surface-006
 * surface-007
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
 * FVector3f-Behavior_05-vector
 * assignment
 * multiply-assign
 * divide-assign
 * FVector3f-ConstructionAndAssignment_02-multiply-assign
 * FVector3f-ConstructionAndAssignment_02-divide-assign
 * add-assign
 * subtract-assign
 * FVector3f-ConstructionAndAssignment_02-assignment
 * to-direction-and-length
 * to-orientation-rotator
 * to-orientation-quat
 * add-bounded
 * container-api
 * FVector3f-NamespaceAndGlobalFunctions_01-container-api
 * container-api-2
 * container-api-3
 * container-api-4
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
 */
/**
 * @begin vector
 * @summary Expected observations:
 * @topic Unreal
 */
/**
 * @function ObserveVectorNominal
 * @summary Expected observations:
 * @covers FVector3f.vector
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 Default is (0,0,0). Uniform 7 fills all axes. Copy
// preserves (1,2,3). X cross Y is Z. X dot Y is 0. (1,1,1) components are
// equal.
// Boundary/ownership: Constructors copy values. Components are float32.
// AllComponentsEqual uses __KINDA_SMALL_NUMBER_flt.
// FVector3f(X,Y,Z), default, uniform, and copy constructors. Components are float32 copies.
bool ObserveVectorNominal()
{
	FVector3f Explicit(1.0f, 2.0f, 3.0f);
	FVector3f Zero;
	FVector3f Uniform(7.0f);
	FVector3f Copied(Explicit);
	return Explicit.Z == 3.0f && Zero.IsZero() && Uniform.Y == 7.0f && Copied.X == 1.0f;
}
/** @end */
/**
 * @begin surface-005
 * @summary FVector3f.
 * @topic Unreal
 */
/**
 * @function ObserveSurface005Nominal
 * @summary FVector3f.
 * @covers FVector3f.surface-005
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

X of (1,2,3) is 1. Field read does not mutate.
bool ObserveSurface005Nominal()
{
	return FVector3f(1.0f, 2.0f, 3.0f).X == 1.0f;
}
/** @end */
/**
 * @begin surface-006
 * @summary FVector3f.
 * @topic Unreal
 */
/**
 * @function ObserveSurface006Nominal
 * @summary FVector3f.
 * @covers FVector3f.surface-006
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

Y of (1,2,3) is 2. Field read does not mutate.
bool ObserveSurface006Nominal()
{
	return FVector3f(1.0f, 2.0f, 3.0f).Y == 2.0f;
}
/** @end */
/**
 * @begin surface-007
 * @summary FVector3f.
 * @topic Unreal
 */
/**
 * @function ObserveSurface007Nominal
 * @summary FVector3f.
 * @covers FVector3f.surface-007
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

Z of (1,2,3) is 3. Field read does not mutate.
bool ObserveSurface007Nominal()
{
	return FVector3f(1.0f, 2.0f, 3.0f).Z == 3.0f;
}
/** @end */
/**
 * @begin cross-product
 * @summary CrossProduct of unit X and unit Y is unit Z.
 * @topic Unreal
 */
/**
 * @function ObserveCrossProductNominal
 * @summary CrossProduct of unit X and unit Y is unit Z.
 * @covers FVector3f.cross-product
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveCrossProductNominal()
{
	FVector3f Cross = FVector3f(1.0f, 0.0f, 0.0f).CrossProduct(FVector3f(0.0f, 1.0f, 0.0f));
	return Cross.Equals(FVector3f(0.0f, 0.0f, 1.0f));
}
/** @end */
/**
 * @begin dot-product
 * @summary DotProduct of orthogonal unit axes is 0.
 * @topic Unreal
 */
/**
 * @function ObserveDotProductNominal
 * @summary DotProduct of orthogonal unit axes is 0.
 * @covers FVector3f.dot-product
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveDotProductNominal()
{
	float32 Orthogonal = FVector3f(1.0f, 0.0f, 0.0f).DotProduct(FVector3f(0.0f, 1.0f, 0.0f));
	float32 Aligned = FVector3f(1.0f, 0.0f, 0.0f).DotProduct(FVector3f(1.0f, 0.0f, 0.0f));
	return Orthogonal == 0.0f && Aligned == 1.0f;
}
/** @end */
/**
 * @begin all-components-equal
 * @summary AllComponentsEqual is
 * @topic Unreal
 */
/**
 * @function ObserveAllComponentsEqualNominal
 * @summary AllComponentsEqual is
 * @covers FVector3f.all-components-equal
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 true for (1,1,1) and false for (1,2,1).
bool ObserveAllComponentsEqualNominal()
{
	return FVector3f(1.0f, 1.0f, 1.0f).AllComponentsEqual() && !FVector3f(1.0f, 2.0f, 1.0f).AllComponentsEqual();
}
/** @end */
/**
 * @begin parallel
 * @summary Inputs: Forward/Right and -Forward, (2,0,-1)
 * @topic Unreal
 */
/**
 * @function ObserveParallelNominal
 * @summary Inputs: Forward/Right and -Forward, (2,0,-1)
 * @covers FVector3f.parallel
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Forward/Right and -Forward, (2,0,-1)

 vs min (0,0,0) max (1,1,1),
// (3,4,0) Size 5, (3,4,12) SizeSquared 169 and XY size 5.
// Expected observations: Forward is parallel and coincident with itself,
// parallel but not coincident with -Forward, orthogonal to Right. Component
// clamp maps (2,0,-1) to (1,0,0). Size of (3,4,0) is 5. Size2D of (3,4,12)
// is 5.
// Boundary/ownership: Parallel family expects unit normals. Default
// thresholds are __THRESH_NORMALS_ARE_PARALLEL_flt /
// __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
bool ObserveParallelNominal()
{
	FVector3f AntiForward(-1.0f, 0.0f, 0.0f);
	bool bSame = FVector3f::ForwardVector.Parallel(FVector3f::ForwardVector);
	bool bOpposite = FVector3f::ForwardVector.Parallel(AntiForward);
	bool bSkew = FVector3f::ForwardVector.Parallel(FVector3f::RightVector);
	return bSame && bOpposite && !bSkew;
}
/** @end */
/**
 * @begin coincident
 * @summary __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
 * @topic Unreal
 */
/**
 * @function ObserveCoincidentNominal
 * @summary __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
 * @covers FVector3f.coincident
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Forward/Right and -Forward, (2,0,-1)

bool ObserveCoincidentNominal()
{
	FVector3f AntiForward(-1.0f, 0.0f, 0.0f);
	bool bSame = FVector3f::ForwardVector.Coincident(FVector3f::ForwardVector);
	bool bOpposite = FVector3f::ForwardVector.Coincident(AntiForward);
	return bSame && !bOpposite;
}
/** @end */
/**
 * @begin orthogonal
 * @summary __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
 * @topic Unreal
 */
/**
 * @function ObserveOrthogonalNominal
 * @summary __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
 * @covers FVector3f.orthogonal
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Forward/Right and -Forward, (2,0,-1)

bool ObserveOrthogonalNominal()
{
	bool bPerp = FVector3f::ForwardVector.Orthogonal(FVector3f::RightVector);
	bool bAligned = FVector3f::ForwardVector.Orthogonal(FVector3f::ForwardVector);
	return bPerp && !bAligned;
}
/** @end */
/**
 * @begin component-min
 * @summary __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
 * @topic Unreal
 */
/**
 * @function ObserveComponentMinNominal
 * @summary __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
 * @covers FVector3f.component-min
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Forward/Right and -Forward, (2,0,-1)

bool ObserveComponentMinNominal()
{
	FVector3f Min = FVector3f(2.0f, 0.0f, -1.0f).ComponentMin(FVector3f(1.0f, 1.0f, 1.0f));
	return Min.Equals(FVector3f(1.0f, 0.0f, -1.0f));
}
/** @end */
/**
 * @begin component-max
 * @summary __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
 * @topic Unreal
 */
/**
 * @function ObserveComponentMaxNominal
 * @summary __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
 * @covers FVector3f.component-max
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Forward/Right and -Forward, (2,0,-1)

bool ObserveComponentMaxNominal()
{
	FVector3f Max = FVector3f(2.0f, 0.0f, -1.0f).ComponentMax(FVector3f(1.0f, 1.0f, 1.0f));
	return Max.Equals(FVector3f(2.0f, 1.0f, 1.0f));
}
/** @end */
/**
 * @begin component-clamp
 * @summary __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
 * @topic Unreal
 */
/**
 * @function ObserveComponentClampNominal
 * @summary __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
 * @covers FVector3f.component-clamp
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Forward/Right and -Forward, (2,0,-1)

bool ObserveComponentClampNominal()
{
	FVector3f Clamped = FVector3f(2.0f, 0.0f, -1.0f).ComponentClamp(FVector3f(0.0f, 0.0f, 0.0f), FVector3f(1.0f, 1.0f, 1.0f));
	return Clamped.Equals(FVector3f(1.0f, 0.0f, 0.0f));
}
/** @end */
/**
 * @begin size
 * @summary __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
 * @topic Unreal
 */
/**
 * @function ObserveSizeNominal
 * @summary __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
 * @covers FVector3f.size
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Forward/Right and -Forward, (2,0,-1)

bool ObserveSizeNominal()
{
	return FVector3f(3.0f, 4.0f, 0.0f).Size() == 5.0f && FVector3f(0.0f, 0.0f, 0.0f).Size() == 0.0f;
}
/** @end */
/**
 * @begin size-squared
 * @summary __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
 * @topic Unreal
 */
/**
 * @function ObserveSizeSquaredNominal
 * @summary __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
 * @covers FVector3f.size-squared
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Forward/Right and -Forward, (2,0,-1)

bool ObserveSizeSquaredNominal()
{
	return FVector3f(3.0f, 4.0f, 12.0f).SizeSquared() == 169.0f && FVector3f(0.0f, 0.0f, 0.0f).SizeSquared() == 0.0f;
}
/** @end */
/**
 * @begin size-2-d
 * @summary __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
 * @topic Unreal
 */
/**
 * @function ObserveSize2DNominal
 * @summary __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
 * @covers FVector3f.size-2-d
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Forward/Right and -Forward, (2,0,-1)

bool ObserveSize2DNominal()
{
	return FVector3f(3.0f, 4.0f, 12.0f).Size2D() == 5.0f && FVector3f(0.0f, 0.0f, 9.0f).Size2D() == 0.0f;
}
/** @end */
/**
 * @begin size-squared-2-d
 * @summary __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
 * @topic Unreal
 */
/**
 * @function ObserveSizeSquared2DNominal
 * @summary __THRESH_NORMALS_ARE_ORTHOGONAL_flt.
 * @covers FVector3f.size-squared-2-d
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs: Forward/Right and -Forward, (2,0,-1)

bool ObserveSizeSquared2DNominal()
{
	return FVector3f(3.0f, 4.0f, 12.0f).SizeSquared2D() == 25.0f && FVector3f(0.0f, 0.0f, 9.0f).SizeSquared2D() == 0.0f;
}
/** @end */
/**
 * @begin normalize
 * @summary Expected observations:
 * @topic Unreal
 */
/**
 * @function ObserveNormalizeNominal
 * @summary Expected observations:
 * @covers FVector3f.normalize
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 Normalize of (3,0,0) yields unit X and true. Zero
// stays zero and false. Projection of (2,4,2) is (1,2,1). GridSnap rounds.
// Cube/box clamp. Reciprocal of 2 is 0.5; zero uses __BIG_NUMBER_flt. Mirror
// of (1,1,0) across X is (-1,1,0). Plane project drops Z. 90 deg maps X to
// Y. Cosine of aligned XY is 1.
// Boundary/ownership: Normalize mutates. Reciprocal of zero is BIG_NUMBER,
// not an exception. RotateAngleAxis returns a new vector.
bool ObserveNormalizeNominal()
{
	FVector3f Vector(3.0f, 0.0f, 0.0f);
	bool bNormalized = Vector.Normalize();
	FVector3f Zero;
	bool bZeroFailed = Zero.Normalize();
	return bNormalized && Vector.Equals(FVector3f(1.0f, 0.0f, 0.0f)) && !bZeroFailed && Zero.IsZero();
}
/** @end */
/**
 * @begin projection
 * @summary not an exception.
 * @topic Unreal
 */
/**
 * @function ObserveProjectionNominal
 * @summary not an exception.
 * @covers FVector3f.projection
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveProjectionNominal()
{
	FVector3f Projected = FVector3f(2.0f, 4.0f, 2.0f).Projection();
	return Projected.Equals(FVector3f(1.0f, 2.0f, 1.0f));
}
/** @end */
/**
 * @begin grid-snap
 * @summary not an exception.
 * @topic Unreal
 */
/**
 * @function ObserveGridSnapNominal
 * @summary not an exception.
 * @covers FVector3f.grid-snap
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGridSnapNominal()
{
	FVector3f Snapped = FVector3f(1.2f, 2.7f, -1.4f).GridSnap(1.0f);
	return Snapped.Equals(FVector3f(1.0f, 3.0f, -1.0f));
}
/** @end */
/**
 * @begin bound-to-cube
 * @summary not an exception.
 * @topic Unreal
 */
/**
 * @function ObserveBoundToCubeNominal
 * @summary not an exception.
 * @covers FVector3f.bound-to-cube
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveBoundToCubeNominal()
{
	FVector3f Cubed = FVector3f(10.0f, 0.0f, -20.0f).BoundToCube(5.0f);
	return Cubed.Equals(FVector3f(5.0f, 0.0f, -5.0f));
}
/** @end */
/**
 * @begin bound-to-box
 * @summary not an exception.
 * @topic Unreal
 */
/**
 * @function ObserveBoundToBoxNominal
 * @summary not an exception.
 * @covers FVector3f.bound-to-box
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveBoundToBoxNominal()
{
	FVector3f Boxed = FVector3f(2.0f, -1.0f, 0.5f).BoundToBox(FVector3f(0.0f, 0.0f, 0.0f), FVector3f(1.0f, 1.0f, 1.0f));
	return Boxed.Equals(FVector3f(1.0f, 0.0f, 0.5f));
}
/** @end */
/**
 * @begin reciprocal
 * @summary not an exception.
 * @topic Unreal
 */
/**
 * @function ObserveReciprocalNominal
 * @summary not an exception.
 * @covers FVector3f.reciprocal
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveReciprocalNominal()
{
	FVector3f Reciprocal = FVector3f(2.0f, 4.0f, 0.0f).Reciprocal();
	return Reciprocal.X == 0.5f && Reciprocal.Y == 0.25f && Reciprocal.Z == __BIG_NUMBER_flt;
}
/** @end */
/**
 * @begin mirror-by-vector
 * @summary not an exception.
 * @topic Unreal
 */
/**
 * @function ObserveMirrorByVectorNominal
 * @summary not an exception.
 * @covers FVector3f.mirror-by-vector
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveMirrorByVectorNominal()
{
	FVector3f Mirrored = FVector3f(1.0f, 1.0f, 0.0f).MirrorByVector(FVector3f(1.0f, 0.0f, 0.0f));
	return Mirrored.Equals(FVector3f(-1.0f, 1.0f, 0.0f));
}
/** @end */
/**
 * @begin vector-plane-project
 * @summary not an exception.
 * @topic Unreal
 */
/**
 * @function ObserveVectorPlaneProjectNominal
 * @summary not an exception.
 * @covers FVector3f.vector-plane-project
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveVectorPlaneProjectNominal()
{
	FVector3f Projected = FVector3f(1.0f, 2.0f, 3.0f).VectorPlaneProject(FVector3f(0.0f, 0.0f, 1.0f));
	return Projected.Equals(FVector3f(1.0f, 2.0f, 0.0f));
}
/** @end */
/**
 * @begin rotate-angle-axis
 * @summary not an exception.
 * @topic Unreal
 */
/**
 * @function ObserveRotateAngleAxisNominal
 * @summary not an exception.
 * @covers FVector3f.rotate-angle-axis
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveRotateAngleAxisNominal()
{
	FVector3f Rotated = FVector3f(1.0f, 0.0f, 0.0f).RotateAngleAxis(90.0f, FVector3f(0.0f, 0.0f, 1.0f));
	return Rotated.Equals(FVector3f(0.0f, 1.0f, 0.0f));
}
/** @end */
/**
 * @begin cosine-angle-2-d
 * @summary not an exception.
 * @topic Unreal
 */
/**
 * @function ObserveCosineAngle2DNominal
 * @summary not an exception.
 * @covers FVector3f.cosine-angle-2-d
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveCosineAngle2DNominal()
{
	float32 Aligned = FVector3f(1.0f, 0.0f, 5.0f).CosineAngle2D(FVector3f(1.0f, 0.0f, 9.0f));
	float32 Perp = FVector3f(1.0f, 0.0f, 0.0f).CosineAngle2D(FVector3f(0.0f, 1.0f, 0.0f));
	return Aligned == 1.0f && Perp == 0.0f;
}
/** @end */
/**
 * @begin project-on-to
 * @summary Expected observations: ProjectOnTo
 * @topic Unreal
 */
/**
 * @function ObserveProjectOnToNominal
 * @summary Expected observations: ProjectOnTo
 * @covers FVector3f.project-on-to
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: ProjectOnTo

 X keeps (2,0,0). Unwind maps 370 to 10
// and -190 to 170. Forward heading is 0. Right heading is __HALF_PI_flt.
// Same points are same; far points are not near Dist 2. Distance of
// (3,4,12) is 13. DistSquared is 169. Dist2D and DistXY are 5.
// Boundary/ownership: UnwindEuler mutates degree components. DistXY aliases
// Dist2D.
bool ObserveProjectOnToNominal()
{
	FVector3f Projected = FVector3f(2.0f, 2.0f, 0.0f).ProjectOnTo(FVector3f(1.0f, 0.0f, 0.0f));
	return Projected.Equals(FVector3f(2.0f, 0.0f, 0.0f));
}
/** @end */
/**
 * @begin project-on-to-normal
 * @summary Dist2D.
 * @topic Unreal
 */
/**
 * @function ObserveProjectOnToNormalNominal
 * @summary Dist2D.
 * @covers FVector3f.project-on-to-normal
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: ProjectOnTo

bool ObserveProjectOnToNormalNominal()
{
	FVector3f Projected = FVector3f(2.0f, 2.0f, 0.0f).ProjectOnToNormal(FVector3f(0.0f, 1.0f, 0.0f));
	return Projected.Equals(FVector3f(0.0f, 2.0f, 0.0f));
}
/** @end */
/**
 * @begin unwind-euler
 * @summary Dist2D.
 * @topic Unreal
 */
/**
 * @function ObserveUnwindEulerNominal
 * @summary Dist2D.
 * @covers FVector3f.unwind-euler
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: ProjectOnTo

bool ObserveUnwindEulerNominal()
{
	FVector3f Euler(370.0f, 0.0f, -190.0f);
	Euler.UnwindEuler();
	return Euler.Equals(FVector3f(10.0f, 0.0f, 170.0f));
}
/** @end */
/**
 * @begin heading-angle
 * @summary Dist2D.
 * @topic Unreal
 */
/**
 * @function ObserveHeadingAngleNominal
 * @summary Dist2D.
 * @covers FVector3f.heading-angle
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: ProjectOnTo

bool ObserveHeadingAngleNominal()
{
	float32 Forward = FVector3f::ForwardVector.HeadingAngle();
	float32 Right = FVector3f::RightVector.HeadingAngle();
	return Forward == 0.0f && Right == __HALF_PI_flt;
}
/** @end */
/**
 * @begin points-are-same
 * @summary Dist2D.
 * @topic Unreal
 */
/**
 * @function ObservePointsAreSameNominal
 * @summary Dist2D.
 * @covers FVector3f.points-are-same
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: ProjectOnTo

bool ObservePointsAreSameNominal()
{
	return FVector3f(1.0f, 2.0f, 3.0f).PointsAreSame(FVector3f(1.0f, 2.0f, 3.0f)) && !FVector3f(1.0f, 2.0f, 3.0f).PointsAreSame(FVector3f(10.0f, 0.0f, 0.0f));
}
/** @end */
/**
 * @begin points-are-near
 * @summary Dist2D.
 * @topic Unreal
 */
/**
 * @function ObservePointsAreNearNominal
 * @summary Dist2D.
 * @covers FVector3f.points-are-near
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: ProjectOnTo

bool ObservePointsAreNearNominal()
{
	bool bNear = FVector3f(0.0f, 0.0f, 0.0f).PointsAreNear(FVector3f(1.0f, 1.0f, 1.0f), 2.0f);
	bool bFar = FVector3f(0.0f, 0.0f, 0.0f).PointsAreNear(FVector3f(3.0f, 0.0f, 0.0f), 2.0f);
	return bNear && !bFar;
}
/** @end */
/**
 * @begin distance
 * @summary Dist2D.
 * @topic Unreal
 */
/**
 * @function ObserveDistanceNominal
 * @summary Dist2D.
 * @covers FVector3f.distance
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: ProjectOnTo

bool ObserveDistanceNominal()
{
	return FVector3f(0.0f, 0.0f, 0.0f).Distance(FVector3f(3.0f, 4.0f, 12.0f)) == 13.0f && FVector3f(1.0f, 2.0f, 3.0f).Distance(FVector3f(1.0f, 2.0f, 3.0f)) == 0.0f;
}
/** @end */
/**
 * @begin dist-squared
 * @summary Dist2D.
 * @topic Unreal
 */
/**
 * @function ObserveDistSquaredNominal
 * @summary Dist2D.
 * @covers FVector3f.dist-squared
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: ProjectOnTo

bool ObserveDistSquaredNominal()
{
	return FVector3f(0.0f, 0.0f, 0.0f).DistSquared(FVector3f(3.0f, 4.0f, 12.0f)) == 169.0f;
}
/** @end */
/**
 * @begin dist-2-d
 * @summary Dist2D.
 * @topic Unreal
 */
/**
 * @function ObserveDist2DNominal
 * @summary Dist2D.
 * @covers FVector3f.dist-2-d
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: ProjectOnTo

bool ObserveDist2DNominal()
{
	return FVector3f(0.0f, 0.0f, 0.0f).Dist2D(FVector3f(3.0f, 4.0f, 12.0f)) == 5.0f && FVector3f(0.0f, 0.0f, 9.0f).Dist2D(FVector3f(0.0f, 0.0f, 1.0f)) == 0.0f;
}
/** @end */
/**
 * @begin dist-xy
 * @summary Dist2D.
 * @topic Unreal
 */
/**
 * @function ObserveDistXYNominal
 * @summary Dist2D.
 * @covers FVector3f.dist-xy
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: ProjectOnTo

bool ObserveDistXYNominal()
{
	return FVector3f(0.0f, 0.0f, 0.0f).DistXY(FVector3f(3.0f, 4.0f, 12.0f)) == 5.0f;
}
/** @end */
/**
 * @begin dist-squared-xy
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveDistSquaredXYNominal
 * @summary Observe the container API.
 * @covers FVector3f.dist-squared-xy
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FVector3f Vector(const FVector& Other).
// Inputs: (0,0,0) to (3,4,12), ForwardVector, UE text "X=1 Y=2 Z=3", empty
// text, FVector(4,5,6).
// Expected observations: DistSquaredXY and DistSquared2D are 25. Forward
// Rotation pitch/yaw are 0. InitFromString true parses (1,2,3); empty
// returns false. FVector conversion keeps 4/5/6.
// Boundary/ownership: DistSquared2D aliases DistSquaredXY. InitFromString
// mutates. FVector conversion copies components into float32.
bool ObserveDistSquaredXYNominal()
{
	return FVector3f(0.0f, 0.0f, 0.0f).DistSquaredXY(FVector3f(3.0f, 4.0f, 12.0f)) == 25.0f;
}
/** @end */
/**
 * @begin dist-squared-2-d
 * @summary mutates.
 * @topic Unreal
 */
/**
 * @function ObserveDistSquared2DNominal
 * @summary mutates.
 * @covers FVector3f.dist-squared-2-d
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveDistSquared2DNominal()
{
	return FVector3f(0.0f, 0.0f, 0.0f).DistSquared2D(FVector3f(3.0f, 4.0f, 12.0f)) == 25.0f;
}
/** @end */
/**
 * @begin rotation
 * @summary mutates.
 * @topic Unreal
 */
/**
 * @function ObserveRotationNominal
 * @summary mutates.
 * @covers FVector3f.rotation
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveRotationNominal()
{
	FRotator3f Forward = FVector3f::ForwardVector.Rotation();
	FRotator3f Up = FVector3f::UpVector.Rotation();
	return Forward.Pitch == 0.0f && Forward.Yaw == 0.0f && Up.Pitch == 90.0f;
}
/** @end */
/**
 * @begin init-from-string
 * @summary mutates.
 * @topic Unreal
 */
/**
 * @function ObserveInitFromStringNominal
 * @summary mutates.
 * @covers FVector3f.init-from-string
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveInitFromStringNominal()
{
	FVector3f Parsed;
	bool bValid = Parsed.InitFromString("X=1 Y=2 Z=3");
	FVector3f EmptyTarget(9.0f, 9.0f, 9.0f);
	bool bEmpty = EmptyTarget.InitFromString("");
	return bValid && Parsed.Equals(FVector3f(1.0f, 2.0f, 3.0f)) && !bEmpty;
}
/** @end */
/**
 * @begin FVector3f-Behavior_05-vector
 * @summary mutates.
 * @topic Unreal
 */
/**
 * @function ObserveVectorNominal
 * @summary mutates.
 * @covers FVector3f.vector
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveVectorNominal()
{
	FVector3f FromDouble(FVector(4, 5, 6));
	return FromDouble.X == 4.0f && FromDouble.Y == 5.0f && FromDouble.Z == 6.0f;
}
/** @end */
/**
 * @begin assignment
 * @summary Components are float32.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary Components are float32.
 * @covers FVector3f.assignment
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FVector3f Left(2.0f, 4.0f, 6.0f);
	FVector3f Right(1.0f, 1.0f, 1.0f);
	Left = Right;
	Left.X = 9.0f;
	FVector3f Vector(2.0f, 4.0f, 6.0f);
	FVector3f Sum = Vector + Right;
	FVector3f Difference = Vector - Right;
	FVector3f ComponentProduct = Vector * FVector3f(1.0f, 2.0f, 3.0f);
	FVector3f ComponentQuotient = Vector / FVector3f(2.0f, 2.0f, 3.0f);
	FVector3f Scaled = Vector * 2.0f;
	FVector3f Quotient = Vector / 2.0f;
	FVector3f Negated = -Vector;
	return Left.X == 9.0f &&
		Right.X == 1.0f &&
		Sum.Z == 7.0f &&
		Difference.X == 1.0f &&
		ComponentProduct.Y == 8.0f &&
		ComponentQuotient.Z == 2.0f &&
		Scaled.X == 4.0f &&
		Quotient.Y == 2.0f &&
		Negated.Z == -6.0f &&
		Vector.X == 2.0f;
}
/** @end */
/**
 * @begin multiply-assign
 * @summary Components are float32.
 * @topic Unreal
 */
/**
 * @function ObserveMultiplyAssignNominal
 * @summary Components are float32.
 * @covers FVector3f.multiply-assign
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMultiplyAssignNominal()
{
	FVector3f Vector(2.0f, 4.0f, 6.0f);
	Vector *= 2.0f;
	return Vector.X == 4.0f && Vector.Z == 12.0f;
}
/** @end */
/**
 * @begin divide-assign
 * @summary Components are float32.
 * @topic Unreal
 */
/**
 * @function ObserveDivideAssignNominal
 * @summary Components are float32.
 * @covers FVector3f.divide-assign
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDivideAssignNominal()
{
	FVector3f Vector(2.0f, 4.0f, 6.0f);
	Vector /= 2.0f;
	return Vector.X == 1.0f && Vector.Y == 2.0f && Vector.Z == 3.0f;
}
/** @end */
/**
 * @begin FVector3f-ConstructionAndAssignment_02-multiply-assign
 * @summary digits into a new FString.
 * @topic Unreal
 */
/**
 * @function ObserveMultiplyAssignNominal
 * @summary digits into a new FString.
 * @covers FVector3f.multiply-assign
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveMultiplyAssignNominal()
{
	FVector3f Vector(2.0f, 4.0f, 6.0f);
	Vector *= FVector3f(0.5f, 0.5f, 0.5f);
	return Vector.X == 1.0f && Vector.Z == 3.0f;
}
/** @end */
/**
 * @begin FVector3f-ConstructionAndAssignment_02-divide-assign
 * @summary digits into a new FString.
 * @topic Unreal
 */
/**
 * @function ObserveDivideAssignNominal
 * @summary digits into a new FString.
 * @covers FVector3f.divide-assign
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveDivideAssignNominal()
{
	FVector3f Vector(2.0f, 4.0f, 6.0f);
	Vector /= FVector3f(2.0f, 2.0f, 3.0f);
	return Vector.X == 1.0f && Vector.Y == 2.0f && Vector.Z == 2.0f;
}
/** @end */
/**
 * @begin add-assign
 * @summary digits into a new FString.
 * @topic Unreal
 */
/**
 * @function ObserveAddAssignNominal
 * @summary digits into a new FString.
 * @covers FVector3f.add-assign
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddAssignNominal()
{
	FVector3f Vector(2.0f, 4.0f, 6.0f);
	FVector3f Other(1.0f, 1.0f, 1.0f);
	Vector += Other;
	return Vector.X == 3.0f && Vector.Z == 7.0f && Other.X == 1.0f;
}
/** @end */
/**
 * @begin subtract-assign
 * @summary digits into a new FString.
 * @topic Unreal
 */
/**
 * @function ObserveSubtractAssignNominal
 * @summary digits into a new FString.
 * @covers FVector3f.subtract-assign
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSubtractAssignNominal()
{
	FVector3f Vector(2.0f, 4.0f, 6.0f);
	Vector -= FVector3f(1.0f, 1.0f, 1.0f);
	return Vector.X == 1.0f && Vector.Z == 5.0f;
}
/** @end */
/**
 * @begin FVector3f-ConstructionAndAssignment_02-assignment
 * @summary digits into a new FString.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary digits into a new FString.
 * @covers FVector3f.assignment
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FVector3f Vector(1.0f, 2.0f, 3.0f);
	FString Text = f"{Vector}";
	FString ZeroText = f"{FVector3f::ZeroVector}";
	return Text.Len() > 0 && ZeroText.Len() > 0 && Vector.Z == 3.0f;
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
 * @covers FVector3f.to-direction-and-length
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 Direction of (3,4,0) is (0.6,0.8,0) and length is
// 5. Zero writes zero direction and length 0. Forward orientation rotator
// is identity. Up rotator pitch is 90. Forward quat W is 1.
// Boundary/ownership: OutDir/OutLength are writebacks. Orientation helpers
// return FRotator3f / FQuat4f.
bool ObserveToDirectionAndLengthNominal()
{
	FVector3f Dir;
	float32 Length = -1.0f;
	FVector3f(3.0f, 4.0f, 0.0f).ToDirectionAndLength(Dir, Length);
	FVector3f ZeroDir = FVector3f::OneVector;
	float32 ZeroLength = -1.0f;
	FVector3f::ZeroVector.ToDirectionAndLength(ZeroDir, ZeroLength);
	return Dir.Equals(FVector3f(0.6f, 0.8f, 0.0f)) && Length == 5.0f && ZeroDir.IsZero() && ZeroLength == 0.0f;
}
/** @end */
/**
 * @begin to-orientation-rotator
 * @summary return FRotator3f / FQuat4f.
 * @topic Unreal
 */
/**
 * @function ObserveToOrientationRotatorNominal
 * @summary return FRotator3f / FQuat4f.
 * @covers FVector3f.to-orientation-rotator
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveToOrientationRotatorNominal()
{
	FRotator3f Forward = FVector3f::ForwardVector.ToOrientationRotator();
	FRotator3f Up = FVector3f::UpVector.ToOrientationRotator();
	return Forward.Pitch == 0.0f && Forward.Yaw == 0.0f && Up.Pitch == 90.0f;
}
/** @end */
/**
 * @begin to-orientation-quat
 * @summary return FRotator3f / FQuat4f.
 * @topic Unreal
 */
/**
 * @function ObserveToOrientationQuatNominal
 * @summary return FRotator3f / FQuat4f.
 * @covers FVector3f.to-orientation-quat
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveToOrientationQuatNominal()
{
	FQuat4f Forward = FVector3f::ForwardVector.ToOrientationQuat();
	FQuat4f Up = FVector3f::UpVector.ToOrientationQuat();
	return Forward.W == 1.0f && Forward.X == 0.0f && Up.W != 1.0f;
}
/** @end */
/**
 * @begin add-bounded
 * @summary symmetric cube even though the bind table marks the method const.
 * @topic Unreal
 */
/**
 * @function ObserveAddBoundedNominal
 * @summary symmetric cube even though the bind table marks the method const.
 * @covers FVector3f.add-bounded
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAddBoundedNominal()
{
	FVector3f Vector;
	Vector.AddBounded(FVector3f(100.0f, 0.0f, 0.0f), 10.0f);
	FVector3f DefaultRadius;
	DefaultRadius.AddBounded(FVector3f(1.0f, 0.0f, 0.0f));
	return Vector.Equals(FVector3f(10.0f, 0.0f, 0.0f)) && DefaultRadius.Equals(FVector3f(1.0f, 0.0f, 0.0f));
}
/** @end */
/**
 * @begin container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface083Nominal
 * @summary Observe the container API.
 * @covers FVector3f.container-api
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Forward is (1,0,0). Right is (0,1,0).
// Boundary/ownership: Constants are shared values, not factory functions.
// Down/Backward/Left are not published on FVector3f.
// FVector3f::ZeroVector is (0,0,0). Shared constant, not a factory.
bool ObserveSurface083Nominal()
{
	return FVector3f::ZeroVector.X == 0.0f && FVector3f::ZeroVector.Y == 0.0f && FVector3f::ZeroVector.Z == 0.0f;
}
/** @end */
/**
 * @begin FVector3f-NamespaceAndGlobalFunctions_01-container-api
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface084Nominal
 * @summary Observe the container API.
 * @covers FVector3f.container-api
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FVector3f::OneVector is (1,1,1). Shared constant, not a factory.
bool ObserveSurface084Nominal()
{
	return FVector3f::OneVector.X == 1.0f && FVector3f::OneVector.Y == 1.0f && FVector3f::OneVector.Z == 1.0f;
}
/** @end */
/**
 * @begin container-api-2
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface085Nominal
 * @summary Observe the container API.
 * @covers FVector3f.container-api
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FVector3f::UpVector is (0,0,1). Shared constant, not a factory.
bool ObserveSurface085Nominal()
{
	return FVector3f::UpVector.X == 0.0f && FVector3f::UpVector.Y == 0.0f && FVector3f::UpVector.Z == 1.0f;
}
/** @end */
/**
 * @begin container-api-3
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface086Nominal
 * @summary Observe the container API.
 * @covers FVector3f.container-api
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FVector3f::ForwardVector is (1,0,0). Shared constant, not a factory.
bool ObserveSurface086Nominal()
{
	return FVector3f::ForwardVector.X == 1.0f && FVector3f::ForwardVector.Y == 0.0f && FVector3f::ForwardVector.Z == 0.0f;
}
/** @end */
/**
 * @begin container-api-4
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveSurface087Nominal
 * @summary Observe the container API.
 * @covers FVector3f.container-api
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FVector3f::RightVector is (0,1,0). Shared constant, not a factory.
bool ObserveSurface087Nominal()
{
	return FVector3f::RightVector.X == 0.0f && FVector3f::RightVector.Y == 1.0f && FVector3f::RightVector.Z == 0.0f;
}
/** @end */
/**
 * @begin index
 * @summary path.
 * @topic Unreal
 */
/**
 * @function ObserveIndexNominal
 * @summary path.
 * @covers FVector3f.index
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIndexNominal()
{
	FVector3f Vector(2.0f, 4.0f, 6.0f);
	float32 X = Vector[0];
	float32 Z = Vector[2];
	Vector[1] = 9.0f;
	return X == 2.0f && Z == 6.0f && Vector.Y == 9.0f;
}
/** @end */
/**
 * @begin equality
 * @summary path.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary path.
 * @covers FVector3f.equality
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FVector3f Left(2.0f, 4.0f, 6.0f);
	FVector3f Right(2.0f, 4.0f, 6.0f);
	FVector3f Different(2.0f, 4.0f, 7.0f);
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
 * @covers FVector3f.equals
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

 GetMax of (2,-8,4) is 4. GetAbsMax is 8. GetMin is
// -8. GetAbsMin is 2. GetAbs drops signs. Tiny is nearly zero. Unit X is
// normalized. Sign vector of (1,-2,0) is (1,-1,1).
// Boundary/ownership: Equals uses __KINDA_SMALL_NUMBER_flt. Queries do not
// mutate. Zero components sign as +1.
bool ObserveEqualsNominal()
{
	FVector3f Left(1.0f, 2.0f, 3.0f);
	FVector3f Right(1.0f, 2.0f, 3.0f);
	FVector3f Perturbed(1.0f + __KINDA_SMALL_NUMBER_flt * 0.5f, 2.0f, 3.0f);
	FVector3f Far(2.0f, 2.0f, 3.0f);
	return Left.Equals(Right) && Left.Equals(Perturbed) && !Left.Equals(Far, 0.0f);
}
/** @end */
/**
 * @begin get-max
 * @summary mutate.
 * @topic Unreal
 */
/**
 * @function ObserveGetMaxNominal
 * @summary mutate.
 * @covers FVector3f.get-max
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetMaxNominal()
{
	return FVector3f(2.0f, -8.0f, 4.0f).GetMax() == 4.0f && FVector3f(0.0f, 0.0f, 0.0f).GetMax() == 0.0f;
}
/** @end */
/**
 * @begin get-abs-max
 * @summary mutate.
 * @topic Unreal
 */
/**
 * @function ObserveGetAbsMaxNominal
 * @summary mutate.
 * @covers FVector3f.get-abs-max
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetAbsMaxNominal()
{
	return FVector3f(2.0f, -8.0f, 4.0f).GetAbsMax() == 8.0f && FVector3f(0.0f, 0.0f, 0.0f).GetAbsMax() == 0.0f;
}
/** @end */
/**
 * @begin get-min
 * @summary mutate.
 * @topic Unreal
 */
/**
 * @function ObserveGetMinNominal
 * @summary mutate.
 * @covers FVector3f.get-min
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetMinNominal()
{
	return FVector3f(2.0f, -8.0f, 4.0f).GetMin() == -8.0f && FVector3f(0.0f, 0.0f, 0.0f).GetMin() == 0.0f;
}
/** @end */
/**
 * @begin get-abs-min
 * @summary mutate.
 * @topic Unreal
 */
/**
 * @function ObserveGetAbsMinNominal
 * @summary mutate.
 * @covers FVector3f.get-abs-min
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetAbsMinNominal()
{
	return FVector3f(2.0f, -8.0f, 4.0f).GetAbsMin() == 2.0f && FVector3f(-1.0f, -1.0f, -1.0f).GetAbsMin() == 1.0f;
}
/** @end */
/**
 * @begin get-abs
 * @summary mutate.
 * @topic Unreal
 */
/**
 * @function ObserveGetAbsNominal
 * @summary mutate.
 * @covers FVector3f.get-abs
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetAbsNominal()
{
	FVector3f Abs = FVector3f(-1.0f, 2.0f, -3.0f).GetAbs();
	return Abs.X == 1.0f && Abs.Y == 2.0f && Abs.Z == 3.0f;
}
/** @end */
/**
 * @begin is-nearly-zero
 * @summary mutate.
 * @topic Unreal
 */
/**
 * @function ObserveIsNearlyZeroNominal
 * @summary mutate.
 * @covers FVector3f.is-nearly-zero
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveIsNearlyZeroNominal()
{
	FVector3f Tiny(__KINDA_SMALL_NUMBER_flt * 0.5f, 0.0f, 0.0f);
	return FVector3f(0.0f, 0.0f, 0.0f).IsNearlyZero() && Tiny.IsNearlyZero() && !FVector3f(1.0f, 0.0f, 0.0f).IsNearlyZero();
}
/** @end */
/**
 * @begin is-zero
 * @summary mutate.
 * @topic Unreal
 */
/**
 * @function ObserveIsZeroNominal
 * @summary mutate.
 * @covers FVector3f.is-zero
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveIsZeroNominal()
{
	return FVector3f(0.0f, 0.0f, 0.0f).IsZero() && !FVector3f(0.0f, 0.0f, 1.0f).IsZero();
}
/** @end */
/**
 * @begin is-normalized
 * @summary mutate.
 * @topic Unreal
 */
/**
 * @function ObserveIsNormalizedNominal
 * @summary mutate.
 * @covers FVector3f.is-normalized
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveIsNormalizedNominal()
{
	return FVector3f(1.0f, 0.0f, 0.0f).IsNormalized() && !FVector3f(2.0f, 0.0f, 0.0f).IsNormalized() && !FVector3f(0.0f, 0.0f, 0.0f).IsNormalized();
}
/** @end */
/**
 * @begin get-sign-vector
 * @summary mutate.
 * @topic Unreal
 */
/**
 * @function ObserveGetSignVectorNominal
 * @summary mutate.
 * @covers FVector3f.get-sign-vector
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations:

bool ObserveGetSignVectorNominal()
{
	FVector3f Signs = FVector3f(1.0f, -2.0f, 0.0f).GetSignVector();
	return Signs.X == 1.0f && Signs.Y == -1.0f && Signs.Z == 1.0f;
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
 * @covers FVector3f.get-unsafe-normal
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

 normal of (0,0,2) is (0,0,1). Size clamp of
// (10,0,0) into [2,5] is length 5. 2D clamps preserve Z. Uniform (2,2,2) is
// true. Safe normal of zero is ZeroVector or ResultIfZero. Best axes are
// unit and orthogonal to UpVector. Finite vectors are not NaN.
// Boundary/ownership: GetSafeNormal does not mutate. Out Axis1/Axis2 are
// writebacks. GetUnsafeNormal of zero may be non-finite. IsUniform default
// tolerance is KINDA_SMALL_NUMBER.
bool ObserveGetUnsafeNormalNominal()
{
	FVector3f Normal = FVector3f(0.0f, 0.0f, 2.0f).GetUnsafeNormal();
	return Normal.Equals(FVector3f(0.0f, 0.0f, 1.0f));
}
/** @end */
/**
 * @begin get-clamped-to-size
 * @summary tolerance is KINDA_SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveGetClampedToSizeNominal
 * @summary tolerance is KINDA_SMALL_NUMBER.
 * @covers FVector3f.get-clamped-to-size
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

bool ObserveGetClampedToSizeNominal()
{
	FVector3f Long = FVector3f(10.0f, 0.0f, 0.0f).GetClampedToSize(2.0f, 5.0f);
	FVector3f Short = FVector3f(1.0f, 0.0f, 0.0f).GetClampedToSize(2.0f, 5.0f);
	return Long.Equals(FVector3f(5.0f, 0.0f, 0.0f)) && Short.Equals(FVector3f(2.0f, 0.0f, 0.0f));
}
/** @end */
/**
 * @begin get-clamped-to-size-2-d
 * @summary tolerance is KINDA_SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveGetClampedToSize2DNominal
 * @summary tolerance is KINDA_SMALL_NUMBER.
 * @covers FVector3f.get-clamped-to-size-2-d
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

bool ObserveGetClampedToSize2DNominal()
{
	FVector3f Clamped = FVector3f(10.0f, 0.0f, 7.0f).GetClampedToSize2D(0.0f, 5.0f);
	return Clamped.Equals(FVector3f(5.0f, 0.0f, 7.0f));
}
/** @end */
/**
 * @begin get-clamped-to-max-size
 * @summary tolerance is KINDA_SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveGetClampedToMaxSizeNominal
 * @summary tolerance is KINDA_SMALL_NUMBER.
 * @covers FVector3f.get-clamped-to-max-size
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

bool ObserveGetClampedToMaxSizeNominal()
{
	FVector3f Long = FVector3f(10.0f, 0.0f, 0.0f).GetClampedToMaxSize(5.0f);
	FVector3f Short = FVector3f(1.0f, 0.0f, 0.0f).GetClampedToMaxSize(5.0f);
	return Long.Equals(FVector3f(5.0f, 0.0f, 0.0f)) && Short.Equals(FVector3f(1.0f, 0.0f, 0.0f));
}
/** @end */
/**
 * @begin get-clamped-to-max-size-2-d
 * @summary tolerance is KINDA_SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveGetClampedToMaxSize2DNominal
 * @summary tolerance is KINDA_SMALL_NUMBER.
 * @covers FVector3f.get-clamped-to-max-size-2-d
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

bool ObserveGetClampedToMaxSize2DNominal()
{
	FVector3f Clamped = FVector3f(10.0f, 0.0f, 7.0f).GetClampedToMaxSize2D(5.0f);
	return Clamped.Equals(FVector3f(5.0f, 0.0f, 7.0f));
}
/** @end */
/**
 * @begin is-uniform
 * @summary tolerance is KINDA_SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveIsUniformNominal
 * @summary tolerance is KINDA_SMALL_NUMBER.
 * @covers FVector3f.is-uniform
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

bool ObserveIsUniformNominal()
{
	return FVector3f(2.0f, 2.0f, 2.0f).IsUniform() && !FVector3f(2.0f, 2.0f, 3.0f).IsUniform();
}
/** @end */
/**
 * @begin get-safe-normal
 * @summary tolerance is KINDA_SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveGetSafeNormalNominal
 * @summary tolerance is KINDA_SMALL_NUMBER.
 * @covers FVector3f.get-safe-normal
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

bool ObserveGetSafeNormalNominal()
{
	FVector3f Unit = FVector3f(0.0f, 0.0f, 2.0f).GetSafeNormal();
	FVector3f ZeroDefault = FVector3f::ZeroVector.GetSafeNormal();
	FVector3f ZeroFallback = FVector3f::ZeroVector.GetSafeNormal(__SMALL_NUMBER_flt, FVector3f::OneVector);
	return Unit.Equals(FVector3f(0.0f, 0.0f, 1.0f)) && ZeroDefault.IsZero() && ZeroFallback == FVector3f::OneVector;
}
/** @end */
/**
 * @begin get-safe-normal-2-d
 * @summary tolerance is KINDA_SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveGetSafeNormal2DNominal
 * @summary tolerance is KINDA_SMALL_NUMBER.
 * @covers FVector3f.get-safe-normal-2-d
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

bool ObserveGetSafeNormal2DNominal()
{
	FVector3f UnitXY = FVector3f(3.0f, 4.0f, 9.0f).GetSafeNormal2D();
	FVector3f ZeroXY = FVector3f(0.0f, 0.0f, 5.0f).GetSafeNormal2D();
	FVector3f Fallback = FVector3f(0.0f, 0.0f, 5.0f).GetSafeNormal2D(__SMALL_NUMBER_flt, FVector3f::OneVector);
	return UnitXY.Equals(FVector3f(0.6f, 0.8f, 0.0f)) && ZeroXY.IsZero() && Fallback == FVector3f::OneVector;
}
/** @end */
/**
 * @begin find-best-axis-vectors
 * @summary tolerance is KINDA_SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveFindBestAxisVectorsNominal
 * @summary tolerance is KINDA_SMALL_NUMBER.
 * @covers FVector3f.find-best-axis-vectors
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

bool ObserveFindBestAxisVectorsNominal()
{
	FVector3f Axis1;
	FVector3f Axis2;
	FVector3f::UpVector.FindBestAxisVectors(Axis1, Axis2);
	bool bUnit = Axis1.IsNormalized() && Axis2.IsNormalized();
	bool bPerpToUp = Axis1.Orthogonal(FVector3f::UpVector) && Axis2.Orthogonal(FVector3f::UpVector);
	bool bPerpToEachOther = Axis1.Orthogonal(Axis2);
	return bUnit && bPerpToUp && bPerpToEachOther;
}
/** @end */
/**
 * @begin contains-na-n
 * @summary tolerance is KINDA_SMALL_NUMBER.
 * @topic Unreal
 */
/**
 * @function ObserveContainsNaNNominal
 * @summary tolerance is KINDA_SMALL_NUMBER.
 * @covers FVector3f.contains-na-n
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: Unsafe

bool ObserveContainsNaNNominal()
{
	bool bFinite = !FVector3f(1.0f, 2.0f, 3.0f).ContainsNaN();
	FVector3f MaybeNonFinite = FVector3f::ZeroVector.GetUnsafeNormal();
	bool bNonFinite = MaybeNonFinite.ContainsNaN();
	return bFinite && bNonFinite;
}
/** @end */
/**
 * @begin is-unit
 * @summary __KINDA_SMALL_NUMBER_flt.
 * @topic Unreal
 */
/**
 * @function ObserveIsUnitNominal
 * @summary __KINDA_SMALL_NUMBER_flt.
 * @covers FVector3f.is-unit
 * @inputs FVector3f values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsUnitNominal()
{
	bool bUnit = FVector3f(1.0f, 0.0f, 0.0f).IsUnit();
	bool bScaled = FVector3f(2.0f, 0.0f, 0.0f).IsUnit();
	bool bZero = FVector3f(0.0f, 0.0f, 0.0f).IsUnit();
	bool bWide = FVector3f(1.0f, 0.0f, 0.0f).IsUnit(1.0f);
	return bUnit && !bScaled && !bZero && bWide;
}
/** @end */
