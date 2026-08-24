// Purpose: Observe clipboard copy and paste writeback, including empty text,
// with snapshot/restore so the host clipboard is not left mutated.
// This file is not default-executable.
// AS-facing API: void FPlatformApplicationMisc::ClipboardCopy(const FString& Str);
// void FPlatformApplicationMisc::ClipboardPaste(FString& Dest);
// Inputs: Runner must pass bAllowHostClipboardMutation=true.
// "TestSource.Clipboard" as the non-empty copy, empty string copy, and a
// seeded Dest recorded before paste.
// Expected observations: Copy then paste writes the same text into Dest.
// Empty copy pastes empty. Dest is recorded before and after paste.
// Boundary/ownership: FixtureIsolated. SetupOwner=Runner. CleanupOwner=Source
// restores the snapshot via ClipboardCopy. Missing allow-flag is setup failure.

namespace TS_FPlatformApplicationMisc_NamespaceAndGlobalFunctions_01
{
	bool Observe_ClipboardCopy_Nominal(bool bAllowHostClipboardMutation)
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

	bool Observe_ClipboardPaste_Nominal(bool bAllowHostClipboardMutation)
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
}
