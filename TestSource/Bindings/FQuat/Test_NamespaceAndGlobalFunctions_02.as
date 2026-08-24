// Purpose: Observe FQuat full-path slerp, Squad interpolation, and tangent
// writeback.
// AS-facing API: FQuat FQuat::SlerpFullPath(const FQuat& Quat1, const FQuat& Quat2, float64 Slerp);
// FQuat FQuat::Squad(const FQuat& Quat1, const FQuat& Tang1, const FQuat& Quat2, const FQuat& Tang2, float64 Alpha);
// FQuat FQuat::SquadFullPath(const FQuat& Quat1, const FQuat& Tang1, const FQuat& Quat2, const FQuat& Tang2, float64 Alpha);
// void FQuat::CalcTangents(const FQuat& PrevP, const FQuat& P, const FQuat& NextP, float64 Tension, FQuat& OutTan);
// Inputs: Identity and yaw 90, Identity tangents, Alpha/Slerp 0 and 1,
// Tension 0, and OutTan seeded to (0,0,0,2) before CalcTangents.
// Expected observations: SlerpFullPath at 0/1 matches endpoints. Squad at 0
// is Quat1 and at 1 is Quat2. CalcTangents overwrites OutTan.
// Boundary/ownership: Interpolation returns new quaternions. OutTan is a
// writeback; the input quaternions are not mutated.

namespace TS_FQuat_NamespaceAndGlobalFunctions_02
{
	bool Observe_SlerpFullPath_Nominal()
	{
		FQuat From = FQuat::Identity;
		FQuat To = FQuat(FRotator(0, 90, 0));
		FQuat Start = FQuat::SlerpFullPath(From, To, 0.0);
		FQuat End = FQuat::SlerpFullPath(From, To, 1.0);
		return Start.Equals(From) && End.Equals(To);
	}

	bool Observe_Squad_Nominal()
	{
		FQuat From = FQuat::Identity;
		FQuat To = FQuat(FRotator(0, 90, 0));
		FQuat Start = FQuat::Squad(From, FQuat::Identity, To, FQuat::Identity, 0.0);
		FQuat End = FQuat::Squad(From, FQuat::Identity, To, FQuat::Identity, 1.0);
		return Start.Equals(From) && End.Equals(To);
	}

	bool Observe_SquadFullPath_Nominal()
	{
		FQuat From = FQuat::Identity;
		FQuat To = FQuat(FRotator(0, 90, 0));
		FQuat Start = FQuat::SquadFullPath(From, FQuat::Identity, To, FQuat::Identity, 0.0);
		FQuat End = FQuat::SquadFullPath(From, FQuat::Identity, To, FQuat::Identity, 1.0);
		return Start.Equals(From) && End.Equals(To);
	}

	bool Observe_CalcTangents_Nominal()
	{
		FQuat OutTan(0.0, 0.0, 0.0, 2.0);
		FQuat::CalcTangents(FQuat::Identity, FQuat::Identity, FQuat(FRotator(0, 90, 0)), 0.0, OutTan);
		return OutTan.Size() > 0.0 && OutTan.W != 2.0;
	}
}
