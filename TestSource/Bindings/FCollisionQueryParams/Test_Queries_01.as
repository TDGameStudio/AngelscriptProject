// Purpose: Observe ignored-id getters, object-query bitfields, validity, the
// overlap-filter mapping, and per-channel responses.
// Runner owns the Actor fixture used to populate ignore lists.
// AS-facing API: TArray<uint32> FCollisionQueryParams.GetIgnoredComponents() const;
// TArray<uint32> FCollisionQueryParams.GetIgnoredActors() const;
// TArray<uint32> FComponentQueryParams.GetIgnoredComponents() const;
// TArray<uint32> FComponentQueryParams.GetIgnoredActors() const;
// int64 FCollisionObjectQueryParams.GetObjectTypesToQuery() const;
// int64 FCollisionObjectQueryParams.GetQueryBitfield64() const;
// bool FCollisionObjectQueryParams.IsValid() const;
// bool FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel QueryChannel);
// ECollisionObjectQueryInitType FCollisionObjectQueryParams::GetCollisionChannelFromOverlapFilter(EOverlapFilterOption Filter);
// ECollisionResponse FCollisionResponseContainer.GetResponse(ECollisionChannel Channel) const;
// Inputs: Empty params, AddIgnoredActor/Component with runner-owned Actor and
// IgnoreComponent, empty vs AllObjects object query, WorldStatic,
// Visibility, OverlapFilter_All/StaticOnly/DynamicOnly, and ECR_Ignore
// vs ECR_Block on Visibility.
// Expected observations: Empty ignore arrays have Num 0. Added IDs have Num
// 1. Empty object query IsValid is false; AllObjects is true. WorldStatic is
// a valid object query; Visibility is not. OverlapFilter_All maps to
// AllObjects. GetResponse matches the constructed default.
// Boundary/ownership: Ignored arrays return stored unique IDs. IsValidObjectQuery
// is a namespace helper. SetupOwner=Runner. CleanupOwner=Runner.

namespace TS_FCollisionQueryParams_Queries_01
{
	bool Observe_GetIgnoredComponents_Nominal(UPrimitiveComponent IgnoreComponent)
	{
		if (IgnoreComponent is null)
		{
			throw("TS_FCollisionQueryParams_Queries_01 setup: required IgnoreComponent is null");
		}
		FCollisionQueryParams QueryParams;
		TArray<uint32> EmptyQuery = QueryParams.GetIgnoredComponents();
		QueryParams.AddIgnoredComponent(IgnoreComponent);
		TArray<uint32> QueryIds = QueryParams.GetIgnoredComponents();

		FComponentQueryParams ComponentParams;
		TArray<uint32> EmptyComponent = ComponentParams.GetIgnoredComponents();
		ComponentParams.AddIgnoredComponent(IgnoreComponent);
		TArray<uint32> ComponentIds = ComponentParams.GetIgnoredComponents();
		return EmptyQuery.Num() == 0 && QueryIds.Num() == 1 && EmptyComponent.Num() == 0 && ComponentIds.Num() == 1;
	}

	bool Observe_GetIgnoredActors_Nominal(AActor Actor)
	{
		if (Actor is null)
		{
			throw("TS_FCollisionQueryParams_Queries_01 setup: required Actor is null");
		}
		FCollisionQueryParams QueryParams;
		TArray<uint32> EmptyQuery = QueryParams.GetIgnoredActors();
		QueryParams.AddIgnoredActor(Actor);
		TArray<uint32> QueryIds = QueryParams.GetIgnoredActors();

		FComponentQueryParams ComponentParams;
		TArray<uint32> EmptyComponent = ComponentParams.GetIgnoredActors();
		ComponentParams.AddIgnoredActor(Actor);
		TArray<uint32> ComponentIds = ComponentParams.GetIgnoredActors();
		return EmptyQuery.Num() == 0 && QueryIds.Num() == 1 && EmptyComponent.Num() == 0 && ComponentIds.Num() == 1;
	}

	bool Observe_GetObjectTypesToQuery_Nominal()
	{
		FCollisionObjectQueryParams Empty;
		int64 EmptyBits = Empty.GetObjectTypesToQuery();
		FCollisionObjectQueryParams AllObjects(ECollisionObjectQueryInitType::AllObjects);
		int64 AllBits = AllObjects.GetObjectTypesToQuery();
		return EmptyBits == 0 && AllBits != 0;
	}

	bool Observe_GetQueryBitfield64_Nominal()
	{
		FCollisionObjectQueryParams Empty;
		int64 EmptyBits = Empty.GetQueryBitfield64();
		FCollisionObjectQueryParams WorldStatic(ECollisionChannel::WorldStatic);
		int64 WorldStaticBits = WorldStatic.GetQueryBitfield64();
		return EmptyBits == 0 && WorldStaticBits != 0;
	}

	bool Observe_IsValid_Nominal()
	{
		FCollisionObjectQueryParams Empty;
		bool bEmptyInvalid = Empty.IsValid();
		FCollisionObjectQueryParams WorldStatic(ECollisionChannel::WorldStatic);
		bool bWorldStaticValid = WorldStatic.IsValid();
		FCollisionObjectQueryParams AllObjects(ECollisionObjectQueryInitType::AllObjects);
		bool bAllObjectsValid = AllObjects.IsValid();
		return !bEmptyInvalid && bWorldStaticValid && bAllObjectsValid;
	}

	bool Observe_IsValidObjectQuery_Nominal()
	{
		bool bWorldStatic = FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::WorldStatic);
		bool bPawn = FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::Pawn);
		bool bVisibility = FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::Visibility);
		bool bCamera = FCollisionObjectQueryParams::IsValidObjectQuery(ECollisionChannel::Camera);
		return bWorldStatic && bPawn && !bVisibility && !bCamera;
	}

	bool Observe_GetCollisionChannelFromOverlapFilter_Nominal()
	{
		ECollisionObjectQueryInitType All = FCollisionObjectQueryParams::GetCollisionChannelFromOverlapFilter(EOverlapFilterOption::OverlapFilter_All);
		ECollisionObjectQueryInitType DynamicOnly = FCollisionObjectQueryParams::GetCollisionChannelFromOverlapFilter(EOverlapFilterOption::OverlapFilter_DynamicOnly);
		ECollisionObjectQueryInitType StaticOnly = FCollisionObjectQueryParams::GetCollisionChannelFromOverlapFilter(EOverlapFilterOption::OverlapFilter_StaticOnly);
		return All == ECollisionObjectQueryInitType::AllObjects && DynamicOnly == ECollisionObjectQueryInitType::AllDynamicObjects && StaticOnly == ECollisionObjectQueryInitType::AllStaticObjects;
	}

	bool Observe_GetResponse_Nominal()
	{
		FCollisionResponseContainer IgnoreAll(ECollisionResponse::ECR_Ignore);
		ECollisionResponse VisibilityIgnore = IgnoreAll.GetResponse(ECollisionChannel::Visibility);
		IgnoreAll.SetResponse(ECollisionChannel::Visibility, ECollisionResponse::ECR_Block);
		ECollisionResponse VisibilityBlock = IgnoreAll.GetResponse(ECollisionChannel::Visibility);
		ECollisionResponse WorldStatic = IgnoreAll.GetResponse(ECollisionChannel::WorldStatic);
		return VisibilityIgnore == ECollisionResponse::ECR_Ignore && VisibilityBlock == ECollisionResponse::ECR_Block && WorldStatic == ECollisionResponse::ECR_Ignore;
	}
}
