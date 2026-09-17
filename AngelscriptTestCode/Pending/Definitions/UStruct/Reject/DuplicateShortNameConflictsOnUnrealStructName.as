/**
 * @version v1
 * @summary Two namespaced USTRUCTs that share the Unreal short name collide, so this program is rejected. C++ reports a name conflict on SharedSyntaxStruct.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Two namespaced USTRUCTs that share the Unreal short name collide, so this program is rejected. C++ reports a name conflict on SharedSyntaxStruct.
 * @topic Negative
 */
namespace First
{
	USTRUCT()
	struct FSharedSyntaxStruct
	{
		UPROPERTY()
		int A;
	}
}

namespace Second
{
	USTRUCT()
	struct FSharedSyntaxStruct
	{
		UPROPERTY()
		int B;
	}
}
/** @end */
