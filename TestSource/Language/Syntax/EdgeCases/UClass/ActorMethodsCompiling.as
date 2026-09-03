/**
 * An AActor subclass carrying both an empty void method and one that returns a
 * value. Both bodies must complete, and the return value must survive an
 * interleaved call to the empty method.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ActorMethodsCompiling
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.ActorMethodsCompiling
 * @Provenance C++: AngelscriptSyntaxTypeDeclarationTests.cpp::Class_Positive block 3 AssertCompiles.
 * @Provenance sha256=89000990062cf610c327308f5afe895a2b30ad4fc5c6d8ffc08b4f1937bbd193; lines 66-72.
 * @Provenance Oracle: Bar returns 1; Foo is an empty body that completes.
 * @Provenance Extra: Foo then Bar still returns 1; empty Foo yields 0 from a helper.
 * @Provenance FixtureIsolated.
 */

class AClassMethodsActor : AActor
{
	/**
	 * An empty method whose only job is to complete.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing
	 */
	void Foo()
	{
	}

	/**
	 * A method returning a constant.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 1
	 */
	int Bar()
	{
		return 1;
	}

	/**
	 * Observe that the value-returning method reports 1.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Bar()
	 * @Return 1
	 */
	UFUNCTION()
	int MethodBarNominal()
	{
		return Bar();
	}

	/**
	 * Observe that the empty method completes.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Foo()
	 * @Return 0 once the call completes
	 */
	UFUNCTION()
	int MethodFooEmptyCompletes()
	{
		Foo();
		return 0;
	}

	/**
	 * Observe that calling the empty method first does not corrupt Bar.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Foo() then Bar()
	 * @Return 1
	 * @Boundary interleaved call
	 */
	UFUNCTION()
	int MethodFooThenBarBoundary()
	{
		Foo();
		return Bar();
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs an unset AClassMethodsActor handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int MethodActorDefaultsToNull()
	{
		AClassMethodsActor Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
