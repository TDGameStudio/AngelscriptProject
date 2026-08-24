// Theme: World.Component. WorldStory: component sweep/overlap FunctionLibrary smoke.
// C++: AngelscriptWorldCollisionFunctionLibraryComponentTests.cpp::ComponentQueryEntrypointSmoke
// Runner builds BlockingBox/OverlapBox/QueryBox then ExpectGlobalReturn
// VerifyComponentQueryEntrypointSmoke(QueryBox)==1 and VerifyNullComponentQueryGuards()==1.
// sha256=d7e85911deb2a00e52c147f388cca635ae21f5e9e6389ebc180a93e186a3b3e1; lines 64-128.
// Extra: empty Hits/Overlaps Num()==0; VerifyNullComponentQueryGuards is the nullptr vector.
// FixtureIsolated. Runner owns World teardown.

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

	return bSweep
		&& bOverlap
		&& Hits.Num() > 0
		&& Overlaps.Num() > 0 ? 1 : 0;
}

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

	return !bSweep
		&& !bOverlap
		&& Hits.Num() == 0
		&& Overlaps.Num() == 0 ? 1 : 0;
}

int Observe_ComponentQuery_EmptyArrays()
{
	TArray<FHitResult> Hits;
	TArray<FOverlapResult> Overlaps;
	return Hits.Num() == 0 && Overlaps.Num() == 0 ? 1 : 0;
}
