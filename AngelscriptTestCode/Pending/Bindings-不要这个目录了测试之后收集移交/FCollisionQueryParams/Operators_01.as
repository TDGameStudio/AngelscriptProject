/**
 * @version v1
 * @summary Observe FCollisionResponseContainer equality across every channel.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FCollisionResponseContainer equality across every channel.
 * @topic Baseline
 */
// ECR_Block, and a third identical to the mutated container.
// Expected observations: Identical ignore containers compare true. Ignore vs
// Block on Visibility compares false. A matching copy compares true.
// Boundary/ownership: == compares every per-channel collision response.
// Equality does not mutate either container.

namespace TS_FCollisionQueryParams_Operators_01
{
	bool Observe_Equality_Nominal()
	{
		FCollisionResponseContainer Left(ECollisionResponse::ECR_Ignore);
		FCollisionResponseContainer Right(ECollisionResponse::ECR_Ignore);
		bool bSame = Left == Right;
		Left.SetResponse(ECollisionChannel::Visibility, ECollisionResponse::ECR_Block);
		bool bDifferent = Left == Right;
		FCollisionResponseContainer Copy(ECollisionResponse::ECR_Ignore);
		Copy.SetResponse(ECollisionChannel::Visibility, ECollisionResponse::ECR_Block);
		bool bCopyMatches = Left == Copy;
		return bSame && !bDifferent && bCopyMatches;
	}
}
/** @end */
