/**
 * @version v1
 * @summary Observe whether a world timer handle is paused, including empty, running, paused, and invalidated handles. The bool return is the runner-readable oracle.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe whether a world timer handle is paused, including empty, running, paused, and invalidated handles. The bool return is the runner-readable oracle.
 * @topic Baseline
 */
// UTSSystemTimersQueryHost.NoopTimerCallback as the running handle, the same
// handle after PauseTimerHandle, and the handle after UnPauseTimerHandle.
// Expected observations: Empty handles report not paused. A newly set looping
// timer reports not paused. After PauseTimerHandle the same handle reports
// paused. After UnPauseTimerHandle it reports not paused again.
// Boundary/ownership: IsTimerPausedHandle borrows the current world from the
// WorldContext. It does not own the handle. The host object must remain alive
// while the timer is registered.

UCLASS()
class UTSSystemTimersQueryHost : UObject
{
	UFUNCTION()
	void NoopTimerCallback()
	{
	}
}

namespace TS_SystemTimers_Queries_01
{
	bool Observe_IsTimerPausedHandle_Nominal()
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
}
/** @end */
