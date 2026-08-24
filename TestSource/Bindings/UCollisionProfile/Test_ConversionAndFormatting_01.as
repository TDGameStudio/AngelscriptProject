// Purpose: Observe UCollisionProfile conversions among collision channels,
// object-query types, and trace-query types, including a bad index.
// AS-facing API: ECollisionChannel UCollisionProfile::ConvertToCollisionChannel(bool TraceType, int32 Index);
// EObjectTypeQuery UCollisionProfile::ConvertToObjectType(ECollisionChannel CollisionChannel);
// ETraceTypeQuery UCollisionProfile::ConvertToTraceType(ECollisionChannel CollisionChannel);
// Inputs: ECollisionChannel::WorldStatic, ECollisionChannel::WorldDynamic,
// ECollisionChannel::Visibility, ECollisionChannel::Camera, TraceType true/false,
// and index -1 as the invalid specifier.
// Expected observations: ConvertToObjectType(WorldStatic) round-trips through
// ConvertToCollisionChannel(false, Index). ConvertToTraceType(Visibility)
// round-trips through ConvertToCollisionChannel(true, Index). Camera and
// WorldDynamic remain distinct from those sources.
// Boundary/ownership: Enumerator names come from the active profile, not ECC_
// prefixes. The profile singleton owns the mapping. Invalid Index is the
// expected-failure path.

namespace TS_UCollisionProfile_ConversionAndFormatting_01
{
	bool Observe_ConvertToCollisionChannel_Nominal()
	{
		EObjectTypeQuery WorldStaticObject = UCollisionProfile::ConvertToObjectType(ECollisionChannel::WorldStatic);
		ECollisionChannel FromObject = UCollisionProfile::ConvertToCollisionChannel(false, int32(WorldStaticObject));
		ETraceTypeQuery VisibilityTrace = UCollisionProfile::ConvertToTraceType(ECollisionChannel::Visibility);
		ECollisionChannel FromTrace = UCollisionProfile::ConvertToCollisionChannel(true, int32(VisibilityTrace));
		ECollisionChannel ZeroIndexObject = UCollisionProfile::ConvertToCollisionChannel(false, 0);
		return FromObject == ECollisionChannel::WorldStatic &&
			FromTrace == ECollisionChannel::Visibility &&
			ZeroIndexObject == ECollisionChannel::WorldStatic;
	}

	bool Observe_ConvertToObjectType_Nominal()
	{
		EObjectTypeQuery WorldStatic = UCollisionProfile::ConvertToObjectType(ECollisionChannel::WorldStatic);
		EObjectTypeQuery WorldDynamic = UCollisionProfile::ConvertToObjectType(ECollisionChannel::WorldDynamic);
		return WorldStatic != WorldDynamic && WorldStatic == EObjectTypeQuery::WorldStatic;
	}

	bool Observe_ConvertToTraceType_Nominal()
	{
		ETraceTypeQuery Visibility = UCollisionProfile::ConvertToTraceType(ECollisionChannel::Visibility);
		ETraceTypeQuery Camera = UCollisionProfile::ConvertToTraceType(ECollisionChannel::Camera);
		return Visibility != Camera && Visibility == ETraceTypeQuery::Visibility;
	}

	void ExerciseExpectedFailure()
	{
		ECollisionChannel Invalid = UCollisionProfile::ConvertToCollisionChannel(true, -1);
	}
}
