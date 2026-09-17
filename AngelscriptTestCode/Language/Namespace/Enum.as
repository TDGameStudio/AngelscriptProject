/**
 * @version v1
 * @summary Enumerations declared inside a namespace.
 * @topic Language
 * @topic Namespace
 *
 * enum
 * namespace-with-enum
 * enum-qualified-from-nested-namespace
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
 * @summary Positive language form retained from legacy namespace with enum.
 * @topic Namespace
 */
enum MyEnum
	{
		First,
		Second,
		Third
	}

	int UseEnum(MyEnum E)
	{
		switch (E)
		{
			case MyEnum::First:
				return 1;
			case MyEnum::Second:
				return 2;
			case MyEnum::Third:
				return 3;
		}
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
