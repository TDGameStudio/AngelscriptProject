/**
 * @version v1
 * @summary A script delegate materializes a UDelegateFunction. FCoverageMacroSignal is single-cast; Signal is an FDelegateProperty whose signature exposes int Value.
 * @topic Feature
 */
/**
 * @version root
 * @summary A script delegate materializes a UDelegateFunction. FCoverageMacroSignal is single-cast; Signal is an FDelegateProperty whose signature exposes int Value.
 * @topic Baseline
 */
/**
 * A unicast that carries an int payload.
 *
 * @Covers Delegates.Declaration
 * @Inputs Value
 * @Return nothing when executed
 */
delegate void FCoverageMacroSignal(int Value);

UCLASS()
class ACoverageMacrosDelegateActor : AActor
{
	UPROPERTY()
	FCoverageMacroSignal Signal;

	/**
	 * Observe that a default-constructed actor handle is non-null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs a local ACoverageMacrosDelegateActor
	 * @Return true when the handle is non-null
	 * @Boundary default construct
	 */
	UFUNCTION()
	bool DefaultNonNull()
	{
		ACoverageMacrosDelegateActor Actor;
		return Actor != nullptr;
	}

	/**
	 * Observe that assigning nullptr yields a null handle.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Declaration
	 * @Inputs Actor = nullptr
	 * @Return true when the handle is null
	 * @Boundary nullptr assignment
	 */
	UFUNCTION()
	bool NullBoundary()
	{
		ACoverageMacrosDelegateActor Actor = nullptr;
		return Actor == nullptr;
	}
}
/** @end */
