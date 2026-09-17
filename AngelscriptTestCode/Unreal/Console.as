/**
 * @version v1
 * @summary Console host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic Console
 *
 * variable
 * command
 * inputs-named-int-handle
 * oracle-probe-console-variable
 * set-bool
 * set-float
 * set-int
 * set-string
 * get-bool
 * get-float
 * get-int
 * get-string
 */
/**
 * @begin variable
 * @summary second registration.
 * @topic Unreal
 */
/**
 * @function ObserveVariableNominal
 * @summary second registration.
 * @covers Console.variable
 * @inputs Console values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveVariableNominal()
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
/** @end */
/**
 * @begin command
 * @summary second registration.
 * @topic Unreal
 */
/**
 * @function ObserveCommandNominal
 * @summary second registration.
 * @covers Console.command
 * @inputs Console values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveCommandNominal()
{
	FConsoleCommand Command("as.testsource.console.ctor.command", n"TSConsoleBehaviorCommandTarget");
	FConsoleCommand EmptyNameBoundary("as.testsource.console.ctor.command.other", n"TSConsoleBehaviorCommandTarget");
	FConsoleVariable Probe("as.testsource.console.ctor.command.probe", 3, "probe");
	return Probe.GetInt() == 3;
}
/** @end */
/**
 * @begin inputs-named-int-handle
 * @summary Inputs: named int handle default 5, copy,
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary Inputs: named int handle default 5, copy,
 * @covers Console.inputs-named-int-handle
 * @inputs Console values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: A copied FConsoleVariable

 then SetInt(9) on the copy.
// Oracle: copy GetInt is 5; source GetInt becomes 9 after copy mutation.
// Ownership: copies share registration; last handle owns unregister.
bool ObserveSurface001Nominal()
{
	FConsoleVariable Source("as.testsource.console.variable.handle", 5, "Handle copy probe");
	FConsoleVariable Copied = Source;
	int SourceValue = Source.GetInt();
	int CopiedValue = Copied.GetInt();
	bool bCopyReadsSameValue = SourceValue == 5 && CopiedValue == 5;
	Copied.SetInt(9);
	int SourceAfterCopyMutation = Source.GetInt();
	bool bCopySharesRegistration = SourceAfterCopyMutation == 9;
	return bCopyReadsSameValue && bCopySharesRegistration;
}
/** @end */
/**
 * @begin oracle-probe-console-variable
 * @summary Oracle: a probe console variable
 * @topic Unreal
 */
/**
 * @function ObserveSurface002Nominal
 * @summary Oracle: a probe console variable
 * @covers Console.oracle-probe-console-variable
 * @inputs Console values exercised by this observe
 * @return true when the observe comparison holds
 */
// Expected observations: A copied FConsoleVariable

 still GetInt()s 4 after assignment.
// Ownership: copies share registration rather than creating a second native command.
bool ObserveSurface002Nominal()
{
	FConsoleCommand Source("as.testsource.console.command.handle", n"TSConsoleConstructionCommandTarget");
	FConsoleCommand Copied = Source;
	FConsoleCommand Replaced("as.testsource.console.command.handle.other", n"TSConsoleConstructionCommandTarget");
	Copied = Replaced;
	FConsoleVariable Probe("as.testsource.console.command.handle.probe", 4, "command copy probe");
	return Probe.GetInt() == 4;
}
/** @end */
/**
 * @begin set-bool
 * @summary Inputs:
 * @topic Unreal
 */
/**
 * @function ObserveSetBoolNominal
 * @summary Inputs:
 * @covers Console.set-bool
 * @inputs Console values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

 Seeded handles (true, 1.5, 5, "seed"), mutation arguments (false,
// 3.25, 42, "updated"), a repeated identical set, and restoration of the seed.
// Expected observations: After each Set, the matching Get reports the new
// value. A repeated Set is stable. Restoration returns the seeded value.
// Boundary/ownership: Set mutates the native console object owned by the
// script handle. Leaving the handle in scope keeps the registration alive.
bool ObserveSetBoolNominal()
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
/** @end */
/**
 * @begin set-float
 * @summary script handle.
 * @topic Unreal
 */
/**
 * @function ObserveSetFloatNominal
 * @summary script handle.
 * @covers Console.set-float
 * @inputs Console values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

bool ObserveSetFloatNominal()
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
/** @end */
/**
 * @begin set-int
 * @summary script handle.
 * @topic Unreal
 */
/**
 * @function ObserveSetIntNominal
 * @summary script handle.
 * @covers Console.set-int
 * @inputs Console values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

bool ObserveSetIntNominal()
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
/** @end */
/**
 * @begin set-string
 * @summary script handle.
 * @topic Unreal
 */
/**
 * @function ObserveSetStringNominal
 * @summary script handle.
 * @covers Console.set-string
 * @inputs Console values exercised by this observe
 * @return true when the observe comparison holds
 */
// Inputs:

bool ObserveSetStringNominal()
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
/** @end */
/**
 * @begin get-bool
 * @summary follows the console variable's stored type rather than allocating a new object.
 * @topic Unreal
 */
/**
 * @function ObserveGetBoolNominal
 * @summary follows the console variable's stored type rather than allocating a new object.
 * @covers Console.get-bool
 * @inputs Console values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetBoolNominal()
{
	FConsoleVariable BoolVar("as.testsource.console.get.bool", true, "Bool getter probe");
	bool bDefaultTrue = BoolVar.GetBool();
	BoolVar.SetBool(false);
	bool bUpdatedFalse = BoolVar.GetBool();
	return bDefaultTrue && !bUpdatedFalse;
}
/** @end */
/**
 * @begin get-float
 * @summary follows the console variable's stored type rather than allocating a new object.
 * @topic Unreal
 */
/**
 * @function ObserveGetFloatNominal
 * @summary follows the console variable's stored type rather than allocating a new object.
 * @covers Console.get-float
 * @inputs Console values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetFloatNominal()
{
	FConsoleVariable FloatVar("as.testsource.console.get.float", 1.5, "Float getter probe");
	float32 DefaultValue = FloatVar.GetFloat();
	FloatVar.SetFloat(0.0);
	float32 ZeroValue = FloatVar.GetFloat();
	return DefaultValue == 1.5 && ZeroValue == 0.0;
}
/** @end */
/**
 * @begin get-int
 * @summary follows the console variable's stored type rather than allocating a new object.
 * @topic Unreal
 */
/**
 * @function ObserveGetIntNominal
 * @summary follows the console variable's stored type rather than allocating a new object.
 * @covers Console.get-int
 * @inputs Console values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetIntNominal()
{
	FConsoleVariable IntVar("as.testsource.console.get.int", 5, "Int getter probe");
	int DefaultValue = IntVar.GetInt();
	IntVar.SetInt(0);
	int ZeroValue = IntVar.GetInt();
	return DefaultValue == 5 && ZeroValue == 0;
}
/** @end */
/**
 * @begin get-string
 * @summary follows the console variable's stored type rather than allocating a new object.
 * @topic Unreal
 */
/**
 * @function ObserveGetStringNominal
 * @summary follows the console variable's stored type rather than allocating a new object.
 * @covers Console.get-string
 * @inputs Console values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetStringNominal()
{
	FConsoleVariable StringVar("as.testsource.console.get.string", "DefaultValue", "String getter probe");
	FString DefaultValue = StringVar.GetString();
	StringVar.SetString("");
	FString EmptyValue = StringVar.GetString();
	return DefaultValue == "DefaultValue" && EmptyValue.IsEmpty();
}
/** @end */
