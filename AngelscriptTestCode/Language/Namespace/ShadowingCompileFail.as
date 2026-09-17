/**
 * @version v1
 * @summary Compile-fail cases for Shadowing.
 * @topic Language
 * @topic Namespace
 *
 * invalid-shadowed-type-as-value
 * invalid-duplicate-in-same-namespace
 */
/**
 * @begin invalid-shadowed-type-as-value
 * @summary A shadowed type name cannot be used as a value.
 * @topic Negative
 */
namespace Game
{
	int Score = 1;
}

void Test()
{
	int Game = 2;
	return Game::Score;
}
/** @end */
/**
 * @begin invalid-duplicate-in-same-namespace
 * @summary Two functions cannot share a name in one namespace.
 * @topic Negative
 */
namespace Game
{
	int Score()
	{
		return 1;
	}

	int Score()
	{
		return 2;
	}
}
/** @end */
