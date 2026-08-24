// Purpose: Observe remaining two-axis FRotator::MakeFrom orthonormal builders.
// AS-facing API: FRotator::MakeFromYZ; FRotator::MakeFromZX; FRotator::MakeFromZY.
// Inputs: World Right, Up, and Forward axes in the listed priority order.
// Expected observations: Each pairing of world axes is nearly ZeroRotator.
// Boundary/ownership: The first named axis is the primary direction. Results
// are new rotators.

namespace TS_FRotator_NamespaceAndGlobalFunctions_02
{
	bool Observe_MakeFromYZ_Nominal()
	{
		FRotator FromYZ = FRotator::MakeFromYZ(FVector::RightVector, FVector::UpVector);
		return FromYZ.Equals(FRotator::ZeroRotator);
	}

	bool Observe_MakeFromZX_Nominal()
	{
		FRotator FromZX = FRotator::MakeFromZX(FVector::UpVector, FVector::ForwardVector);
		return FromZX.Equals(FRotator::ZeroRotator);
	}

	bool Observe_MakeFromZY_Nominal()
	{
		FRotator FromZY = FRotator::MakeFromZY(FVector::UpVector, FVector::RightVector);
		return FromZY.Equals(FRotator::ZeroRotator);
	}
}
