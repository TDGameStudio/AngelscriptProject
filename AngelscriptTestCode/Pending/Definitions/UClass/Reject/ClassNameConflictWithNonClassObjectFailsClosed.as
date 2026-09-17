/**
 * @version v1
 * @summary A UCLASS whose name already belongs to a non-class Unreal object is rejected. Do not rename the class; that would make the program compile under the C++ fixture.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A UCLASS whose name already belongs to a non-class Unreal object is rejected. Do not rename the class; that would make the program compile under the C++ fixture.
 * @topic Negative
 */
UCLASS()
class UClassGeneratorNameConflictObject : UObject
{
	UPROPERTY()
	int Value = 1;
}
/** @end */
