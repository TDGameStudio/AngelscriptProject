/**
 * @version v1
 * @summary Observe FVector axis and identity constants.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FVector axis and identity constants.
 * @topic Baseline
 */
// BackwardVector; RightVector; LeftVector.
// Inputs: Each published constant compared against explicit component triples.
// Expected observations: Zero is (0,0,0). One is (1,1,1). Up is (0,0,1).
// Down is (0,0,-1). Forward is (1,0,0). Backward is (-1,0,0). Right is
// (0,1,0). Left is (0,-1,0).
// Boundary/ownership: Constants are shared values, not factory functions.

namespace TS_FVector_NamespaceAndGlobalFunctions_01
{
	// FVector::ZeroVector is (0,0,0). Shared constant.
	bool Observe_Surface087_Nominal()
	{
		return FVector::ZeroVector.X == 0.0 && FVector::ZeroVector.Y == 0.0 && FVector::ZeroVector.Z == 0.0;
	}

	// FVector::OneVector is (1,1,1). Shared constant.
	bool Observe_Surface088_Nominal()
	{
		return FVector::OneVector.X == 1.0 && FVector::OneVector.Y == 1.0 && FVector::OneVector.Z == 1.0;
	}

	// FVector::UpVector is (0,0,1). Shared constant.
	bool Observe_Surface089_Nominal()
	{
		return FVector::UpVector.X == 0.0 && FVector::UpVector.Y == 0.0 && FVector::UpVector.Z == 1.0;
	}

	// FVector::DownVector is (0,0,-1). Shared constant.
	bool Observe_Surface090_Nominal()
	{
		return FVector::DownVector.X == 0.0 && FVector::DownVector.Y == 0.0 && FVector::DownVector.Z == -1.0;
	}

	// FVector::ForwardVector is (1,0,0). Shared constant.
	bool Observe_Surface091_Nominal()
	{
		return FVector::ForwardVector.X == 1.0 && FVector::ForwardVector.Y == 0.0 && FVector::ForwardVector.Z == 0.0;
	}

	// FVector::BackwardVector is (-1,0,0). Shared constant.
	bool Observe_Surface092_Nominal()
	{
		return FVector::BackwardVector.X == -1.0 && FVector::BackwardVector.Y == 0.0 && FVector::BackwardVector.Z == 0.0;
	}

	// FVector::RightVector is (0,1,0). Shared constant.
	bool Observe_Surface093_Nominal()
	{
		return FVector::RightVector.X == 0.0 && FVector::RightVector.Y == 1.0 && FVector::RightVector.Z == 0.0;
	}

	// FVector::LeftVector is (0,-1,0). Shared constant.
	bool Observe_Surface094_Nominal()
	{
		return FVector::LeftVector.X == 0.0 && FVector::LeftVector.Y == -1.0 && FVector::LeftVector.Z == 0.0;
	}
}
/** @end */
