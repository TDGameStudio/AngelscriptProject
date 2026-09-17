/**
 * @version v1
 * @summary A USTRUCT whose name already belongs to a non-struct Unreal object is rejected. Do not rename the struct; that would make the program compile under the C++ fixture.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A USTRUCT whose name already belongs to a non-struct Unreal object is rejected. Do not rename the struct; that would make the program compile under the C++ fixture.
 * @topic Negative
 */
USTRUCT()
struct FClassGeneratorNameConflictStruct
{
	UPROPERTY()
	int Value = 1;
}
/** @end */
