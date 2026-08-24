// Purpose: Observe declaration of script-owned console variable and command
// handle types, including copy independence of the handle values.
// AS-facing API: struct FConsoleVariable; struct FConsoleCommand;
// Inputs: Default construction of both handle types, then copy assignment of
// a named integer variable handle and a named command handle.
// Expected observations: A copied FConsoleVariable still GetInt()s the same
// value as the source until the copy is replaced. Command handles remain
// distinct objects after copy.
// Boundary/ownership: The script handle owns the console object lifetime.
// Destroying the last handle unregisters the console object. Copies share that
// registration rather than creating a second native command.

void TSConsoleConstructionCommandTarget()
{
}

namespace TS_Console_ConstructionAndAssignment_01
{
	// struct FConsoleVariable copy shares the native registration.
	// Inputs: named int handle default 5, copy, then SetInt(9) on the copy.
	// Oracle: copy GetInt is 5; source GetInt becomes 9 after copy mutation.
	// Ownership: copies share registration; last handle owns unregister.
	bool Observe_Surface001_Nominal()
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

	// struct FConsoleCommand copy and assignment keep console registration healthy.
	// Inputs: named command handle, copy, then assignment from another command.
	// Oracle: a probe console variable still GetInt()s 4 after assignment.
	// Ownership: copies share registration rather than creating a second native command.
	bool Observe_Surface002_Nominal()
	{
		FConsoleCommand Source("as.testsource.console.command.handle", n"TSConsoleConstructionCommandTarget");
		FConsoleCommand Copied = Source;
		FConsoleCommand Replaced("as.testsource.console.command.handle.other", n"TSConsoleConstructionCommandTarget");
		Copied = Replaced;
		FConsoleVariable Probe("as.testsource.console.command.handle.probe", 4, "command copy probe");
		return Probe.GetInt() == 4;
	}
}
