/**
 * @version v1
 * @summary Nested namespace scope and qualified access.
 * @topic Language
 * @topic Namespace
 */
/**
 * @version root
 * @summary An inner namespace reached through a two-segment qualifier.
 * @topic Baseline
 */
namespace Outer
{
	namespace Inner
	{
		int Value()
		{
			return 4;
		}
	}
}

int NestedAccess()
{
	return Outer::Inner::Value();
}
/** @end */
/**
 * @version invalid-skip-inner-qualifier
 * @parent root
 * @summary The outer name alone does not expose the inner function.
 * @topic Negative
 */
int Test()
{
	return Outer::Value();
}
/** @end */
/**
 * @version valid-namespace-nested-access
 * @parent root
 * @summary Positive language form retained from legacy namespace nested access.
 * @topic Namespace
 */
const int OuterValue = 10;

	int OuterFunction()
	{
		return 100;
	}

	namespace Inner
	{
		const int InnerValue = 20;

		int InnerFunction()
		{
			return 200;
		}

		int AccessOuter()
		{
			return Outer::OuterFunction();
		}
	}

	int AccessInner()
	{
		return Inner::InnerFunction();
	}
/** @end */
/**
 * @version valid-namespace-nested-scope
 * @parent root
 * @summary Positive language form retained from legacy namespace nested scope.
 * @topic Namespace
 */
namespace Inner
	{
		int Value = 1;
	}
/** @end */
/**
 * @version invalid-namespace-missing-opening-brace
 * @parent root
 * @summary A namespace declaration requires an opening brace.
 * @topic Negative
 */
namespace Game
	int Score()
	{
		return 1;
	}
}
/** @end */
