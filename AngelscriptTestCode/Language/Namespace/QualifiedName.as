/**
 * @version v1
 * @summary Qualified namespace names and qualified calls.
 * @topic Language
 * @topic Namespace
 */
/**
 * @version root
 * @summary A named namespace function invoked through a qualified name.
 * @topic Baseline
 */
namespace Tools
{
	int Offset()
	{
		return 3;
	}
}

int QualifiedCall()
{
	return Tools::Offset();
}
/** @end */
/**
 * @version invalid-unknown-qualifier
 * @parent root
 * @summary A qualifier that names no namespace is invalid.
 * @topic Negative
 */
int Test()
{
	return Missing::Offset();
}
/** @end */
/**
 * @version valid-namespace-qualified-call
 * @parent root
 * @summary Positive language form retained from legacy namespace qualified call.
 * @topic Namespace
 */
int GetVal()
	{
		return 42;
	}
/** @end */
/**
 * @version valid-namespace-qualified-name
 * @parent root
 * @summary Positive language form retained from legacy namespace qualified name.
 * @topic Namespace
 */
const int Value = 100;

	int GetValue()
	{
		return Value;
	}
/** @end */
/**
 * @version invalid-namespace-anonymous
 * @parent root
 * @summary Compile-rejection form retained from legacy namespace anonymous.
 * @topic Negative
 */
namespace
{
	int X;
}
/** @end */
/**
 * @version invalid-namespace-missing-member
 * @parent root
 * @summary Compile-rejection form retained from legacy namespace missing member.
 * @topic Negative
 */
int X = 1;
/** @end */
/**
 * @version invalid-namespace-undeclared
 * @parent root
 * @summary Compile-rejection form retained from legacy namespace undeclared.
 * @topic Negative
 */
void Test()
{
	int X = FakeNamespace::Value;
}
/** @end */
/**
 * @version invalid-namespace-using-directive
 * @parent root
 * @summary Compile-rejection form retained from legacy namespace using directive.
 * @topic Negative
 */
int Add(int A, int B)
	{
		return A + B;
	}
/** @end */
/**
 * @version invalid-namespace-using-symbol
 * @parent root
 * @summary Compile-rejection form retained from legacy namespace using symbol.
 * @topic Negative
 */
int Add(int A, int B)
	{
		return A + B;
	}
/** @end */
/**
 * @version valid-multi-segment-qualifier
 * @parent root
 * @summary A three-segment qualified function call.
 * @topic Namespace
 */
namespace Game
{
	namespace Combat
	{
		int Hit()
		{
			return 4;
		}
	}
}

int Use()
{
	return Game::Combat::Hit();
}
/** @end */
