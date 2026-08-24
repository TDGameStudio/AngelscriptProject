// Purpose: Observe FMatrix::Identity() as the engine-default identity matrix.
// AS-facing API: FMatrix FMatrix::Identity();
// Inputs: No arguments. A second Identity() call as an independent copy.
// Expected observations: Identity transforms (1,2,3) to (1,2,3) with W=1.
// A second Identity() produces the same transform. Default construction is
// not used here; Identity() is the published identity factory.
// Boundary/ownership: Identity() returns a new matrix value. It is not a
// shared FMatrix::Identity field.

namespace TS_FMatrix_NamespaceAndGlobalFunctions_01
{
	bool Observe_Identity_Nominal()
	{
		FMatrix Identity = FMatrix::Identity();
		FMatrix Again = FMatrix::Identity();
		FVector4 Position = Identity.TransformPosition(FVector(1, 2, 3));
		FVector4 Repeated = Again.TransformPosition(FVector(1, 2, 3));
		return Position.X == 1.0 && Position.Y == 2.0 && Position.Z == 3.0 && Position.W == 1.0 && Repeated.X == 1.0 && Repeated.W == 1.0;
	}
}
