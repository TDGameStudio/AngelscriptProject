/**
 * @version v1
 * @summary Global and scoped names that share a spelling.
 * @topic Language
 * @topic Namespace
 *
 * global-versus-scoped              // A global helper and a same-named scoped helper selected by qualification.
 * namespace-global-versus-scoped    // Distinct namespaces and a global function are selected by qualification.
 * namespace-scoped-global           // A namespace function reads the global through a leading scope qualifier.
 * unqualified-finds-global          // An inner namespace without a hiding name finds the global function.
 * scoped-hides-global               // An unqualified call inside a namespace finds the scoped function, not the global.
 */
/**
 * @begin global-versus-scoped
 * @summary A global helper and a same-named scoped helper selected by qualification.
 */
int Amount()
{
	return 1;
}

namespace Game
{
	int Amount()
	{
		return 2;
	}
}

int PickGlobal()
{
	return Amount();
}

int PickScoped()
{
	return Game::Amount();
}
/** @end */
/**
 * @begin namespace-global-versus-scoped
 * @summary Distinct namespaces and a global function are selected by qualification.
 * @topic Namespace
 */
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
/** @end */
/**
 * @begin namespace-scoped-global
 * @summary A namespace function reads the global through a leading scope qualifier.
 * @topic Namespace
 */
int Amount()
{
	return 7;
}

namespace Game
{
	int ReadGlobal()
	{
		return ::Amount();
	}
}

int UseScopedGlobal()
{
	return Game::ReadGlobal();
}
/** @end */
/**
 * @begin unqualified-finds-global
 * @summary An inner namespace without a hiding name finds the global function.
 * @topic Namespace
 */
int Amount()
{
	return 1;
}

namespace Game
{
	int Read()
	{
		return Amount();
	}
}

int UseUnqualified()
{
	return Game::Read();
}
/** @end */
/**
 * @begin scoped-hides-global
 * @summary An unqualified call inside a namespace finds the scoped function, not the global.
 * @topic Namespace
 */
int Amount()
{
	return 1;
}

namespace Game
{
	int Amount()
	{
		return 2;
	}

	int Read()
	{
		return Amount();
	}
}

int UseHidden()
{
	return Game::Read();
}
/** @end */
