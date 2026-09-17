/**
 * @version v1
 * @summary Compile-fail cases for GlobalVersusScoped.
 * @topic Language
 * @topic Namespace
 *
 * invalid-ambiguous-unqualified-after-using    // An unqualified name is invalid when a using-directive makes it ambiguous.
 */
/**
 * @begin invalid-ambiguous-unqualified-after-using
 * @summary An unqualified name is invalid when a using-directive makes it ambiguous.
 * @topic Negative
 */
using namespace Game;

int Test()
{
	return Amount();
}
/** @end */
