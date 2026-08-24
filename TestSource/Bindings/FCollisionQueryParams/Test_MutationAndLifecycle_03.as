// Purpose: Observe object-query bitfield mutations and response-container
// SetResponse / SetAllChannels / CreateMinContainer.
// AS-facing API: void FCollisionObjectQueryParams.AddObjectTypesToQuery(ECollisionChannel QueryChannel);
// void FCollisionObjectQueryParams.RemoveObjectTypesToQuery(ECollisionChannel QueryChannel);
// void FCollisionObjectQueryParams.SetObjectTypesToQuery(int64 InObjectTypesToQuery);
// bool FCollisionResponseContainer.SetResponse(ECollisionChannel Channel, ECollisionResponse NewResponse);
// bool FCollisionResponseContainer.SetAllChannels(ECollisionResponse NewResponse);
// FCollisionResponseContainer FCollisionResponseContainer::CreateMinContainer(const FCollisionResponseContainer& A, const FCollisionResponseContainer& B);
// Inputs: Empty object query, WorldStatic / Pawn / Camera,
// bitfield 0 and 1, ECR_Ignore/Block/Overlap, Visibility vs WorldStatic.
// Expected observations: Add makes IsValid true. Remove WorldStatic after
// adding only that channel makes IsValid false. SetObjectTypesToQuery(0)
// clears. SetResponse returns true then false on a repeat. SetAllChannels
// returns true when the container changes. CreateMinContainer yields the
// least blocking response per channel.
// Boundary/ownership: Bitfields replace the object-query mask. CreateMinContainer
// returns a new container.

namespace TS_FCollisionQueryParams_MutationAndLifecycle_03
{
	bool Observe_AddObjectTypesToQuery_Nominal()
	{
		FCollisionObjectQueryParams Params;
		bool bEmptyInvalid = Params.IsValid();
		Params.AddObjectTypesToQuery(ECollisionChannel::WorldStatic);
		bool bWorldStaticValid = Params.IsValid();
		Params.AddObjectTypesToQuery(ECollisionChannel::Pawn);
		int64 Bits = Params.GetObjectTypesToQuery();
		return !bEmptyInvalid && bWorldStaticValid && Bits != 0;
	}

	bool Observe_RemoveObjectTypesToQuery_Nominal()
	{
		FCollisionObjectQueryParams Params;
		Params.AddObjectTypesToQuery(ECollisionChannel::WorldStatic);
		Params.AddObjectTypesToQuery(ECollisionChannel::Pawn);
		Params.RemoveObjectTypesToQuery(ECollisionChannel::Pawn);
		bool bStillValid = Params.IsValid();
		Params.RemoveObjectTypesToQuery(ECollisionChannel::WorldStatic);
		bool bEmptyAfterRemove = Params.IsValid();
		return bStillValid && !bEmptyAfterRemove;
	}

	bool Observe_SetObjectTypesToQuery_Nominal()
	{
		FCollisionObjectQueryParams Params;
		Params.SetObjectTypesToQuery(1);
		int64 One = Params.GetObjectTypesToQuery();
		bool bOneValid = Params.IsValid();
		Params.SetObjectTypesToQuery(0);
		int64 Zero = Params.GetObjectTypesToQuery();
		bool bZeroInvalid = Params.IsValid();
		return One == 1 && bOneValid && Zero == 0 && !bZeroInvalid;
	}

	bool Observe_SetResponse_Nominal()
	{
		FCollisionResponseContainer Responses(ECollisionResponse::ECR_Ignore);
		bool bChanged = Responses.SetResponse(ECollisionChannel::Visibility, ECollisionResponse::ECR_Block);
		bool bRepeatUnchanged = Responses.SetResponse(ECollisionChannel::Visibility, ECollisionResponse::ECR_Block);
		ECollisionResponse After = Responses.GetResponse(ECollisionChannel::Visibility);
		return bChanged && !bRepeatUnchanged && After == ECollisionResponse::ECR_Block;
	}

	bool Observe_SetAllChannels_Nominal()
	{
		FCollisionResponseContainer Responses(ECollisionResponse::ECR_Ignore);
		bool bChanged = Responses.SetAllChannels(ECollisionResponse::ECR_Block);
		bool bRepeatUnchanged = Responses.SetAllChannels(ECollisionResponse::ECR_Block);
		ECollisionResponse Visibility = Responses.GetResponse(ECollisionChannel::Visibility);
		ECollisionResponse WorldStatic = Responses.GetResponse(ECollisionChannel::WorldStatic);
		return bChanged && !bRepeatUnchanged && Visibility == ECollisionResponse::ECR_Block && WorldStatic == ECollisionResponse::ECR_Block;
	}

	bool Observe_CreateMinContainer_Nominal()
	{
		FCollisionResponseContainer A(ECollisionResponse::ECR_Block);
		A.SetResponse(ECollisionChannel::Visibility, ECollisionResponse::ECR_Overlap);
		A.SetResponse(ECollisionChannel::WorldStatic, ECollisionResponse::ECR_Ignore);
		FCollisionResponseContainer B(ECollisionResponse::ECR_Ignore);
		B.SetResponse(ECollisionChannel::Visibility, ECollisionResponse::ECR_Block);
		FCollisionResponseContainer Min = FCollisionResponseContainer::CreateMinContainer(A, B);
		ECollisionResponse Visibility = Min.GetResponse(ECollisionChannel::Visibility);
		ECollisionResponse WorldStatic = Min.GetResponse(ECollisionChannel::WorldStatic);
		return Visibility == ECollisionResponse::ECR_Overlap && WorldStatic == ECollisionResponse::ECR_Ignore;
	}
}
