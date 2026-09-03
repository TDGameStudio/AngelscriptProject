/**
 * FCollisionResponseContainer per-channel, all-channel, replace and min operations,
 * plus response-params construction. C++ treats Run() == 1 as the oracle, so the
 * UCLASS, UFUNCTION and UPROPERTY names are part of the contract and are kept
 * verbatim. The observers cover Run, the defaults and an ignore-default container.
 *
 * @Theme Gameplay.Physics
 * @Subject Physics.CollisionResponseContainerOperations
 * @Harness UClass
 * @Tag Gameplay.Physics.CollisionResponseContainerOperations
 * @Provenance Theme: Gameplay.Physics. Value oracle: FCollisionResponseContainer mutate/replace/min/params.
 * @Provenance C++: AngelscriptCoveragePhysicsTests.cpp::CollisionResponseContainerOperations
 * @Provenance Oracle: Run() == 1; PerChannel/AllChannel/Replace/Min/ResponseParams flags true.
 * @Provenance Extra: defaults false. DefaultSafe. Keep UPROPERTY names.
 */

UCLASS()
class UCoveragePhysicsResponseContainerHarness : UObject
{
	UPROPERTY()
	bool PerChannelResponsesRoundTripped = false;

	UPROPERTY()
	bool AllChannelResponsesRoundTripped = false;

	UPROPERTY()
	bool ReplaceResponsesRoundTripped = false;

	UPROPERTY()
	bool MinResponseContainerCreated = false;

	UPROPERTY()
	bool ResponseParamsConstructed = false;

	/**
	 * Mutate per-channel and all-channel responses, replace them, build a min
	 * container and construct response params.
	 *
	 * @Kind Action
	 * @Covers Physics.CollisionResponseContainerOperations
	 * @Inputs none
	 * @Return 1 when PerChannelResponsesRoundTripped, AllChannelResponsesRoundTripped,
	 * ReplaceResponsesRoundTripped, MinResponseContainerCreated and
	 * ResponseParamsConstructed are true, otherwise 0
	 */
	UFUNCTION()
	int Run()
	{
		FCollisionResponseContainer Responses(ECollisionResponse::ECR_Ignore);
		bool bSetVisibility = Responses.SetResponse(ECollisionChannel::ECC_Visibility, ECollisionResponse::ECR_Block);
		bool bSetCamera = Responses.SetResponse(ECollisionChannel::ECC_Camera, ECollisionResponse::ECR_Overlap);
		PerChannelResponsesRoundTripped =
			bSetVisibility
			&& bSetCamera
			&& Responses.GetResponse(ECollisionChannel::ECC_Visibility) == ECollisionResponse::ECR_Block
			&& Responses.GetResponse(ECollisionChannel::ECC_Camera) == ECollisionResponse::ECR_Overlap
			&& Responses.GetResponse(ECollisionChannel::ECC_Pawn) == ECollisionResponse::ECR_Ignore;

		bool bSetAllChannels = Responses.SetAllChannels(ECollisionResponse::ECR_Block);
		AllChannelResponsesRoundTripped =
			bSetAllChannels
			&& Responses.GetResponse(ECollisionChannel::ECC_WorldStatic) == ECollisionResponse::ECR_Block
			&& Responses.GetResponse(ECollisionChannel::ECC_WorldDynamic) == ECollisionResponse::ECR_Block
			&& Responses.GetResponse(ECollisionChannel::ECC_Pawn) == ECollisionResponse::ECR_Block;

		bool bReplacedChannels = Responses.ReplaceChannels(ECollisionResponse::ECR_Block, ECollisionResponse::ECR_Ignore);
		ReplaceResponsesRoundTripped =
			bReplacedChannels
			&& Responses.GetResponse(ECollisionChannel::ECC_WorldStatic) == ECollisionResponse::ECR_Ignore
			&& Responses.GetResponse(ECollisionChannel::ECC_Visibility) == ECollisionResponse::ECR_Ignore
			&& Responses.GetResponse(ECollisionChannel::ECC_Camera) == ECollisionResponse::ECR_Ignore;

		FCollisionResponseContainer OtherResponses(ECollisionResponse::ECR_Overlap);
		FCollisionResponseContainer MinResponses = FCollisionResponseContainer::CreateMinContainer(Responses, OtherResponses);
		MinResponseContainerCreated =
			MinResponses.GetResponse(ECollisionChannel::ECC_Pawn) == ECollisionResponse::ECR_Ignore
			&& MinResponses.GetResponse(ECollisionChannel::ECC_Visibility) == ECollisionResponse::ECR_Ignore;

		FCollisionResponseParams ResponseParams(Responses);
		ResponseParamsConstructed = true;

		if (!PerChannelResponsesRoundTripped)
		{
			return 0;
		}
		if (!AllChannelResponsesRoundTripped)
		{
			return 0;
		}
		if (!ReplaceResponsesRoundTripped)
		{
			return 0;
		}
		if (!MinResponseContainerCreated)
		{
			return 0;
		}
		if (!ResponseParamsConstructed)
		{
			return 0;
		}
		return 1;
	}

	/**
	 * Observe that Run returns 1 after the five flags are written.
	 *
	 * @Kind Observe
	 * @Covers Physics.CollisionResponseContainerOperations
	 * @Inputs none
	 * @Return true when Run returns 1
	 */
	UFUNCTION()
	bool RunReturnsOne()
	{
		return Run() == 1;
	}

	/**
	 * Observe that an untouched harness holds every flag false.
	 *
	 * @Kind Observe
	 * @Covers Physics.CollisionResponseContainerOperations
	 * @Inputs a harness that has not run
	 * @Return true when PerChannelResponsesRoundTripped, AllChannelResponsesRoundTripped,
	 * ReplaceResponsesRoundTripped, MinResponseContainerCreated and
	 * ResponseParamsConstructed are false
	 * @Boundary default value
	 */
	UFUNCTION()
	bool DefaultFalse()
	{
		if (PerChannelResponsesRoundTripped)
		{
			return false;
		}
		if (AllChannelResponsesRoundTripped)
		{
			return false;
		}
		if (ReplaceResponsesRoundTripped)
		{
			return false;
		}
		if (MinResponseContainerCreated)
		{
			return false;
		}
		return ResponseParamsConstructed == false;
	}

	/**
	 * Observe that an ignore-default container reports Ignore on the pawn channel.
	 *
	 * @Kind Observe
	 * @Covers Physics.CollisionResponseContainerOperations
	 * @Inputs a container constructed with ECR_Ignore
	 * @Return true when the pawn channel is ECR_Ignore
	 * @Boundary ignore default
	 */
	UFUNCTION()
	bool IgnoreDefaultBoundary()
	{
		FCollisionResponseContainer Responses(ECollisionResponse::ECR_Ignore);
		return Responses.GetResponse(ECollisionChannel::ECC_Pawn) == ECollisionResponse::ECR_Ignore;
	}
}
