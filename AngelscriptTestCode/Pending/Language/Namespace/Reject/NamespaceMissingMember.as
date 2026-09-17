/**
 * @version v1
 * @summary Reading a member that was never declared inside a namespace is rejected. The namespace itself exists and holds a member, but the qualified name names one that does not.
 * @topic Language
 */
/**
 * @version root
 * @summary Reading a member that was never declared inside a namespace is rejected. The namespace itself exists and holds a member, but the qualified name names one that does not.
 * @topic Negative
 */
namespace MySpaceBadAcc
{
	int X = 1;
}

/** */
void Test()
{
	int Y = MySpaceBadAcc::NonExistent;
}
/** @end */
