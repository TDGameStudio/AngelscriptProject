/**
 * @version v1
 * @summary Global and scoped names that share a spelling.
 * @topic Language
 * @topic Namespace
 */
/**
 * @version root
 * @summary A global helper and a same-named scoped helper selected by qualification.
 * @topic Baseline
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
 * @version invalid-ambiguous-unqualified-after-using
 * @parent root
 * @summary An unqualified name is invalid when a using-directive makes it ambiguous.
 * @topic Negative
 */
using namespace Game;

int Test()
{
	return Amount();
}
/** @end */
/**
 * @version valid-namespace-global-versus-scoped
 * @parent root
 * @summary Positive language form retained from legacy namespace global versus scoped.
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
 * @version valid-namespace-scoped-global
 * @parent root
 * @summary Positive language form retained from legacy namespace scoped global.
 * @topic Namespace
 */
int GlobalVal = 42;
/** @end */
