/**
 * @version v1
 * @summary Inner-scope names that shadow outer namespace names.
 * @topic Language
 * @topic Namespace
 */
/**
 * @version root
 * @summary A local that shadows a namespace function of the same name.
 * @topic Baseline
 */
namespace Game
{
	int Score()
	{
		return 10;
	}
}

int ShadowedLocal()
{
	int Score = 1;
	return Score + Game::Score();
}
/** @end */
/**
 * @version invalid-shadowed-type-as-value
 * @parent root
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
 * @version valid-parameter-shadows-namespace
 * @parent root
 * @summary A parameter name shadows a namespace function.
 * @topic Namespace
 */
namespace Game
{
	int Score()
	{
		return 10;
	}
}

int UseShadow(int Score)
{
	return Score + Game::Score();
}
/** @end */
/**
 * @version valid-inner-block-shadows-local
 * @parent root
 * @summary An inner block local shadows an outer local.
 * @topic Namespace
 */
int InnerShadow()
{
	int Score = 1;
	{
		int Score = 2;
		return Score;
	}
}
/** @end */
/**
 * @version invalid-duplicate-in-same-namespace
 * @parent root
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
