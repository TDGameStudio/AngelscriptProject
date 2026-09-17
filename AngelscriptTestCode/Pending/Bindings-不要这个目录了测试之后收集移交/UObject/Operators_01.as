/**
 * @version v1
 * @summary Observe string concatenation with a UObject text representation.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe string concatenation with a UObject text representation.
 * @topic Baseline
 */
// Runner owns the live UObject fixture.
// AS-facing API: Text + Object;
// Inputs: Prefix "obj:", runner-owned UObject, a null handle as the zero
// operand, and empty prefix "".
// Expected observations: Prefix + Object returns a new string longer than
// the prefix. The original prefix is unchanged. Null object concatenation
// still returns a consumed string longer than the prefix.
// Boundary/ownership: + returns a new FString. It does not mutate the UObject
// or take ownership of it. SetupOwner=Runner.

namespace TS_UObject_Operators_01
{
	bool Observe_Addition_Nominal(UObject Object)
	{
		if (Object is null)
		{
			throw("TS_UObject_Operators_01 setup: required Object is null");
		}
		FString Prefix = "obj:";
		FString Combined = Prefix + Object;
		FString FromEmpty = "" + Object;
		UObject NullObject = nullptr;
		FString WithNull = Prefix + NullObject;
		return Prefix == "obj:" && Combined.Len() > Prefix.Len() && FromEmpty.Len() > 0 && WithNull.Len() > Prefix.Len();
	}
}
/** @end */
