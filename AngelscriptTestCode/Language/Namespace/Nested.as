/**
 * @version v1
 * @summary Nested namespace scope and qualified access.
 * @topic Language
 * @topic Namespace
 *
 * nested
 * namespace-nested-access
 * namespace-nested-scope
 */
/**
 * @begin nested
 * @summary An inner namespace reached through a two-segment qualifier.
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
 * @begin namespace-nested-access
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
 * @begin namespace-nested-scope
 * @summary Positive language form retained from legacy namespace nested scope.
 * @topic Namespace
 */
namespace Inner
	{
		int Value = 1;
	}
/** @end */
