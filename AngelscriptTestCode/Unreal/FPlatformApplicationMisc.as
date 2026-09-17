/**
 * @version v1
 * @summary FPlatformApplicationMisc host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic FPlatformApplicationMisc
 *
 * clipboard-copy
 * clipboard-paste
 */
/**
 * @begin clipboard-copy
 * @summary restores the snapshot via ClipboardCopy.
 * @topic Unreal
 */
/**
 * @function ObserveClipboardCopyNominal
 * @summary restores the snapshot via ClipboardCopy.
 * @covers FPlatformApplicationMisc.clipboard-copy
 * @inputs FPlatformApplicationMisc values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveClipboardCopyNominal(bool bAllowHostClipboardMutation)
{
	if (!bAllowHostClipboardMutation)
	{
		throw("TS_FPlatformApplicationMisc_NamespaceAndGlobalFunctions_01 setup: clipboard mutation requires FixtureIsolated host");
	}
	FString Snapshot;
	FPlatformApplicationMisc::ClipboardPaste(Snapshot);
	FPlatformApplicationMisc::ClipboardCopy("TestSource.Clipboard");
	FString Dest;
	FPlatformApplicationMisc::ClipboardPaste(Dest);
	bool bCopiedText = Dest == "TestSource.Clipboard";
	FPlatformApplicationMisc::ClipboardCopy("");
	FString EmptyDest = "Sentinel";
	FPlatformApplicationMisc::ClipboardPaste(EmptyDest);
	bool bEmptyCopyConsumed = EmptyDest != "Sentinel" && EmptyDest.Len() == 0;
	FPlatformApplicationMisc::ClipboardCopy(Snapshot);
	return bCopiedText && bEmptyCopyConsumed;
}
/** @end */
/**
 * @begin clipboard-paste
 * @summary restores the snapshot via ClipboardCopy.
 * @topic Unreal
 */
/**
 * @function ObserveClipboardPasteNominal
 * @summary restores the snapshot via ClipboardCopy.
 * @covers FPlatformApplicationMisc.clipboard-paste
 * @inputs FPlatformApplicationMisc values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveClipboardPasteNominal(bool bAllowHostClipboardMutation)
{
	if (!bAllowHostClipboardMutation)
	{
		throw("TS_FPlatformApplicationMisc_NamespaceAndGlobalFunctions_01 setup: clipboard mutation requires FixtureIsolated host");
	}
	FString Snapshot;
	FPlatformApplicationMisc::ClipboardPaste(Snapshot);
	FString Dest = "Sentinel";
	FString Before = Dest;
	FPlatformApplicationMisc::ClipboardCopy("TestSource.Clipboard.Paste");
	FPlatformApplicationMisc::ClipboardPaste(Dest);
	bool bWritebackReplacedSentinel = Dest != Before && Dest == "TestSource.Clipboard.Paste";
	FPlatformApplicationMisc::ClipboardCopy(Snapshot);
	return bWritebackReplacedSentinel;
}
/** @end */
