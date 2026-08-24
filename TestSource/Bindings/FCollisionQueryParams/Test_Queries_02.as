// Purpose: Observe the shared engine default collision-response container.
// AS-facing API: const FCollisionResponseContainer& FCollisionResponseContainer::GetDefaultResponseContainer();
// Inputs: Two reads of GetDefaultResponseContainer, compared with a local
// ECR_Ignore container.
// Expected observations: Repeated reads compare equal. The default container
// is not identical to an all-ignore container. Visibility is ECR_Block.
// Boundary/ownership: The returned reference is the shared engine default.
// Do not assume exclusive ownership.

namespace TS_FCollisionQueryParams_Queries_02
{
	bool Observe_GetDefaultResponseContainer_Nominal()
	{
		FCollisionResponseContainer First = FCollisionResponseContainer::GetDefaultResponseContainer();
		FCollisionResponseContainer Second = FCollisionResponseContainer::GetDefaultResponseContainer();
		FCollisionResponseContainer IgnoreAll(ECollisionResponse::ECR_Ignore);
		ECollisionResponse Visibility = First.GetResponse(ECollisionChannel::Visibility);
		return First == Second && !(First == IgnoreAll) && Visibility == ECollisionResponse::ECR_Block;
	}
}
