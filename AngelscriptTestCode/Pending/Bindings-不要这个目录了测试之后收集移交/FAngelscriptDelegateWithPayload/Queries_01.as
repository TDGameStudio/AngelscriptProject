/**
 * @version v1
 * @summary Observe FAngelscriptDelegateWithPayload.IsBound for empty, bound, and rebound receivers. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FAngelscriptDelegateWithPayload.IsBound for empty, bound, and rebound receivers. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// BindWithPayload to OnIntPayload with 41.
// Expected observations: Default IsBound is false. After BindUFunction it is
// true. After BindWithPayload it remains true because both a live object and
// function name are stored.
// Boundary/ownership: IsBound requires a live target object and a non-none
// function name. It does not execute or copy the payload.

UCLASS()
class UTSDelegateWithPayloadQueryReceiver : UObject
{
	bool bFlag = false;
	int PayloadValue = 0;

	UFUNCTION()
	void OnNoPayload()
	{
		bFlag = true;
	}

	UFUNCTION()
	void OnIntPayload(int Value)
	{
		PayloadValue = Value;
	}
}

namespace TS_FAngelscriptDelegateWithPayload_Queries_01
{
	bool Observe_IsBound_Nominal()
	{
		FAngelscriptDelegateWithPayload Delegate;
		bool bDefaultUnbound = Delegate.IsBound();

		UTSDelegateWithPayloadQueryReceiver Receiver;
		if (Receiver is null)
		{
			throw("TS_FAngelscriptDelegateWithPayload_Queries_01 setup: required Receiver is null");
		}
		Delegate.BindUFunction(Receiver, n"OnNoPayload");
		bool bBoundWithoutPayload = Delegate.IsBound();

		Delegate.BindWithPayload(Receiver, n"OnIntPayload", 41);
		bool bBoundWithPayload = Delegate.IsBound();

		return !bDefaultUnbound && bBoundWithoutPayload && bBoundWithPayload;
	}
}
/** @end */
