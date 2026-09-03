/**
 * TSoftObjectPtr.LoadAsync resolves the referenced asset on a background
 * path and invokes the callback once it is available. The callback may fire
 * immediately when the asset is already loaded, so the delegate must be
 * bound before the call and must tolerate a synchronous invocation.
 *
 * @Theme Containers.TSoftObjectPtr
 * @Subject TSoftObjectPtr.LoadAsync
 * @Harness Async
 * @Tag Containers.TSoftObjectPtr.TSoftObjectPtrLoadAsync
 * @Namespace TSoftObjectPtrTest
 */

UCLASS()
class UTSoftObjectPtrLoadAsyncObject : UObject
{
}

namespace TSoftObjectPtrTest
{
	/**
	 * Observe LoadAsync on a pointer that is already valid: the callback fires
	 * and the pointer resolves to the object it was assigned.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.LoadAsync
	 * @Inputs Pointer assigned a live object; LoadAsync with a capture callback
	 * @Return true when the callback fires and reports a non-null resolution
	 * @Boundary callback may fire synchronously for an already-loaded asset
	 */
	UFUNCTION()
	void LoadAsyncOnValidPointerInvokesCallback()
	{
		UObject Target = NewObject(GetTransientPackage(), UTSoftObjectPtrLoadAsyncObject::StaticClass(), n"TSoftPtrAsync_Valid", true);
		if (Target == nullptr)
		{
			return;
		}

		TSoftObjectPtr<UObject> Soft;
		Soft = Target;

		bool bCallbackFired = false;
		Soft.LoadAsync(FOnSoftObjectLoaded::BindLambda(
			[&bCallbackFired, Target](UObject Loaded)
			{
				bCallbackFired = true;
				ensure(Loaded == Target);
			}));

		ensure(bCallbackFired);
	}

	/**
	 * Observe LoadAsync on a pending pointer: the pointer names an asset that
	 * is not loaded, so the request is issued and the callback reports the
	 * outcome rather than the caller blocking on it.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.LoadAsync
	 * @Inputs Pointer constructed from an unloaded path; LoadAsync with a capture callback
	 * @Return void; the callback records whether the load resolved
	 * @Boundary pending state — no guarantee the named asset exists
	 */
	UFUNCTION()
	void LoadAsyncOnPendingPointerIssuesRequest()
	{
		TSoftObjectPtr<UObject> Soft;
		Soft = FSoftObjectPath("/Game/AngelscriptTest/NotLoaded.Never");

		bool bCallbackFired = false;
		Soft.LoadAsync(FOnSoftObjectLoaded::BindLambda(
			[&bCallbackFired](UObject Loaded)
			{
				bCallbackFired = true;
			}));

		ensure(bCallbackFired);
	}

	/**
	 * Observe that LoadAsync does not change the pointer's path: it requests a
	 * load, it does not rewrite the reference.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.LoadAsync
	 * @Inputs Pointer with a known path; LoadAsync; re-read the path
	 * @Return true when ToSoftObjectPath() is unchanged after the request
	 */
	UFUNCTION()
	void LoadAsyncDoesNotRewritePath()
	{
		TSoftObjectPtr<UObject> Soft;
		FSoftObjectPath Original("/Game/AngelscriptTest/SomePackage.SomeAsset");
		Soft = Original;

		Soft.LoadAsync(FOnSoftObjectLoaded::BindLambda(
			[](UObject Loaded)
			{
			}));

		ensure(Soft.ToSoftObjectPath() == Original);
	}

	/**
	 * Observe that Reset before the callback fires leaves the pointer null;
	 * a pending request does not resurrect the reference.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.Reset
	 * @Inputs Pointer with a path; LoadAsync; Reset immediately
	 * @Return true when IsNull() is true after the reset
	 * @Boundary request in flight vs cleared reference
	 */
	UFUNCTION()
	void ResetBeforeCallbackLeavesPointerNull()
	{
		TSoftObjectPtr<UObject> Soft;
		Soft = FSoftObjectPath("/Game/AngelscriptTest/SomePackage.SomeAsset");

		Soft.LoadAsync(FOnSoftObjectLoaded::BindLambda(
			[](UObject Loaded)
			{
			}));

		Soft.Reset();
		ensure(Soft.IsNull());
	}
}
