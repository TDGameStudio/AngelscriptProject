/**
 * @version v1
 * @summary LoadAsync of TSoftObjectPtr<AActor> throws Actor soft references cannot be loaded, stream the level in instead.
 * @topic Containers
 * LoadAsyncActorForbidden
 */
/**
 * @begin LoadAsyncActorForbidden
 * @summary LoadAsync of TSoftObjectPtr<AActor> throws Actor soft references cannot be loaded, stream the level in instead.
 * @topic Containers
 */
void LoadAsyncActorForbidden()
{
	FOnSoftObjectLoaded OnLoaded;
	TSoftObjectPtr<AActor> ActorRef;
	ActorRef.LoadAsync(OnLoaded);
}
/** @end */
