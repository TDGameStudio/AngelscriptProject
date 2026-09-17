/**
 * @version v1
 * @summary Inner-scope names that shadow outer namespace names.
 * @topic Language
 * @topic Namespace
 *
 * shadowing
 * parameter-shadows-namespace
 * inner-block-shadows-local
 */
/**
 * @begin shadowing
 * @summary A local that shadows a namespace function of the same name.
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
 * @begin parameter-shadows-namespace
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
 * @begin inner-block-shadows-local
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
