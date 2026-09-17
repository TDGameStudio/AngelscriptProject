/**
 * @version v1
 * @summary TSoftObjectPtr without a template argument is rejected. The template requires exactly one UObject-derived subtype.
 * @topic Containers
 */
/**
 * @version root
 * @summary TSoftObjectPtr without a template argument is rejected. The template requires exactly one UObject-derived subtype.
 * @topic Negative
 */
namespace TSoftObjectPtrTest
{
	void Test()
	{
		TSoftObjectPtr Soft;
	}
}
/** @end */
