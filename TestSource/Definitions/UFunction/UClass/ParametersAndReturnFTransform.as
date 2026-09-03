/**
 * FTransform compose, location, &out, and TransformPosition. ComposeTransforms
 * of T1*T2 equals the product. GetTransformLocation of (50,100,150) returns
 * that location. WriteTransformOut writes (10,20,30). TransformPoint of
 * (100,0,0) on (10,0,0) is (110,0,0). Identity is empty, and a nullptr actor
 * is the empty handle.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.ParametersAndReturnFTransform
 * @Harness UClass
 * @Tag Definitions.UFunction.ParametersAndReturnFTransform
 * @Provenance Theme: Definitions.UFunction. WorldStory FTransform compose, location, &out, TransformPosition.
 * @Provenance C++: AngelscriptCoverageFTransformFunctionTests.cpp::UFunctionParametersAndReturn
 * @Provenance Oracle: ComposeTransforms T1*T2; GetTransformLocation (50,100,150); WriteTransformOut (10,20,30); TransformPoint.
 * @Provenance Extra: Identity empty; nullptr actor is the empty handle.
 * @Provenance FixtureIsolated.
 */

UCLASS()
class ACoverageFTransformFunctionActor : AActor
{
	/**
	 * Compose two transforms.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param a First transform
	 * @Param b Second transform
	 * @Inputs a and b
	 * @Return a * b
	 */
	UFUNCTION()
	FTransform ComposeTransforms(FTransform a, FTransform b)
	{
		return a * b;
	}

	/**
	 * Read a transform location.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param t Transform
	 * @Inputs t
	 * @Return t.GetLocation()
	 */
	UFUNCTION()
	FVector GetTransformLocation(FTransform t)
	{
		return t.GetLocation();
	}

	/**
	 * Write FTransform(FVector(10,20,30)) to an out slot.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param result Destination received as FTransform&out
	 * @Inputs an empty out transform
	 * @Return void
	 */
	UFUNCTION()
	void WriteTransformOut(FTransform&out result)
	{
		result = FTransform(FVector(10, 20, 30));
	}

	/**
	 * Transform a point through a transform.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param t Transform
	 * @Param point Point to transform
	 * @Inputs t and point
	 * @Return t.TransformPosition(point)
	 */
	UFUNCTION()
	FVector TransformPoint(FTransform t, FVector point)
	{
		return t.TransformPosition(point);
	}

	/**
	 * Observe compose, location, WriteTransformOut, and TransformPoint.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ComposeTransforms of (100,0,0) and (0,100,0), location (50,100,150), WriteTransformOut, TransformPoint
	 * @Return true when compose, location, out, and moved point match the oracle
	 */
	UFUNCTION()
	bool TransformLiveMatrix()
	{
		FTransform T1 = FTransform(FVector(100, 0, 0));
		FTransform T2 = FTransform(FVector(0, 100, 0));
		FTransform Composed = ComposeTransforms(T1, T2);
		FTransform OutValue = FTransform::Identity;
		WriteTransformOut(OutValue);
		FVector Located = GetTransformLocation(FTransform(FVector(50, 100, 150)));
		FVector Moved = TransformPoint(FTransform(FVector(100, 0, 0)), FVector(10, 0, 0));
		if (!Composed.Equals(T1 * T2, 0.01))
		{
			return false;
		}
		if (!Located.Equals(FVector(50, 100, 150), 0.01))
		{
			return false;
		}
		if (!OutValue.GetLocation().Equals(FVector(10, 20, 30), 0.01))
		{
			return false;
		}
		return Moved.Equals(FVector(110, 0, 0), 0.01);
	}

	/**
	 * Observe Identity location, TransformPoint, and compose.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs Identity location, TransformPoint of (3,4,5), ComposeTransforms(Identity, Identity)
	 * @Return true when location is zero, the point is unchanged, and compose is Identity
	 * @Boundary identity
	 */
	UFUNCTION()
	bool IdentityEmpty()
	{
		FTransform Identity = FTransform::Identity;
		FVector Point = FVector(3, 4, 5);
		if (!GetTransformLocation(Identity).Equals(FVector::ZeroVector, 0.01))
		{
			return false;
		}
		if (!TransformPoint(Identity, Point).Equals(Point, 0.01))
		{
			return false;
		}
		return ComposeTransforms(Identity, Identity).Equals(Identity, 0.01);
	}

	/**
	 * Observe that a null handle of this class is null.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs ACoverageFTransformFunctionActor Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary null handle
	 */
	UFUNCTION()
	bool NullDefaultIsNull()
	{
		ACoverageFTransformFunctionActor Actor = nullptr;
		return Actor == nullptr;
	}
}
