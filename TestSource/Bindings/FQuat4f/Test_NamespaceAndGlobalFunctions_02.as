// Purpose: Observe FQuat4f Squad interpolation and tangent writeback.
// AS-facing API: FQuat4f FQuat4f::Squad(const FQuat4f& Quat1, const FQuat4f& Tang1, const FQuat4f& Quat2, const FQuat4f& Tang2, float32 Alpha);
// FQuat4f FQuat4f::SquadFullPath(const FQuat4f& Quat1, const FQuat4f& Tang1, const FQuat4f& Quat2, const FQuat4f& Tang2, float32 Alpha);
// void FQuat4f::CalcTangents(const FQuat4f& PrevP, const FQuat4f& P, const FQuat4f& NextP, float32 Tension, FQuat4f& OutTan);
// Inputs: Identity and yaw 90, Identity tangents, Alpha 0 and 1, Tension 0,
// and OutTan seeded to (0,0,0,2) before CalcTangents.
// Expected observations: Squad at 0 is Quat1 and at 1 is Quat2. SquadFullPath
// matches the same endpoints. CalcTangents overwrites OutTan.
// Boundary/ownership: Interpolation returns new quaternions. OutTan is a
// writeback; Tension controls curve tightness.

namespace TS_FQuat4f_NamespaceAndGlobalFunctions_02
{
	bool Observe_Squad_Nominal()
	{
		FQuat4f From = FQuat4f::Identity;
		FQuat4f To = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
		FQuat4f Start = FQuat4f::Squad(From, FQuat4f::Identity, To, FQuat4f::Identity, 0.0);
		FQuat4f End = FQuat4f::Squad(From, FQuat4f::Identity, To, FQuat4f::Identity, 1.0);
		return Start.Equals(From) && End.Equals(To);
	}

	bool Observe_SquadFullPath_Nominal()
	{
		FQuat4f From = FQuat4f::Identity;
		FQuat4f To = FQuat4f(FRotator3f(0.0, 90.0, 0.0));
		FQuat4f Start = FQuat4f::SquadFullPath(From, FQuat4f::Identity, To, FQuat4f::Identity, 0.0);
		FQuat4f End = FQuat4f::SquadFullPath(From, FQuat4f::Identity, To, FQuat4f::Identity, 1.0);
		return Start.Equals(From) && End.Equals(To);
	}

	bool Observe_CalcTangents_Nominal()
	{
		FQuat4f OutTan(0.0, 0.0, 0.0, 2.0);
		FQuat4f::CalcTangents(FQuat4f::Identity, FQuat4f::Identity, FQuat4f(FRotator3f(0.0, 90.0, 0.0)), 0.0, OutTan);
		return OutTan.Size() > 0.0 && OutTan.W != 2.0;
	}
}
