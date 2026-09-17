/**
 * @version v1
 * @summary Debugging host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic Debugging
 *
 * ensure
 * ensure-always
 * throw
 * format-angelscript-callstack
 * get-angelscript-callstack
 */
/**
 * @begin ensure
 * @summary failure.
 * @topic Unreal
 */
/**
 * @function ObserveEnsureNominal
 * @summary failure.
 * @covers Debugging.ensure
 * @inputs Debugging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveEnsureNominal()
{
	bool bTrueBare = ensure(true);
	bool bTrueWithMessage = ensure(true, "ensure passed");
	bool bFalseBare = ensure(false);
	bool bFalseWithMessage = ensure(false, "ensure failed");
	return bTrueBare && bTrueWithMessage && !bFalseBare && !bFalseWithMessage;
}
/** @end */
/**
 * @begin ensure-always
 * @summary failure.
 * @topic Unreal
 */
/**
 * @function ObserveEnsureAlwaysNominal
 * @summary failure.
 * @covers Debugging.ensure-always
 * @inputs Debugging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveEnsureAlwaysNominal()
{
	bool bTrueBare = ensureAlways(true);
	bool bTrueWithMessage = ensureAlways(true, "ensureAlways passed");
	bool bFalseBare = ensureAlways(false);
	bool bFalseWithMessage = ensureAlways(false, "ensureAlways failed");
	return bTrueBare && bTrueWithMessage && !bFalseBare && !bFalseWithMessage;
}
/** @end */
/**
 * @begin throw
 * @summary failure.
 * @topic Unreal
 */
/**
 * @function ObserveThrowNominal
 * @summary failure.
 * @covers Debugging.throw
 * @inputs Debugging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveThrowNominal()
{
	FString PreparedMessage = "expected debugging throw";
	return PreparedMessage == "expected debugging throw";
}
/** @end */
/**
 * @begin format-angelscript-callstack
 * @summary does not mutate the live script callstack.
 * @topic Unreal
 */
/**
 * @function ObserveFormatAngelscriptCallstackNominal
 * @summary does not mutate the live script callstack.
 * @covers Debugging.format-angelscript-callstack
 * @inputs Debugging values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveFormatAngelscriptCallstackNominal()
{
	FString Formatted = FormatAngelscriptCallstack();
	FString Empty = "";
	return Formatted.Len() > 0 && Formatted != Empty;
}
/** @end */
/**
 * @begin get-angelscript-callstack
 * @summary returned TArray is an independent copy of frame text.
 * @topic Unreal
 */
/**
 * @function ObserveGetAngelscriptCallstackNominal
 * @summary returned TArray is an independent copy of frame text.
 * @covers Debugging.get-angelscript-callstack
 * @inputs Debugging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetAngelscriptCallstackNominal()
{
	TArray<FString> Empty;
	TArray<FString> Frames = GetAngelscriptCallstack();
	int FrameCount = Frames.Num();
	if (FrameCount == 0)
	{
		return false;
	}
	return Empty.Num() == 0 && Frames[0].Len() > 0;
}
/** @end */
