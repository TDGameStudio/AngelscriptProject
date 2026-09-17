/**
 * @version v1
 * @summary Global and scoped names that share a spelling.
 * @topic Language
 * @topic Namespace
 *
 * global-versus-scoped
 * namespace-global-versus-scoped
 * namespace-scoped-global
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
 * @begin namespace-scoped-global
 * @summary Positive language form retained from legacy namespace scoped global.
 * @topic Namespace
 */
int GlobalVal = 42;
/** @end */
