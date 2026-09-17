/**
 * @version v1
 * @summary TOptional without a template argument is rejected. The template is declared as TOptional<class T>, so the argument is mandatory.
 * @topic Containers
 */
/**
 * @version root
 * @summary TOptional without a template argument is rejected. The template is declared as TOptional<class T>, so the argument is mandatory.
 * @topic Negative
 */
namespace TOptionalTest
{
	void Test()
	{
		TOptional Opt;
	}
}
/** @end */
