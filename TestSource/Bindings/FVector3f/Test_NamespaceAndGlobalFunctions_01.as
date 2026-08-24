// Purpose: Observe FVector3f axis and identity constants.
// AS-facing API: ZeroVector; OneVector; UpVector; ForwardVector; RightVector.
// Inputs: Each published constant compared against explicit component triples.
// Expected observations: Zero is (0,0,0). One is (1,1,1). Up is (0,0,1).
// Forward is (1,0,0). Right is (0,1,0).
// Boundary/ownership: Constants are shared values, not factory functions.
// Down/Backward/Left are not published on FVector3f.

namespace TS_FVector3f_NamespaceAndGlobalFunctions_01
{
	// FVector3f::ZeroVector is (0,0,0). Shared constant, not a factory.
	bool Observe_Surface083_Nominal()
	{
		return FVector3f::ZeroVector.X == 0.0f && FVector3f::ZeroVector.Y == 0.0f && FVector3f::ZeroVector.Z == 0.0f;
	}

	// FVector3f::OneVector is (1,1,1). Shared constant, not a factory.
	bool Observe_Surface084_Nominal()
	{
		return FVector3f::OneVector.X == 1.0f && FVector3f::OneVector.Y == 1.0f && FVector3f::OneVector.Z == 1.0f;
	}

	// FVector3f::UpVector is (0,0,1). Shared constant, not a factory.
	bool Observe_Surface085_Nominal()
	{
		return FVector3f::UpVector.X == 0.0f && FVector3f::UpVector.Y == 0.0f && FVector3f::UpVector.Z == 1.0f;
	}

	// FVector3f::ForwardVector is (1,0,0). Shared constant, not a factory.
	bool Observe_Surface086_Nominal()
	{
		return FVector3f::ForwardVector.X == 1.0f && FVector3f::ForwardVector.Y == 0.0f && FVector3f::ForwardVector.Z == 0.0f;
	}

	// FVector3f::RightVector is (0,1,0). Shared constant, not a factory.
	bool Observe_Surface087_Nominal()
	{
		return FVector3f::RightVector.X == 0.0f && FVector3f::RightVector.Y == 1.0f && FVector3f::RightVector.Z == 0.0f;
	}
}
