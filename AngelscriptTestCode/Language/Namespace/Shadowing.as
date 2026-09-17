/**
 * @version v1
 * @summary Inner-scope names that shadow outer namespace names.
 * @topic Language
 * @topic Namespace
 *
 * shadowing                              // A local that shadows a namespace function of the same name.
 * parameter-shadows-namespace            // A parameter name shadows a namespace function.
 * inner-block-shadows-local              // An inner block local shadows an outer local.
 * function-shadows-namespace-function    // A global function shares a name with a namespace function.
 * local-shadows-namespace-const          // A local variable shadows a namespace constant of the same name.
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
/**
 * @begin function-shadows-namespace-function
 * @summary A global function shares a name with a namespace function.
 * @topic Namespace
 */
namespace Game
{
	int Score()
	{
		return 10;
	}
}

int Score()
{
	return 1;
}

int UseBoth()
{
	return Score() + Game::Score();
}
/** @end */
/**
 * @begin local-shadows-namespace-const
 * @summary A local variable shadows a namespace constant of the same name.
 * @topic Namespace
 */
namespace Game
{
	const int Score = 10;
}

int UseShadowedConst()
{
	int Score = 1;
	return Score + Game::Score;
}
/** @end */
