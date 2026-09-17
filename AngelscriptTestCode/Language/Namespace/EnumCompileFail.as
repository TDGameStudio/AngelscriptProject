/**
 * @version v1
 * @summary Compile-fail cases for Enum.
 * @topic Language
 * @topic Namespace
 *
 * invalid-unqualified-namespaced-enum    // A namespaced enum type is not visible without its qualifier.
 * invalid-enum-missing-qualifier         // A namespaced enumerator is not visible without its qualifier.
 */
/**
 * @begin invalid-unqualified-namespaced-enum
 * @summary A namespaced enum type is not visible without its qualifier.
 * @topic Negative
 */
void Test()
{
	EPhase Phase = EPhase::Play;
}
/** @end */
/**
 * @begin invalid-enum-missing-qualifier
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
