/**
 * @version v1
 * @summary Qualified namespace names and qualified calls.
 * @topic Language
 * @topic Namespace
 *
 * qualified-name              // A named namespace function invoked through a qualified name.
 * namespace-qualified-call    // A namespaced function is invoked with an argument through a qualifier.
 * namespace-qualified-name    // A namespaced constant is read through a qualified name.
 * multi-segment-qualifier     // A three-segment qualified function call.
 * qualified-enum-member       // An enumerator is selected through a namespace qualifier.
 * qualified-struct-type       // A struct type is named through a namespace qualifier.
 */
/**
 * @begin qualified-name
 * @summary A named namespace function invoked through a qualified name.
 */
namespace Tools
{
	int Offset()
	{
		return 3;
	}
}

int QualifiedCall()
{
	return Tools::Offset();
}
/** @end */
/**
 * @begin namespace-qualified-call
 * @summary A namespaced function is invoked with an argument through a qualifier.
 * @topic Namespace
 */
namespace Tools
{
	int Add(int Value)
	{
		return Value + 3;
	}
}

int CallAdd()
{
	return Tools::Add(4);
}
/** @end */
/**
 * @begin namespace-qualified-name
 * @summary A namespaced constant is read through a qualified name.
 * @topic Namespace
 */
namespace Tools
{
	const int Offset = 3;
}

int ReadOffset()
{
	return Tools::Offset;
}
/** @end */
/**
 * @begin multi-segment-qualifier
 * @summary A three-segment qualified function call.
 * @topic Namespace
 */
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

int Use()
{
	return Game::Combat::Hit();
}
/** @end */
/**
 * @begin qualified-enum-member
 * @summary An enumerator is selected through a namespace qualifier.
 * @topic Namespace
 */
namespace Tools
{
	enum EKind
	{
		Low,
		High
	}
}

int ReadKind()
{
	return int(Tools::EKind::High);
}
/** @end */
/**
 * @begin qualified-struct-type
 * @summary A struct type is named through a namespace qualifier.
 * @topic Namespace
 */
namespace Tools
{
	struct FSize
	{
		int Width;
	}
}

int ReadWidth()
{
	Tools::FSize Size;
	Size.Width = 4;
	return Size.Width;
}
/** @end */
