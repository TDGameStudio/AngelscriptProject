/**
 * TSubclassOf of a struct is rejected. The template subtype must be a
 * UObject-derived class, so a value type is not accepted.
 *
 * @Theme Containers.TSubclassOf
 * @Subject TSubclassOf.StructSubType
 * @Harness CompileReject
 * @Tag Containers.TSubclassOf.TSubclassOfOfStruct
 * @Kind CompileReject
 * @Covers TSubclassOf.Declaration
 * @Inputs TSubclassOf<FVector> Class
 * @Return does not compile
 * @Namespace TSubclassOfTest
 */

namespace TSubclassOfTest
{
	void Test()
	{
		TSubclassOf<FVector> Class;
	}
}
