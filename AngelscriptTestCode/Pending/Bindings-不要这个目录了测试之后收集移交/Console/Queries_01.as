/**
 * @version v1
 * @summary Observe FConsoleVariable typed getters for bool, float32, int, and FString conversions from known positive, negative, and default states.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FConsoleVariable typed getters for bool, float32, int, and FString conversions from known positive, negative, and default states.
 * @topic Baseline
 */
// float32 FConsoleVariable.GetFloat() const;
// int FConsoleVariable.GetInt() const;
// FString FConsoleVariable.GetString() const;
// Inputs: An int variable at default 5 then 0, a bool variable at true then
// false, a float variable at 1.5 then 0.0, and a string variable at
// "DefaultValue" then empty.
// Expected observations: Getters convert the current native value. True/false
// bool outcomes are both reachable. Empty string and zero numeric values are
// distinct from the seeded defaults.
// Boundary/ownership: Getters do not consume or destroy the handle. Conversion
// follows the console variable's stored type rather than allocating a new object.

namespace TS_Console_Queries_01
{
	bool Observe_GetBool_Nominal()
	{
		FConsoleVariable BoolVar("as.testsource.console.get.bool", true, "Bool getter probe");
		bool bDefaultTrue = BoolVar.GetBool();
		BoolVar.SetBool(false);
		bool bUpdatedFalse = BoolVar.GetBool();
		return bDefaultTrue && !bUpdatedFalse;
	}

	bool Observe_GetFloat_Nominal()
	{
		FConsoleVariable FloatVar("as.testsource.console.get.float", 1.5, "Float getter probe");
		float32 DefaultValue = FloatVar.GetFloat();
		FloatVar.SetFloat(0.0);
		float32 ZeroValue = FloatVar.GetFloat();
		return DefaultValue == 1.5 && ZeroValue == 0.0;
	}

	bool Observe_GetInt_Nominal()
	{
		FConsoleVariable IntVar("as.testsource.console.get.int", 5, "Int getter probe");
		int DefaultValue = IntVar.GetInt();
		IntVar.SetInt(0);
		int ZeroValue = IntVar.GetInt();
		return DefaultValue == 5 && ZeroValue == 0;
	}

	bool Observe_GetString_Nominal()
	{
		FConsoleVariable StringVar("as.testsource.console.get.string", "DefaultValue", "String getter probe");
		FString DefaultValue = StringVar.GetString();
		StringVar.SetString("");
		FString EmptyValue = StringVar.GetString();
		return DefaultValue == "DefaultValue" && EmptyValue.IsEmpty();
	}
}
/** @end */
