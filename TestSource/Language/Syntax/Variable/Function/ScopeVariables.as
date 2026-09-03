/**
 * The scope rules governing where a local is visible: function scope, block
 * scope, loop scope, sibling block scopes each with their own variable of the
 * same name, nested blocks, if/else branches, while loops, and globals beside
 * namespaced constants.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.Variable.ScopeVariables
 * @Harness Function
 * @Tag Language.Syntax.Variable.ScopeVariables
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageNamespaceTests.cpp::ScopeVariables ExpectGlobalReturn.
 * @Provenance sha256=a4e8fc6cd453088d29148cf7dbc8dc7ea2ec1b70286a341232d56d44123fcb1f; lines 367-478.
 * @Provenance Oracle: FunctionScope==30; BlockScope==30; ForLoopScope==10; MultipleBlockScopes==30;
 * @Provenance NestedBlockScopes==60; IfStatementScope(true)==100; WhileLoopScope==20;
 * @Provenance GlobalAndNamespaceScope==18; ReadNamespacedScope==11.
 * @Provenance Extra: IfStatementScope(false)==200. DefaultSafe. Source owns locals.
 */

const int GlobalScopeValue = 7;

namespace ScopeNS
{
	const int NamespacedScopeValue = 11;

	/**
	 * Reads the namespaced constant from inside its namespace.
	 *
	 * @Covers Syntax.Variable
	 * @Inputs the namespaced const NamespacedScopeValue
	 * @Return 11
	 */
	int ReadNamespacedScope()
	{
		return NamespacedScopeValue;
	}
}

namespace SyntaxTest
{
	/**
	 * Two locals declared at function scope.
	 *
	 * @Covers Syntax.Variable
	 * @Inputs none
	 * @Return 30
	 */
	int FunctionScope()
	{
		int X = 10;
		int Y = 20;
		return X + Y;
	}

	/**
	 * A local declared inside a nested block, invisible outside it.
	 *
	 * @Covers Syntax.Variable
	 * @Inputs none
	 * @Return 30
	 */
	int BlockScope()
	{
		int X = 10;
		{
			int Y = 20;
			X = X + Y;
		}
		// Y is not accessible here
		return X;
	}

	/**
	 * A loop counter scoped to the loop body.
	 *
	 * @Covers Syntax.Variable
	 * @Inputs none
	 * @Return 10
	 */
	int ForLoopScope()
	{
		int Sum = 0;
		for (int i = 0; i < 5; i++)
		{
			// i is only accessible in loop
			Sum += i;
		}
		// i is not accessible here
		return Sum;
	}

	/**
	 * Two sibling blocks each declaring their own X.
	 *
	 * @Covers Syntax.Variable
	 * @Inputs none
	 * @Return 30
	 */
	int MultipleBlockScopes()
	{
		int Result = 0;
		{
			int X = 10;
			Result += X;
		}
		{
			int X = 20;  // Different X
			Result += X;
		}
		return Result;
	}

	/**
	 * Three levels of nested blocks contributing to one outer variable.
	 *
	 * @Covers Syntax.Variable
	 * @Inputs none
	 * @Return 60
	 */
	int NestedBlockScopes()
	{
		int X = 10;
		{
			int Y = 20;
			{
				int Z = 30;
				X = X + Y + Z;
			}
		}
		return X;
	}

	/**
	 * Each branch declaring its own X of the same name.
	 *
	 * @Covers Syntax.Variable
	 * @Inputs a branch selector
	 * @Return 100 when true, 200 when false
	 * @Param Condition selects the branch
	 */
	int IfStatementScope(bool Condition)
	{
		int Result = 0;
		if (Condition)
		{
			int X = 100;
			Result = X;
		}
		else
		{
			int X = 200;  // Different X
			Result = X;
		}
		return Result;
	}

	/**
	 * A temporary declared inside a while body.
	 *
	 * @Covers Syntax.Variable
	 * @Inputs none
	 * @Return 20
	 */
	int WhileLoopScope()
	{
		int Sum = 0;
		int i = 0;
		while (i < 5)
		{
			int Temp = i * 2;
			Sum += Temp;
			i++;
		}
		// Temp is not accessible here
		return Sum;
	}

	/**
	 * Combines a global constant with a namespaced one.
	 *
	 * @Covers Syntax.Variable
	 * @Inputs the global and namespaced constants
	 * @Return 18
	 */
	int GlobalAndNamespaceScope()
	{
		return GlobalScopeValue + ScopeNS::ReadNamespacedScope();
	}

	/**
	 * Observe that every scope form produces its expected value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Variable
	 * @Inputs all nine scope helpers
	 * @Return true when all nine match
	 */
	UFUNCTION()
	bool ScopeVariableFormsProduceExpectedValues()
	{
		if (FunctionScope() != 30)
		{
			return false;
		}

		if (BlockScope() != 30)
		{
			return false;
		}

		if (ForLoopScope() != 10)
		{
			return false;
		}

		if (MultipleBlockScopes() != 30)
		{
			return false;
		}

		if (NestedBlockScopes() != 60)
		{
			return false;
		}

		if (IfStatementScope(true) != 100)
		{
			return false;
		}

		if (WhileLoopScope() != 20)
		{
			return false;
		}

		if (GlobalAndNamespaceScope() != 18)
		{
			return false;
		}

		return ScopeNS::ReadNamespacedScope() == 11;
	}

	/**
	 * Observe the else branch of the if-scope helper.
	 *
	 * @Kind Observe
	 * @Covers Syntax.Variable
	 * @Inputs IfStatementScope(false)
	 * @Return 200
	 * @Boundary false branch
	 */
	UFUNCTION()
	int IfStatementScopeFalseBoundary()
	{
		return IfStatementScope(false);
	}
}
