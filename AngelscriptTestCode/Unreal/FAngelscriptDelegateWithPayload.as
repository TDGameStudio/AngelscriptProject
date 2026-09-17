/**
 * @version v1
 * @summary FAngelscriptDelegateWithPayload host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FAngelscriptDelegateWithPayload
 *
 * execute-if-bound
 * bind-u-function
 * bind-with-payload
 * is-bound
 */
/**
 * @begin execute-if-bound
 * @summary signatures raise and are outside this Positive file.
 * @topic Unreal
 */
/**
 * @function ObserveExecuteIfBoundNominal
 * @summary signatures raise and are outside this Positive file.
 * @covers FAngelscriptDelegateWithPayload.execute-if-bound
 * @inputs FAngelscriptDelegateWithPayload values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSDelegateWithPayloadMutationReceiver : UObject
{
	bool bFlag = false;
	int PayloadValue = 0;
	int NoPayloadCount = 0;

bool ObserveExecuteIfBoundNominal()
{
	UTSDelegateWithPayloadMutationReceiver Receiver;
	if (Receiver is null)
	{
		throw("TS_FAngelscriptDelegateWithPayload_MutationAndLifecycle_01 setup: required Receiver is null");
	}
	Receiver.bFlag = false;
	Receiver.PayloadValue = 3;
	FAngelscriptDelegateWithPayload Unbound;
	Unbound.ExecuteIfBound();
	bool bUnboundIsNoOp = !Receiver.bFlag && Receiver.PayloadValue == 3;

	FAngelscriptDelegateWithPayload Bound;
	Bound.BindUFunction(Receiver, n"OnNoPayload");
	Bound.ExecuteIfBound();
	bool bBoundPathInvoked = Receiver.bFlag && Receiver.NoPayloadCount == 1;

	Bound.ExecuteIfBound();
	bool bRepeatedExecuteInvoked = Receiver.NoPayloadCount == 2;

	return bUnboundIsNoOp && bBoundPathInvoked && bRepeatedExecuteInvoked;
}
/** @end */
/**
 * @begin bind-u-function
 * @summary signatures raise and are outside this Positive file.
 * @topic Unreal
 */
/**
 * @function ObserveBindUFunctionNominal
 * @summary signatures raise and are outside this Positive file.
 * @covers FAngelscriptDelegateWithPayload.bind-u-function
 * @inputs FAngelscriptDelegateWithPayload values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSDelegateWithPayloadMutationReceiver : UObject
{
	bool bFlag = false;
	int PayloadValue = 0;
	int NoPayloadCount = 0;

bool ObserveBindUFunctionNominal()
{
	UTSDelegateWithPayloadMutationReceiver Receiver;
	if (Receiver is null)
	{
		throw("TS_FAngelscriptDelegateWithPayload_MutationAndLifecycle_01 setup: required Receiver is null");
	}
	Receiver.bFlag = false;
	Receiver.PayloadValue = 9;
	FAngelscriptDelegateWithPayload Delegate;
	Delegate.BindUFunction(Receiver, n"OnNoPayload");
	bool bBoundAfterBind = Delegate.IsBound();
	Delegate.ExecuteIfBound();
	bool bNoPayloadInvoked = Receiver.bFlag && Receiver.PayloadValue == 9;

	Delegate.BindUFunction(Receiver, n"OnNoPayload");
	bool bRepeatedBindRemainsBound = Delegate.IsBound();

	return bBoundAfterBind && bNoPayloadInvoked && bRepeatedBindRemainsBound;
}
/** @end */
/**
 * @begin bind-with-payload
 * @summary signatures raise and are outside this Positive file.
 * @topic Unreal
 */
/**
 * @function ObserveBindWithPayloadNominal
 * @summary signatures raise and are outside this Positive file.
 * @covers FAngelscriptDelegateWithPayload.bind-with-payload
 * @inputs FAngelscriptDelegateWithPayload values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSDelegateWithPayloadMutationReceiver : UObject
{
	bool bFlag = false;
	int PayloadValue = 0;
	int NoPayloadCount = 0;

bool ObserveBindWithPayloadNominal()
{
	UTSDelegateWithPayloadMutationReceiver Receiver;
	if (Receiver is null)
	{
		throw("TS_FAngelscriptDelegateWithPayload_MutationAndLifecycle_01 setup: required Receiver is null");
	}
	Receiver.bFlag = false;
	Receiver.PayloadValue = 0;
	Receiver.NoPayloadCount = 0;
	FAngelscriptDelegateWithPayload Delegate;
	int Payload = 41;
	Delegate.BindWithPayload(Receiver, n"OnIntPayload", Payload);
	bool bBoundWithPayload = Delegate.IsBound();
	Delegate.ExecuteIfBound();
	bool bPayloadCopiedAndDelivered = Receiver.PayloadValue == 41 && Payload == 41;

	Delegate.BindWithPayload(Receiver, n"OnIntPayload", 7);
	Delegate.ExecuteIfBound();
	bool bRepeatedPayloadReplaced = Receiver.PayloadValue == 7;

	Delegate.BindUFunction(Receiver, n"OnNoPayload");
	int PayloadBeforeClearingBind = Receiver.PayloadValue;
	Delegate.ExecuteIfBound();
	bool bBindUFunctionClearedPayloadPath =
		Delegate.IsBound() &&
		Receiver.NoPayloadCount == 1 &&
		Receiver.PayloadValue == PayloadBeforeClearingBind;

	return bBoundWithPayload && bPayloadCopiedAndDelivered && bRepeatedPayloadReplaced && bBindUFunctionClearedPayloadPath;
}
/** @end */
/**
 * @begin is-bound
 * @summary function name.
 * @topic Unreal
 */
/**
 * @function ObserveIsBoundNominal
 * @summary function name.
 * @covers FAngelscriptDelegateWithPayload.is-bound
 * @inputs FAngelscriptDelegateWithPayload values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSDelegateWithPayloadQueryReceiver : UObject
{
	bool bFlag = false;
	int PayloadValue = 0;

bool ObserveIsBoundNominal()
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
/** @end */
