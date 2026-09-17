/**
 * @version v1
 * @summary Observe FGuid::NewGuid as a platform-generated unique identifier.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FGuid::NewGuid as a platform-generated unique identifier.
 * @topic Baseline
 */
// required to differ but typically do; both are consumed and compared against
// the invalid zero GUID.
// Boundary/ownership: NewGuid returns a value type. The platform owns the
// generator; the script owns the returned FGuid copy.

namespace TS_FGuid_NamespaceAndGlobalFunctions_01
{
	bool Observe_NewGuid_Nominal()
	{
		FGuid First = FGuid::NewGuid();
		FGuid Second = FGuid::NewGuid();
		FGuid Zero(0, 0, 0, 0);
		return First.IsValid() && Second.IsValid() && !(First == Zero) && !(Second == Zero);
	}
}
/** @end */
