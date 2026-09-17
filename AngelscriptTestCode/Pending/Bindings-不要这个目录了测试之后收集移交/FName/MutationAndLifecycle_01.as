/**
 * @version v1
 * @summary Observe FName.SetNumber replacing the numeric suffix, including repeated sets and restoration to 0.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FName.SetNumber replacing the numeric suffix, including repeated sets and restoration to 0.
 * @topic Baseline
 */
// string remains Alpha. Repeated set is stable. SetNumber(0) restores the
// unsuffixed name number.
// Boundary/ownership: SetNumber mutates only the numeric component of this
// FName value. It does not allocate a new interned string for the plain text.

namespace TS_FName_MutationAndLifecycle_01
{
	bool Observe_SetNumber_Nominal()
	{
		FName Name = n"Alpha";
		int32 Before = Name.GetNumber();
		Name.SetNumber(1);
		int32 AfterFirst = Name.GetNumber();
		FString PlainAfter = Name.GetPlainNameString();
		Name.SetNumber(1);
		int32 AfterRepeat = Name.GetNumber();
		Name.SetNumber(0);
		int32 Restored = Name.GetNumber();
		return AfterFirst == 1 && AfterRepeat == 1 && Restored == 0 && PlainAfter == "Alpha" && Before == 0;
	}
}
/** @end */
