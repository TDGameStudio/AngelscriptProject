// Purpose: Observe FConsoleVariable and FConsoleCommand constructors for every
// published default-value overload, including help-text omission.
// AS-facing API: FConsoleVariable Variable(const FString& Name, int DefaultValue, const FString& Help = "");
// FConsoleVariable Variable(const FString& Name, bool DefaultValue, const FString& Help = "");
// FConsoleVariable Variable(const FString& Name, float32 DefaultValue, const FString& Help = "");
// FConsoleVariable Variable(const FString& Name, const FString& DefaultValue, const FString& Help = "");
// FConsoleCommand Command(const FString& Name, const FName& FunctionName);
// Inputs: Distinct names, defaults 5 / true / 1.5 / "DefaultValue", omitted
// help on the int overload, and a command bound to TSConsoleBehaviorCommandTarget.
// Expected observations: Each constructed variable Get* matches its default.
// Empty help omission still registers. The command handle constructs without
// throwing for a compatible script function name.
// Boundary/ownership: The handle lifetime owns the console registration.
// Reusing an existing native name reuses that object rather than leaking a
// second registration. FunctionName must name a compatible script function.

void TSConsoleBehaviorCommandTarget()
{
}

namespace TS_Console_Behavior_01
{
	bool Observe_Variable_Nominal()
	{
		FConsoleVariable IntVar("as.testsource.console.ctor.int", 5);
		int IntDefault = IntVar.GetInt();
		FConsoleVariable IntVarWithHelp("as.testsource.console.ctor.int.help", 5, "Help text");
		int IntHelped = IntVarWithHelp.GetInt();
		bool bIntConstructorsMatch = IntDefault == 5 && IntHelped == 5;

		FConsoleVariable BoolVar("as.testsource.console.ctor.bool", true, "Bool ctor");
		bool bBoolDefault = BoolVar.GetBool();

		FConsoleVariable FloatVar("as.testsource.console.ctor.float", 1.5, "Float ctor");
		float32 FloatDefault = FloatVar.GetFloat();
		bool bFloatDefaultMatches = FloatDefault == 1.5;

		FConsoleVariable StringVar("as.testsource.console.ctor.string", "DefaultValue", "String ctor");
		FString StringDefault = StringVar.GetString();
		bool bStringDefaultMatches = StringDefault == "DefaultValue";

		return bIntConstructorsMatch && bBoolDefault && bFloatDefaultMatches && bStringDefaultMatches;
	}

	bool Observe_Command_Nominal()
	{
		FConsoleCommand Command("as.testsource.console.ctor.command", n"TSConsoleBehaviorCommandTarget");
		FConsoleCommand EmptyNameBoundary("as.testsource.console.ctor.command.other", n"TSConsoleBehaviorCommandTarget");
		FConsoleVariable Probe("as.testsource.console.ctor.command.probe", 3, "probe");
		return Probe.GetInt() == 3;
	}
}
