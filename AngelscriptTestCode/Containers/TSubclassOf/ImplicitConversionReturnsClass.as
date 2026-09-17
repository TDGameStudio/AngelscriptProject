/**
 * @version v1
 * @summary A valid TSubclassOf converts back to the UClass it was set from.
 * @topic Containers
 *
 * ImplicitConversionReturnsClass
 */
/**
 * @begin ImplicitConversionReturnsClass
 * @summary A valid TSubclassOf converts back to the UClass it was set from.
 * @topic Containers
 */
UCLASS()
class UImplicitConversionObject : UObject
{
}

bool ImplicitConversionReturnsClass()
{
	TSubclassOf<UObject> Class;
	UClass Expected = UImplicitConversionObject::StaticClass();
	Class = Expected;
	return Class == Expected;
}
/** @end */
