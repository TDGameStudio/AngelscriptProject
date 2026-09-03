/**
 * A global function and namespaced functions live in separate scopes and do
 * not collide. A namespace function can be called by qualified name from the
 * global scope, and a function inside a namespace can in turn call a global
 * function by its unqualified name. A namespaced constant is read through a
 * namespaced accessor.
 *
 * @Theme Language.Namespace
 * @Subject Namespace.GlobalVersusScoped
 * @Harness Function
 * @Tag Language.Namespace.NamespaceGlobalVersusScoped
 * @Namespace NamespaceTest
 * @Provenance C++: AngelscriptCoverageNamespaceTests.cpp::NamespaceDeclaration ExpectGlobalReturn.
 * @Provenance sha256=ed8666966307b61c080253146660f1c28e311613f94514f075534fb13223c92d; lines 83-129.
 * @Provenance Oracle: GlobalFunction() == 100; UseNamespacedFunctions() == 500.
 * @Provenance Extra: GetConstant() == 42; CallGlobalFunction() == 100; namespaced 200/300 stay isolated.
 */

/**
 * A function declared at global scope, outside every namespace.
 */
int GlobalFunction()
{
	return 100;
}

namespace MyNamespace
{
	/**
	 * A function declared inside a namespace, callable by qualified name.
	 */
	int NamespacedFunction()
	{
		return 200;
	}

	const int NamespacedConstant = 42;

	/**
	 * Reads the namespaced constant, so the constant is observable from
	 * outside without naming it directly.
	 */
	int GetConstant()
	{
		return NamespacedConstant;
	}
}

namespace OtherNamespace
{
	/**
	 * A second namespace function used to show two namespaces stay isolated.
	 */
	int OtherFunction()
	{
		return 300;
	}
}

/**
 * Adds the results of two different namespaces, exercised from global scope.
 */
int UseNamespacedFunctions()
{
	return MyNamespace::NamespacedFunction() + OtherNamespace::OtherFunction();
}

namespace AccessGlobal
{
	/**
	 * Calls a global function from inside a namespace by its unqualified name.
	 */
	int CallGlobalFunction()
	{
		return GlobalFunction();
	}
}

namespace NamespaceTest
{
	/**
	 * Observe that a global function resolves from the global scope.
	 *
	 * @Kind Observe
	 * @Covers Namespace.GlobalScope
	 * @Inputs Call GlobalFunction() from the global scope
	 * @Return 100 when the global function resolves
	 */
	UFUNCTION()
	int GlobalFunctionResolves()
	{
		return GlobalFunction();
	}

	/**
	 * Observe that two namespaced functions from different namespaces can be
	 * combined through qualified calls.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Call UseNamespacedFunctions(), which adds MyNamespace and OtherNamespace results
	 * @Return 500 when both namespaces resolve and stay isolated
	 */
	UFUNCTION()
	int NamespacedFunctionsCombine()
	{
		return UseNamespacedFunctions();
	}

	/**
	 * Observe that a namespaced constant is read through a namespaced accessor.
	 *
	 * @Kind Observe
	 * @Covers Namespace.QualifiedAccess
	 * @Inputs Call MyNamespace::GetConstant()
	 * @Return 42 when the namespaced constant resolves
	 */
	UFUNCTION()
	int NamespacedConstantResolves()
	{
		return MyNamespace::GetConstant();
	}

	/**
	 * Observe that a function inside a namespace can call a global function by
	 * its unqualified name.
	 *
	 * @Kind Observe
	 * @Covers Namespace.GlobalScope
	 * @Inputs Call AccessGlobal::CallGlobalFunction(), which calls GlobalFunction()
	 * @Return 100 when the global function is reachable from inside a namespace
	 */
	UFUNCTION()
	int GlobalFunctionReachableFromNamespace()
	{
		return AccessGlobal::CallGlobalFunction();
	}

	/**
	 * Observe that the global and namespaced results stay independent: the
	 * global value is not shadowed by either namespace.
	 *
	 * @Kind Observe
	 * @Covers Namespace.GlobalScope
	 * @Inputs Compare GlobalFunction() with each namespaced function
	 * @Return true when the values are 100, 200, and 300 respectively
	 */
	UFUNCTION()
	bool ScopesStayIndependent()
	{
		if (GlobalFunction() != 100)
		{
			return false;
		}
		if (MyNamespace::NamespacedFunction() != 200)
		{
			return false;
		}
		return OtherNamespace::OtherFunction() == 300;
	}
}
