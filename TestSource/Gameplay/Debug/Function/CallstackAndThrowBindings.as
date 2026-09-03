/**
 * The Angelscript callstack bindings plus the throw path. The CSV NegativeDiagnostic
 * label is a heuristic: C++ compiles this module and executes EntryCallstack expecting
 * 1, so this is a value oracle. ThrowEntry raises CoverageThrowMessage and is expected
 * to be reached only by C++, never by the observers.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.CallstackAndThrowBindings
 * @Harness Function
 * @Tag Gameplay.Debug.CallstackAndThrowBindings
 * @Namespace DebugTest
 * @Provenance Theme: Gameplay.Debug. Callstack frames plus throw exception path.
 * @Provenance C++: AngelscriptCoverageDebugTests.cpp::CallstackAndThrowBindings
 * @Provenance CSV NegativeDiagnostic; C++ compiles. ExecuteAndExpectInt EntryCallstack == 1.
 * @Provenance ThrowEntry raises CoverageThrowMessage. Extra: empty stack / missing needle are false.
 * @Provenance DefaultSafe.
 */

namespace DebugTest
{
	/**
	 * Search a callstack for a frame name.
	 *
	 * @Kind Helper
	 * @Covers Debug.CallstackAndThrowBindings
	 * @Inputs a callstack and the frame name to look for
	 * @Return true when any frame contains the needle
	 * @Param Stack the callstack to search
	 * @Param Needle the frame name to look for
	 */
	UFUNCTION()
	bool StackContains(const TArray<FString>&in Stack, const FString&in Needle)
	{
		for (int Index = 0; Index < Stack.Num(); ++Index)
		{
			if (Stack[Index].Contains(Needle))
			{
				return true;
			}
		}
		return false;
	}

	/**
	 * Observe that both the raw and the formatted callstack name the current frame and
	 * its caller.
	 *
	 * @Kind Observe
	 * @Covers Debug.CallstackAndThrowBindings
	 * @Inputs none
	 * @Return 1 when both forms name both frames, otherwise 0
	 */
	UFUNCTION()
	int ProbeCallstack()
	{
		TArray<FString> Stack = GetAngelscriptCallstack();
		FString Formatted = FormatAngelscriptCallstack();
		if (Stack.Num() < 3)
		{
			return 0;
		}
		if (!StackContains(Stack, "ProbeCallstack"))
		{
			return 0;
		}
		if (!StackContains(Stack, "EntryCallstack"))
		{
			return 0;
		}
		if (!Formatted.Contains("ProbeCallstack"))
		{
			return 0;
		}
		if (!Formatted.Contains("EntryCallstack"))
		{
			return 0;
		}
		return 1;
	}

	/**
	 * The entrypoint C++ executes to drive the callstack probe.
	 *
	 * @Kind Observe
	 * @Covers Debug.CallstackAndThrowBindings
	 * @Inputs none
	 * @Return ProbeCallstack(), expected to be 1
	 */
	UFUNCTION()
	int EntryCallstack()
	{
		return ProbeCallstack();
	}

	/**
	 * Raise the script exception that the throw path is named after. C++ invokes this
	 * and expects the error; no observer calls it.
	 *
	 * @Kind Action
	 * @Covers Debug.CallstackAndThrowBindings
	 * @Inputs none
	 * @Return nothing; throws before it can return
	 */
	UFUNCTION()
	void ThrowLeaf()
	{
		throw("CoverageThrowMessage");
	}

	/**
	 * The entrypoint C++ executes to drive the throw path. No observer calls it.
	 *
	 * @Kind Action
	 * @Covers Debug.CallstackAndThrowBindings
	 * @Inputs none
	 * @Return does not return; throws before the return is reached
	 */
	UFUNCTION()
	int ThrowEntry()
	{
		ThrowLeaf();
		return 0;
	}

	/**
	 * Observe that the callstack probe reports success when driven from the entrypoint.
	 *
	 * @Kind Observe
	 * @Covers Debug.CallstackAndThrowBindings
	 * @Inputs none
	 * @Return true when EntryCallstack returned 1
	 */
	UFUNCTION()
	bool EntryCallstackNominal()
	{
		return EntryCallstack() == 1;
	}

	/**
	 * Observe that an empty callstack contains nothing.
	 *
	 * @Kind Observe
	 * @Covers Debug.CallstackAndThrowBindings
	 * @Inputs an empty callstack
	 * @Return true when the search reports no match
	 * @Boundary empty stack
	 */
	UFUNCTION()
	bool StackContainsEmptyDefault()
	{
		TArray<FString> Empty;
		return !StackContains(Empty, "ProbeCallstack");
	}

	/**
	 * Observe that a callstack without the sought frame contains nothing.
	 *
	 * @Kind Observe
	 * @Covers Debug.CallstackAndThrowBindings
	 * @Inputs a callstack holding an unrelated frame
	 * @Return true when the search reports no match
	 * @Boundary missing needle
	 */
	UFUNCTION()
	bool StackContainsMissingNeedle()
	{
		TArray<FString> Stack;
		Stack.Add("OtherFrame");
		return !StackContains(Stack, "ProbeCallstack");
	}
}
