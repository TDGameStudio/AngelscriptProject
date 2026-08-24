// Theme: Gameplay.Physics. Value oracle: FCollisionResponseContainer mutate/replace/min/params.
// C++: AngelscriptCoveragePhysicsTests.cpp::CollisionResponseContainerOperations
// Oracle: Run() == 1; PerChannel/AllChannel/Replace/Min/ResponseParams flags true.
// Extra: defaults false. DefaultSafe. Keep UPROPERTY names.

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

		return PerChannelResponsesRoundTripped
			&& AllChannelResponsesRoundTripped
			&& ReplaceResponsesRoundTripped
			&& MinResponseContainerCreated
			&& ResponseParamsConstructed ? 1 : 0;
	}
}

bool Observe_ResponseContainer_Nominal(UCoveragePhysicsResponseContainerHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_CollisionResponseContainerOperations setup: required Harness is null");
	}
	return Harness.Run() == 1;
}

bool Observe_ResponseContainer_Defaults(UCoveragePhysicsResponseContainerHarness Harness)
{
	if (Harness is null)
	{
		throw("Test_CollisionResponseContainerOperations setup: required Harness is null");
	}
	return Harness.PerChannelResponsesRoundTripped == false
		&& Harness.AllChannelResponsesRoundTripped == false
		&& Harness.ReplaceResponsesRoundTripped == false
		&& Harness.MinResponseContainerCreated == false
		&& Harness.ResponseParamsConstructed == false;
}

bool Observe_ResponseContainer_IgnoreDefaultBoundary()
{
	FCollisionResponseContainer Responses(ECollisionResponse::ECR_Ignore);
	return Responses.GetResponse(ECollisionChannel::ECC_Pawn) == ECollisionResponse::ECR_Ignore;
}
