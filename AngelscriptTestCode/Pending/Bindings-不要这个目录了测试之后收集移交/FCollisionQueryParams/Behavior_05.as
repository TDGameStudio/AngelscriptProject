/**
 * @version v1
 * @summary Observe object-query IgnoreMask, DoVerify, response-container construction, and ReplaceChannels. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe object-query IgnoreMask, DoVerify, response-container construction, and ReplaceChannels. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// void FCollisionObjectQueryParams.DoVerify() const;
// FCollisionResponseContainer Responses(ECollisionResponse DefaultResponse);
// bool FCollisionResponseContainer.ReplaceChannels(ECollisionResponse OldResponse, ECollisionResponse NewResponse);
// Inputs: IgnoreMask 29, a valid WorldStatic object query, ECR_Ignore
// container, replace Ignore with Block, then Block with Overlap, then a
// no-op replace of a missing OldResponse.
// Expected observations: IgnoreMask round-trips. DoVerify returns on a valid
// bitfield. Constructed Ignore container GetResponse is Ignore. ReplaceChannels
// returns true when any channel changes and false when none match.
// Boundary/ownership: DoVerify is an engine debug check. ReplaceChannels
// mutates matching channels only.

namespace TS_FCollisionQueryParams_Behavior_05
{
	// FCollisionObjectQueryParams.IgnoreMask default 0, assigned 29, then 0. Oracle: 0 then 29 then 0. Packed extra filter bits.
	bool Observe_Surface086_Nominal()
	{
		FCollisionObjectQueryParams Params;
		uint8 DefaultMask = Params.IgnoreMask;
		Params.IgnoreMask = 29;
		uint8 Assigned = Params.IgnoreMask;
		Params.IgnoreMask = 0;
		return DefaultMask == 0 && Assigned == 29 && Params.IgnoreMask == 0;
	}

	// FCollisionObjectQueryParams.DoVerify on empty, WorldStatic, and AllObjects. Oracle: empty invalid, WorldStatic and AllObjects valid. Debug check does not change validity.
	bool Observe_DoVerify_Nominal()
	{
		FCollisionObjectQueryParams Empty;
		Empty.DoVerify();
		FCollisionObjectQueryParams WorldStatic(ECollisionChannel::WorldStatic);
		WorldStatic.DoVerify();
		FCollisionObjectQueryParams AllObjects(ECollisionObjectQueryInitType::AllObjects);
		AllObjects.DoVerify();
		return !Empty.IsValid() && WorldStatic.IsValid() && AllObjects.IsValid();
	}

	// FCollisionResponseContainer(ECR_Ignore/Block/Overlap). Oracle: Visibility Ignore, WorldStatic Block, Camera Overlap. Per-channel default.
	bool Observe_Responses_Nominal()
	{
		FCollisionResponseContainer IgnoreAll(ECollisionResponse::ECR_Ignore);
		ECollisionResponse Visibility = IgnoreAll.GetResponse(ECollisionChannel::Visibility);
		FCollisionResponseContainer BlockAll(ECollisionResponse::ECR_Block);
		ECollisionResponse WorldStatic = BlockAll.GetResponse(ECollisionChannel::WorldStatic);
		FCollisionResponseContainer OverlapAll(ECollisionResponse::ECR_Overlap);
		ECollisionResponse Camera = OverlapAll.GetResponse(ECollisionChannel::Camera);
		return Visibility == ECollisionResponse::ECR_Ignore && WorldStatic == ECollisionResponse::ECR_Block && Camera == ECollisionResponse::ECR_Overlap;
	}

	// ReplaceChannels Ignore->Block then Block->Overlap then missing Block. Oracle: first two true, Visibility/WorldStatic updated, missing false. Mutates matching channels.
	bool Observe_ReplaceChannels_Nominal()
	{
		FCollisionResponseContainer Responses(ECollisionResponse::ECR_Ignore);
		bool bReplacedIgnore = Responses.ReplaceChannels(ECollisionResponse::ECR_Ignore, ECollisionResponse::ECR_Block);
		ECollisionResponse AfterBlock = Responses.GetResponse(ECollisionChannel::Visibility);
		bool bReplacedBlock = Responses.ReplaceChannels(ECollisionResponse::ECR_Block, ECollisionResponse::ECR_Overlap);
		ECollisionResponse AfterOverlap = Responses.GetResponse(ECollisionChannel::WorldStatic);
		bool bMissingOld = Responses.ReplaceChannels(ECollisionResponse::ECR_Block, ECollisionResponse::ECR_Ignore);
		return bReplacedIgnore && AfterBlock == ECollisionResponse::ECR_Block && bReplacedBlock && AfterOverlap == ECollisionResponse::ECR_Overlap && !bMissingOld;
	}
}
/** @end */
