/**
 * @version v1
 * @summary NativeModuleFunctionBinding host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic NativeModuleFunctionBinding
 *
 * aactor-staticclass-stays-callable
 */
/**
 * @begin aactor-staticclass-stays-callable
 * @summary AActor::StaticClass stays callable.
 * @topic Unreal
 */
/**
 * @function ObserveSurface001Nominal
 * @summary AActor::StaticClass stays callable.
 * @covers NativeModuleFunctionBinding.aactor-staticclass-stays-callable
 * @inputs NativeModuleFunctionBinding values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveSurface001Nominal()
{
	UClass ActorClass = AActor::StaticClass();
	UObject NullObject = nullptr;
	return ActorClass != nullptr && NullObject is null;
}
/** @end */
