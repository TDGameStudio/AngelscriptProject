// Purpose: Observe FConsoleVariable setters and restore the handle to its
// seeded value after repeated mutations.
// AS-facing API: void FConsoleVariable.SetBool(bool InValue) const;
// void FConsoleVariable.SetFloat(float32 InValue) const;
// void FConsoleVariable.SetInt(int InValue) const;
// void FConsoleVariable.SetString(const FString& InValue) const;
// Inputs: Seeded handles (true, 1.5, 5, "seed"), mutation arguments (false,
// 3.25, 42, "updated"), a repeated identical set, and restoration of the seed.
// Expected observations: After each Set, the matching Get reports the new
// value. A repeated Set is stable. Restoration returns the seeded value.
// Boundary/ownership: Set mutates the native console object owned by the
// script handle. Leaving the handle in scope keeps the registration alive.

namespace TS_Console_MutationAndLifecycle_01
{
	bool Observe_SetBool_Nominal()
	{
		FConsoleVariable BoolVar("as.testsource.console.set.bool", true, "Bool setter probe");
		BoolVar.SetBool(false);
		bool bAfterFirst = BoolVar.GetBool();
		BoolVar.SetBool(false);
		bool bAfterRepeat = BoolVar.GetBool();
		BoolVar.SetBool(true);
		bool bRestored = BoolVar.GetBool();
		return !bAfterFirst && !bAfterRepeat && bRestored;
	}

	bool Observe_SetFloat_Nominal()
	{
		FConsoleVariable FloatVar("as.testsource.console.set.float", 1.5, "Float setter probe");
		FloatVar.SetFloat(3.25);
		float32 AfterFirst = FloatVar.GetFloat();
		FloatVar.SetFloat(3.25);
		float32 AfterRepeat = FloatVar.GetFloat();
		FloatVar.SetFloat(1.5);
		float32 Restored = FloatVar.GetFloat();
		return AfterFirst == 3.25 && AfterRepeat == 3.25 && Restored == 1.5;
	}

	bool Observe_SetInt_Nominal()
	{
		FConsoleVariable IntVar("as.testsource.console.set.int", 5, "Int setter probe");
		IntVar.SetInt(42);
		int AfterFirst = IntVar.GetInt();
		IntVar.SetInt(42);
		int AfterRepeat = IntVar.GetInt();
		IntVar.SetInt(5);
		int Restored = IntVar.GetInt();
		return AfterFirst == 42 && AfterRepeat == 42 && Restored == 5;
	}

	bool Observe_SetString_Nominal()
	{
		FConsoleVariable StringVar("as.testsource.console.set.string", "seed", "String setter probe");
		StringVar.SetString("updated");
		FString AfterFirst = StringVar.GetString();
		StringVar.SetString("updated");
		FString AfterRepeat = StringVar.GetString();
		StringVar.SetString("seed");
		FString Restored = StringVar.GetString();
		return AfterFirst == "updated" && AfterRepeat == "updated" && Restored == "seed";
	}
}
