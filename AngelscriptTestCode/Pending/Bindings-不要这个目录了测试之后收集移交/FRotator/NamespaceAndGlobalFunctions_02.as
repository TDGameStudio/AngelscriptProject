/**
 * @version v1
 * @summary Observe remaining two-axis FRotator::MakeFrom orthonormal builders.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe remaining two-axis FRotator::MakeFrom orthonormal builders.
 * @topic Baseline
 */
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
/** @end */
