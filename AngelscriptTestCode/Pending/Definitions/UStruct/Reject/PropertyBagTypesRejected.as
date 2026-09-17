/**
 * @version v1
 * @summary Property-bag types on a USTRUCT remain unsupported, so this program is rejected. FInstancedPropertyBag and FPropertyBag must not compile as members.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Property-bag types on a USTRUCT remain unsupported, so this program is rejected. FInstancedPropertyBag and FPropertyBag must not compile as members.
 * @topic Negative
 */
USTRUCT()
struct FPropertyBagBoundary
{
	FInstancedPropertyBag Foo;
	FPropertyBag Bar;
}
/** @end */
