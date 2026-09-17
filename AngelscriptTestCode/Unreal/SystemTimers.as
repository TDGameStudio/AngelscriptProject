/**
 * @version v1
 * @summary SystemTimers host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic SystemTimers
 *
 * set-timer
 * clear-and-invalidate-timer-handle
 * pause-timer-handle
 * un-pause-timer-handle
 * is-timer-paused-handle
 */
/**
 * @begin set-timer
 * @summary object is borrowed by the world timer manager until cleared.
 * @topic Unreal
 */
/**
 * @function ObserveSetTimerNominal
 * @summary object is borrowed by the world timer manager until cleared.
 * @covers SystemTimers.set-timer
 * @inputs SystemTimers values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSSystemTimersMutationHost : UObject
{

bool ObserveSetTimerNominal()
{
	UTSSystemTimersMutationHost Host;
	FTimerHandle SingleShot = System::SetTimer(Host, n"NoopTimerCallback", 0.25);
	bool bSingleShotActive = !System::IsTimerPausedHandle(SingleShot);
	FTimerHandle Looping = System::SetTimer(Host, n"NoopTimerCallback", 0.5, true);
	bool bLoopingActive = !System::IsTimerPausedHandle(Looping);
	FTimerHandle Repeated = System::SetTimer(Host, n"NoopTimerCallback", 0.5, true);
	bool bRepeatedActive = !System::IsTimerPausedHandle(Repeated);
	System::ClearAndInvalidateTimerHandle(SingleShot);
	System::ClearAndInvalidateTimerHandle(Looping);
	System::ClearAndInvalidateTimerHandle(Repeated);
	return bSingleShotActive && bLoopingActive && bRepeatedActive;
}
/** @end */
/**
 * @begin clear-and-invalidate-timer-handle
 * @summary object is borrowed by the world timer manager until cleared.
 * @topic Unreal
 */
/**
 * @function ObserveClearAndInvalidateTimerHandleNominal
 * @summary object is borrowed by the world timer manager until cleared.
 * @covers SystemTimers.clear-and-invalidate-timer-handle
 * @inputs SystemTimers values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSSystemTimersMutationHost : UObject
{

bool ObserveClearAndInvalidateTimerHandleNominal()
{
	UTSSystemTimersMutationHost Host;
	FTimerHandle Handle = System::SetTimer(Host, n"NoopTimerCallback", 0.5, true);
	bool bBeforeClearPaused = System::IsTimerPausedHandle(Handle);
	System::ClearAndInvalidateTimerHandle(Handle);
	bool bAfterClearPaused = System::IsTimerPausedHandle(Handle);
	System::ClearAndInvalidateTimerHandle(Handle);
	bool bRepeatedClearPaused = System::IsTimerPausedHandle(Handle);
	FTimerHandle Empty;
	System::ClearAndInvalidateTimerHandle(Empty);
	return !bBeforeClearPaused && !bAfterClearPaused && !bRepeatedClearPaused;
}
/** @end */
/**
 * @begin pause-timer-handle
 * @summary and do not own Handle.
 * @topic Unreal
 */
/**
 * @function ObservePauseTimerHandleNominal
 * @summary and do not own Handle.
 * @covers SystemTimers.pause-timer-handle
 * @inputs SystemTimers values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSSystemTimersPauseHost : UObject
{

bool ObservePauseTimerHandleNominal()
{
	FTimerHandle Empty;
	System::PauseTimerHandle(Empty);
	bool bEmptyPaused = System::IsTimerPausedHandle(Empty);
	UTSSystemTimersPauseHost Host;
	FTimerHandle Handle = System::SetTimer(Host, n"NoopTimerCallback", 0.5, true);
	System::PauseTimerHandle(Handle);
	bool bPaused = System::IsTimerPausedHandle(Handle);
	System::PauseTimerHandle(Handle);
	bool bRepeatedPause = System::IsTimerPausedHandle(Handle);
	System::ClearAndInvalidateTimerHandle(Handle);
	return !bEmptyPaused && bPaused && bRepeatedPause;
}
/** @end */
/**
 * @begin un-pause-timer-handle
 * @summary and do not own Handle.
 * @topic Unreal
 */
/**
 * @function ObserveUnPauseTimerHandleNominal
 * @summary and do not own Handle.
 * @covers SystemTimers.un-pause-timer-handle
 * @inputs SystemTimers values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSSystemTimersPauseHost : UObject
{

bool ObserveUnPauseTimerHandleNominal()
{
	FTimerHandle Empty;
	System::UnPauseTimerHandle(Empty);
	bool bEmptyPaused = System::IsTimerPausedHandle(Empty);
	UTSSystemTimersPauseHost Host;
	FTimerHandle Handle = System::SetTimer(Host, n"NoopTimerCallback", 0.5, true);
	System::PauseTimerHandle(Handle);
	bool bPaused = System::IsTimerPausedHandle(Handle);
	System::UnPauseTimerHandle(Handle);
	bool bUnpaused = System::IsTimerPausedHandle(Handle);
	System::UnPauseTimerHandle(Handle);
	bool bRepeatedUnpause = System::IsTimerPausedHandle(Handle);
	System::ClearAndInvalidateTimerHandle(Handle);
	return !bEmptyPaused && bPaused && !bUnpaused && !bRepeatedUnpause;
}
/** @end */
/**
 * @begin is-timer-paused-handle
 * @summary while the timer is registered.
 * @topic Unreal
 */
/**
 * @function ObserveIsTimerPausedHandleNominal
 * @summary while the timer is registered.
 * @covers SystemTimers.is-timer-paused-handle
 * @inputs SystemTimers values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSSystemTimersQueryHost : UObject
{

bool ObserveIsTimerPausedHandleNominal()
{
	FTimerHandle Empty;
	bool bEmptyPaused = System::IsTimerPausedHandle(Empty);
	UTSSystemTimersQueryHost Host;
	FTimerHandle Handle = System::SetTimer(Host, n"NoopTimerCallback", 0.5, true);
	bool bAfterSetPaused = System::IsTimerPausedHandle(Handle);
	System::PauseTimerHandle(Handle);
	bool bAfterPausePaused = System::IsTimerPausedHandle(Handle);
	System::UnPauseTimerHandle(Handle);
	bool bAfterUnPausePaused = System::IsTimerPausedHandle(Handle);
	System::ClearAndInvalidateTimerHandle(Handle);
	bool bAfterClearPaused = System::IsTimerPausedHandle(Handle);
	return !bEmptyPaused && !bAfterSetPaused && bAfterPausePaused && !bAfterUnPausePaused && !bAfterClearPaused;
}
/** @end */
