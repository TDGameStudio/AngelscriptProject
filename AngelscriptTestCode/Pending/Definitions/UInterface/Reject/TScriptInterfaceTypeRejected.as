/**
 * @version v1
 * @summary A TScriptInterface property type is rejected without script interfaces. Do not add an interface declaration that would change the diagnostic.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A TScriptInterface property type is rejected without script interfaces. Do not add an interface declaration that would change the diagnostic.
 * @topic Negative
 */
UCLASS()
class ACoverageUnsupportedTScriptInterfaceActor : AActor
{
	UPROPERTY()
	TScriptInterface<ICoverageUnsupportedInterface> InterfaceRef;
}
/** @end */
