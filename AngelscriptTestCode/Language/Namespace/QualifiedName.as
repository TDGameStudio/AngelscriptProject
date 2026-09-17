/**
 * @version v1
 * @summary Qualified namespace names and qualified calls.
 * @topic Language
 * @topic Namespace
 *
 * qualified-name
 * namespace-qualified-call
 * namespace-qualified-name
 * multi-segment-qualifier
 */
/**
 * @begin qualified-name
 * @summary A named namespace function invoked through a qualified name.
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
 * @begin namespace-qualified-call
 * @summary Positive language form retained from legacy namespace qualified call.
 * @topic Namespace
 */
int GetVal()
	{
		return 42;
	}
/** @end */
/**
 * @begin namespace-qualified-name
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
 * @begin multi-segment-qualifier
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
