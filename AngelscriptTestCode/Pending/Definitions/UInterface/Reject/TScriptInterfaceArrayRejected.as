/**
 * @version v1
 * @summary TArray of TScriptInterface is an explicit unsupported container boundary. Do not add an interface declaration that would change the diagnostic.
 * @topic Definitions
 */
/**
 * @version root
 * @summary TArray of TScriptInterface is an explicit unsupported container boundary. Do not add an interface declaration that would change the diagnostic.
 * @topic Negative
 */
UCLASS()
class ACoverageUnsupportedTScriptInterfaceArrayActor : AActor
{
	UPROPERTY()
	TArray<TScriptInterface<ICoverageUnsupportedInterface>> InterfaceRefs;
}
/** @end */
