/**
 * @version v1
 * @summary Enumerations declared inside a namespace.
 * @topic Language
 * @topic Namespace
 *
 * enum                                    // A namespaced enum selected through a qualified enumerator.
 * namespace-with-enum                     // An enum declared in a namespace is used unqualified inside that namespace.
 * enum-qualified-from-nested-namespace    // Enum enumerator accessed through a nested qualifier.
 * two-enums-same-namespace                // Two enumerations live in one namespace and are selected by qualification.
 * enum-as-function-argument               // A namespaced enum type is used as a function parameter.
 */
/**
 * @begin enum
 * @summary A namespaced enum selected through a qualified enumerator.
 */
namespace Game
{
	enum EPhase
	{
		Start,
		Play,
		End
	}
}

int PhaseValue()
{
	Game::EPhase Phase = Game::EPhase::Play;
	if (Phase == Game::EPhase::Play)
	{
		return 1;
	}
	return 0;
}
/** @end */
/**
 * @begin namespace-with-enum
 * @summary An enum declared in a namespace is used unqualified inside that namespace.
 * @topic Namespace
 */
namespace Game
{
	enum EPhase
	{
		Start,
		Play,
		End
	}

	int Inside()
	{
		EPhase Phase = EPhase::Play;
		if (Phase == EPhase::Play)
		{
			return 1;
		}
		return 0;
	}
}

int Outside()
{
	return Game::Inside();
}
/** @end */
/**
 * @begin enum-qualified-from-nested-namespace
 * @summary Enum enumerator accessed through a nested qualifier.
 * @topic Namespace
 */
namespace Game
{
	namespace Mode
	{
		enum ELane
		{
			Low,
			High
		}
	}
}

int UseLane()
{
	Game::Mode::ELane Lane = Game::Mode::ELane::High;
	return int(Lane);
}
/** @end */
/**
 * @begin two-enums-same-namespace
 * @summary Two enumerations live in one namespace and are selected by qualification.
 * @topic Namespace
 */
namespace Game
{
	enum EPhase
	{
		Start,
		End
	}

	enum ELane
	{
		Low,
		High
	}
}

int UseBoth()
{
	Game::EPhase Phase = Game::EPhase::End;
	Game::ELane Lane = Game::ELane::High;
	return int(Phase) + int(Lane);
}
/** @end */
/**
 * @begin enum-as-function-argument
 * @summary A namespaced enum type is used as a function parameter.
 * @topic Namespace
 */
namespace Game
{
	enum EPhase
	{
		Start,
		Play
	}
}

int TakePhase(Game::EPhase Phase)
{
	if (Phase == Game::EPhase::Play)
	{
		return 1;
	}
	return 0;
}

int UsePhaseArg()
{
	return TakePhase(Game::EPhase::Play);
}
/** @end */
