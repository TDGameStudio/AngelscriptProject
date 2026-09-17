/**
 * @version v1
 * @summary Sweep and overlap entrypoints driven from a world collision function library. C++ builds the blocking, overlap and query boxes, then calls both entrypoints by name through ExpectGlobalReturn. The names are part of the.
 * @topic World
 */
/**
 * @version root
 * @summary Sweep and overlap entrypoints driven from a world collision function library. C++ builds the blocking, overlap and query boxes, then calls both entrypoints by name through ExpectGlobalReturn. The names are part of the.
 * @topic Baseline
 */
namespace ComponentTest
{
	/**
	 * Run both query entrypoints against a real query component.
	 *
	 * @Kind Observe
	 * @Covers Component.QueryEntrypointSmoke
	 * @Inputs a query component swept across and overlapped with the built boxes
	 * @Return 1 when both queries report hits and overlaps, otherwise 0
	 * @Param QueryComponent the component to query with
	 */
	UFUNCTION()
	int VerifyComponentQueryEntrypointSmoke(UPrimitiveComponent QueryComponent)
	{
		TArray<FHitResult> Hits;
		TArray<FOverlapResult> Overlaps;

		FComponentQueryParams Params = FComponentQueryParams::DefaultComponentQueryParams;
		Params.AddIgnoredComponent(QueryComponent);

		FCollisionObjectQueryParams ObjectQueryParams;
		ObjectQueryParams.AddObjectTypesToQuery(ECollisionChannel::ECC_WorldDynamic);

		const bool bSweep = System::ComponentSweepMulti(
			Hits,
			QueryComponent,
			FVector(-200.0f, 0.0f, 0.0f),
			FVector(200.0f, 0.0f, 0.0f),
			FQuat::Identity,
			Params);

		const bool bOverlap = System::ComponentOverlapMulti(
			Overlaps,
			QueryComponent,
			FVector(0.0f, 150.0f, 0.0f),
			FQuat::Identity,
			Params,
			ObjectQueryParams);

		if (!bSweep)
		{
			return 0;
		}
		if (!bOverlap)
		{
			return 0;
		}
		if (Hits.Num() <= 0)
		{
			return 0;
		}
		if (Overlaps.Num() <= 0)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Run both query entrypoints with a null component, which must be refused.
	 *
	 * @Kind Observe
	 * @Covers Component.QueryEntrypointSmoke
	 * @Inputs a null query component
	 * @Return 1 when both queries refuse and both arrays stay empty, otherwise 0
	 * @Boundary null query component
	 */
	UFUNCTION()
	int VerifyNullComponentQueryGuards()
	{
		TArray<FHitResult> Hits;
		TArray<FOverlapResult> Overlaps;

		FComponentQueryParams Params = FComponentQueryParams::DefaultComponentQueryParams;
		FCollisionObjectQueryParams ObjectQueryParams;
		ObjectQueryParams.AddObjectTypesToQuery(ECollisionChannel::ECC_WorldDynamic);

		const bool bSweep = System::ComponentSweepMulti(
			Hits,
			nullptr,
			FVector(-200.0f, 0.0f, 0.0f),
			FVector(200.0f, 0.0f, 0.0f),
			FQuat::Identity,
			Params);

		const bool bOverlap = System::ComponentOverlapMulti(
			Overlaps,
			nullptr,
			FVector(0.0f, 150.0f, 0.0f),
			FQuat::Identity,
			Params,
			ObjectQueryParams);

		if (bSweep)
		{
			return 0;
		}
		if (bOverlap)
		{
			return 0;
		}
		if (Hits.Num() != 0)
		{
			return 0;
		}
		if (Overlaps.Num() != 0)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that freshly declared result arrays are empty.
	 *
	 * @Kind Observe
	 * @Covers Component.QueryEntrypointSmoke
	 * @Inputs newly declared hit and overlap arrays
	 * @Return 1 when both are empty, otherwise 0
	 * @Boundary empty arrays
	 */
	UFUNCTION()
	int EmptyArrays()
	{
		TArray<FHitResult> Hits;
		TArray<FOverlapResult> Overlaps;

		if (Hits.Num() != 0)
		{
			return 0;
		}
		if (Overlaps.Num() != 0)
		{
			return 0;
		}
		return 1;
	}
}
/** @end */
