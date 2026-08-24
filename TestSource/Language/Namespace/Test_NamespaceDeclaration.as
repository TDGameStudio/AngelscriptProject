// Theme: Language.Namespace. Positive: global vs namespaced functions.
// C++: AngelscriptCoverageNamespaceTests.cpp::NamespaceDeclaration ExpectGlobalReturn.
// sha256=ed8666966307b61c080253146660f1c28e311613f94514f075534fb13223c92d; lines 83-129.
// Oracle: GlobalFunction() == 100; UseNamespacedFunctions() == 500.
// Extra: GetConstant() == 42; CallGlobalFunction() == 100; namespaced 200/300 stay isolated.
// DefaultSafe.

int GlobalFunction()
{
	return 100;
}

namespace MyNamespace
{
	int NamespacedFunction()
	{
		return 200;
	}

	const int NamespacedConstant = 42;

	int GetConstant()
	{
		return NamespacedConstant;
	}
}

namespace OtherNamespace
{
	int OtherFunction()
	{
		return 300;
	}
}

int UseNamespacedFunctions()
{
	return MyNamespace::NamespacedFunction() + OtherNamespace::OtherFunction();
}

namespace AccessGlobal
{
	int CallGlobalFunction()
	{
		return GlobalFunction();
	}
}

bool Observe_NamespaceDeclaration_Nominal()
{
	return GlobalFunction() == 100 && UseNamespacedFunctions() == 500;
}

bool Observe_GetConstant_Nominal()
{
	return MyNamespace::GetConstant() == 42;
}

bool Observe_CallGlobalFromNamespace()
{
	return AccessGlobal::CallGlobalFunction() == 100;
}
