// Purpose: Observe collision-configuration enums expanded from the active
// UCollisionProfile, including copy and assignment independence.
// AS-facing API: enum ETraceTypeQuery { <configured trace profile names>, Visibility, Camera };
// enum ECollisionChannel { <configured profile names> };
// enum EObjectTypeQuery { <configured object profile names>, WorldStatic, WorldDynamic, PhysicsBody };
// Inputs: Default Visibility/Camera trace values, WorldStatic object query,
// copy of those values, and assignment of Camera over Visibility.
// Expected observations: Copied enumerators compare equal to the source.
// Assigned Camera differs from Visibility. WorldStatic remains a valid object
// query after copy.
// Boundary/ownership: Enumerator names come from the active profile plus
// Unreal's fixed channels. Script does not own the profile configuration.

namespace TS_ConfigEnums_ConstructionAndAssignment_01
{
	// enum ETraceTypeQuery Visibility/Camera copy and assignment stay independent.
	// Inputs: Visibility, Camera, copy then assign Camera.
	// Oracle: copy equals Visibility; assignment selects Camera; Visibility is unchanged.
	// Ownership: enum values; script does not own the profile configuration.
	bool Observe_Surface001_Nominal()
	{
		ETraceTypeQuery Visibility = ETraceTypeQuery::Visibility;
		ETraceTypeQuery Camera = ETraceTypeQuery::Camera;
		ETraceTypeQuery Copied = Visibility;
		bool bCopyIndependentAndEqual = Copied == Visibility;
		Copied = Camera;
		bool bAssignmentReplacesValue = Copied == Camera && Visibility == ETraceTypeQuery::Visibility;
		return bCopyIndependentAndEqual && bAssignmentReplacesValue && Visibility != Camera;
	}

	// enum ECollisionChannel WorldStatic copies and then assigns WorldDynamic.
	// Inputs: WorldStatic copy, then WorldDynamic assignment.
	// Oracle: copy equals source; assigned value differs from WorldStatic.
	// Ownership: enum values; use ECollisionChannel::WorldStatic not ECC_*.
	bool Observe_Surface002_Nominal()
	{
		ECollisionChannel WorldStaticChannel = ECollisionChannel::WorldStatic;
		ECollisionChannel Copied = WorldStaticChannel;
		bool bCopiedChannelEqualsSource = Copied == WorldStaticChannel;
		Copied = ECollisionChannel::WorldDynamic;
		bool bAssignedChannelDiffers = Copied != WorldStaticChannel;
		return bCopiedChannelEqualsSource && bAssignedChannelDiffers;
	}

	// enum EObjectTypeQuery WorldStatic/WorldDynamic/PhysicsBody copy and assign.
	// Inputs: WorldStatic copy, then PhysicsBody assignment.
	// Oracle: copy equals WorldStatic; assignment selects PhysicsBody; WorldStatic != WorldDynamic.
	// Ownership: enum values from the active profile plus fixed channels.
	bool Observe_Surface003_Nominal()
	{
		EObjectTypeQuery WorldStatic = EObjectTypeQuery::WorldStatic;
		EObjectTypeQuery WorldDynamic = EObjectTypeQuery::WorldDynamic;
		EObjectTypeQuery PhysicsBody = EObjectTypeQuery::PhysicsBody;
		EObjectTypeQuery Copied = WorldStatic;
		bool bCopyEqualsWorldStatic = Copied == WorldStatic;
		Copied = PhysicsBody;
		bool bAssignmentSelectsPhysicsBody = Copied == PhysicsBody && WorldStatic != WorldDynamic;
		return bCopyEqualsWorldStatic && bAssignmentSelectsPhysicsBody;
	}
}
