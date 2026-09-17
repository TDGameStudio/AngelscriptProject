/**
 * @version v1
 * @summary Observe expansion of an eligible UEnum and the EGetByNameFlags lookup-policy enum, including copy and assignment.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe expansion of an eligible UEnum and the EGetByNameFlags lookup-policy enum, including copy and assignment.
 * @topic Baseline
 */
// enum EGetByNameFlags;
// Inputs: EAttachmentRule::KeepWorld / KeepRelative / SnapToTarget,
// EGetByNameFlags::None / ErrorIfNotFound / CaseSensitive / CheckAuthoredName,
// copies of those values, and assignment over the copy.
// Expected observations: Copied KeepWorld equals the source. Assigned
// KeepRelative differs from KeepWorld. Copied None equals the source.
// Assigned ErrorIfNotFound differs from None.
// Boundary/ownership: Enumerator names have native qualification removed.
// Script-generated /Script/Angelscript enums are not expanded here. The enum
// values do not own UEnum objects.

namespace TS_UEnum_ConstructionAndAssignment_01
{
	// EAttachmentRule enumerators copy and assign by value and stay distinct.
	bool Observe_Surface001_Nominal()
	{
		EAttachmentRule World = EAttachmentRule::KeepWorld;
		EAttachmentRule Relative = EAttachmentRule::KeepRelative;
		EAttachmentRule Snap = EAttachmentRule::SnapToTarget;
		EAttachmentRule Copied = World;
		bool bCopyEqualsSource = Copied == World;
		Copied = Relative;
		return bCopyEqualsSource &&
			Copied == Relative &&
			World == EAttachmentRule::KeepWorld &&
			World != Relative &&
			Relative != Snap &&
			World != Snap;
	}

	// EGetByNameFlags enumerators copy and assign by value and stay distinct.
	bool Observe_Surface002_Nominal()
	{
		EGetByNameFlags None = EGetByNameFlags::None;
		EGetByNameFlags ErrorIfNotFound = EGetByNameFlags::ErrorIfNotFound;
		EGetByNameFlags CaseSensitive = EGetByNameFlags::CaseSensitive;
		EGetByNameFlags CheckAuthoredName = EGetByNameFlags::CheckAuthoredName;
		EGetByNameFlags Copied = None;
		bool bCopyEqualsNone = Copied == None;
		Copied = ErrorIfNotFound;
		return bCopyEqualsNone &&
			Copied == ErrorIfNotFound &&
			None != ErrorIfNotFound &&
			None != CaseSensitive &&
			None != CheckAuthoredName &&
			ErrorIfNotFound != CaseSensitive &&
			CaseSensitive != CheckAuthoredName;
	}
}
/** @end */
