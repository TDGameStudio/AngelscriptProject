/**
 * TSubclassOf<TSubclassOf<UObject>> is rejected: a class wrapper is itself a
 * container, so nesting one inside another is rejected like any other
 * nested container.
 *
 * @Theme Containers.TSubclassOf
 * @Subject TSubclassOf.NestedSubclass
 * @Harness CompileReject
 * @Tag Containers.TSubclassOf.TSubclassOfNestedLocal
 * @Kind CompileReject
 * @Covers TSubclassOf.Declaration
 * @Inputs TSubclassOf<TSubclassOf<UObject>> Class
 * @Return does not compile; "Containers cannot be nested in other containers"
 * @Namespace TSubclassOfTest
 */

namespace TSubclassOfTest
{
	void Test()
	{
		TSubclassOf<TSubclassOf<UObject>> Class;
	}
}
