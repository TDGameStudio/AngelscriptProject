/**
 * @version v1
 * @summary Enumerations declared inside a namespace.
 * @topic Language
 * @topic Namespace
 */
/**
 * @version root
 * @summary A namespaced enum selected through a qualified enumerator.
 * @topic Baseline
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
 * @version invalid-unqualified-namespaced-enum
 * @parent root
 * @summary A namespaced enum type is not visible without its qualifier.
 * @topic Negative
 */
void Test()
{
	EPhase Phase = EPhase::Play;
}
/** @end */
/**
 * @version valid-namespace-with-enum
 * @parent root
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
 * @version valid-enum-qualified-from-nested-namespace
 * @parent root
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
 * @version invalid-enum-missing-qualifier
 * @parent root
 * @summary A namespaced enumerator is not visible without its qualifier.
 * @topic Negative
 */
namespace Game
{
	enum ELane
	{
		Low
	}
}

void Test()
{
	ELane Lane = Low;
}
/** @end */
