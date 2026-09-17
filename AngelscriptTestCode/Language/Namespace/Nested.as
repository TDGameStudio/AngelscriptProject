/**
 * @version v1
 * @summary Nested namespace scope and qualified access.
 * @topic Language
 * @topic Namespace
 *
 * nested                     // An inner namespace reached through a two-segment qualifier.
 * namespace-nested-access    // Outer scope reaches an inner name, and the inner name is also reached globally.
 * namespace-nested-scope     // A name declared in an inner namespace is read inside that same scope.
 * three-level-nested         // A function is reached through three nested namespace segments.
 * inner-calls-outer          // An inner namespace calls a function in its outer namespace.
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
 * @summary Outer scope reaches an inner name, and the inner name is also reached globally.
 * @topic Namespace
 */
namespace Outer
{
	int Root()
	{
		return 10;
	}

	namespace Inner
	{
		int Leaf()
		{
			return 20;
		}
	}

	int FromOuter()
	{
		return Inner::Leaf();
	}
}

int FromGlobal()
{
	return Outer::Inner::Leaf() + Outer::Root();
}
/** @end */
/**
 * @begin namespace-nested-scope
 * @summary A name declared in an inner namespace is read inside that same scope.
 * @topic Namespace
 */
namespace Outer
{
	namespace Inner
	{
		int Value = 1;

		int Read()
		{
			return Value;
		}
	}
}

int UseInnerScope()
{
	return Outer::Inner::Read();
}
/** @end */
/**
 * @begin three-level-nested
 * @summary A function is reached through three nested namespace segments.
 * @topic Namespace
 */
namespace World
{
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
}

int UseDeep()
{
	return World::Game::Combat::Hit();
}
/** @end */
/**
 * @begin inner-calls-outer
 * @summary An inner namespace calls a function in its outer namespace.
 * @topic Namespace
 */
namespace Outer
{
	int Root()
	{
		return 5;
	}

	namespace Inner
	{
		int UseRoot()
		{
			return Outer::Root();
		}
	}
}

int CallInner()
{
	return Outer::Inner::UseRoot();
}
/** @end */
