/**
 * ExecuteIfBound on an unbound unicast returns the type's default. Entry
 * returns 0 for int; EntryBool returns 0 for false; two unbound int
 * delegates stay 0 independently.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateExecuteIfBoundReturnsDefaultValue
 * @Harness Function
 * @Tag Feature.Delegates.DelegateExecuteIfBoundReturnsDefaultValue
 * @Namespace DelegatesTest
 * @Provenance Theme: Feature.Delegates. Positive unbound ExecuteIfBound returns default values.
 * @Provenance C++: AngelscriptCompilerDelegateRuntimeTests.cpp::DelegateExecuteIfBoundReturnsDefaultValue
 * @Provenance Oracle: Entry()==0, EntryBool()==0. Extra: two unbound int delegates stay 0 independently.
 * @Provenance DefaultSafe.
 */

/**
 * A unicast that returns int.
 *
 * @Covers Delegates.ExecuteIfBound
 * @Inputs none
 * @Return the bound handler's int, or 0 when unbound
 */
delegate int FRuntimeValueDelegate();

/**
 * A unicast that returns bool.
 *
 * @Covers Delegates.ExecuteIfBound
 * @Inputs none
 * @Return the bound handler's bool, or false when unbound
 */
delegate bool FRuntimeBoolDelegate();

namespace DelegatesTest
{
	/**
	 * The C++ int oracle: ExecuteIfBound on an unbound int delegate.
	 *
	 * @Kind Observe
	 * @Covers Delegates.ExecuteIfBound
	 * @Inputs an unbound FRuntimeValueDelegate
	 * @Return 0
	 * @Boundary unbound default
	 */
	UFUNCTION()
	int Entry()
	{
		FRuntimeValueDelegate Delegate;
		return Delegate.ExecuteIfBound();
	}

	/**
	 * The C++ bool oracle: ExecuteIfBound on an unbound bool delegate as 0 or 1.
	 *
	 * @Kind Observe
	 * @Covers Delegates.ExecuteIfBound
	 * @Inputs an unbound FRuntimeBoolDelegate
	 * @Return 0
	 * @Boundary unbound default
	 */
	UFUNCTION()
	int EntryBool()
	{
		FRuntimeBoolDelegate Delegate;
		return Delegate.ExecuteIfBound() ? 1 : 0;
	}

	/**
	 * Observe the unbound int default.
	 *
	 * @Kind Observe
	 * @Covers Delegates.ExecuteIfBound
	 * @Inputs none
	 * @Return 0
	 * @Boundary unbound int
	 */
	UFUNCTION()
	int UnboundIntDefault()
	{
		return Entry();
	}

	/**
	 * Observe the unbound bool default.
	 *
	 * @Kind Observe
	 * @Covers Delegates.ExecuteIfBound
	 * @Inputs none
	 * @Return 0
	 * @Boundary unbound bool
	 */
	UFUNCTION()
	int UnboundBoolDefault()
	{
		return EntryBool();
	}

	/**
	 * Observe that two unbound int delegates each return 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.ExecuteIfBound
	 * @Inputs two unbound FRuntimeValueDelegate values
	 * @Return 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int UnboundIntCopyIndependence()
	{
		FRuntimeValueDelegate First;
		FRuntimeValueDelegate Second;
		return First.ExecuteIfBound() + Second.ExecuteIfBound();
	}
}
