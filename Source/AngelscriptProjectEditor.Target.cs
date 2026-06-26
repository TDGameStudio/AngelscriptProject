// Copyright Epic Games, Inc. All Rights Reserved.

using UnrealBuildTool;
using System.Collections.Generic;

public class AngelscriptProjectEditorTarget : TargetRules
{
	public AngelscriptProjectEditorTarget( TargetInfo Target) : base(Target)
	{
		Type = TargetType.Editor;
		DefaultBuildSettings = BuildSettingsVersion.V7;
		IncludeOrderVersion = EngineIncludeOrderVersion.Unreal5_8;
		ExtraModuleNames.Add("AngelscriptProject");
		ExtraModuleNames.Add("AngelscriptProjectTest");

		// NOTE (BindFreeCompleteness Phase 2): we originally planned to enable
		//   GlobalDefinitions.Add("MALLOC_LEAKDETECTION=1");
		// to drive the `mallocleak.*` console commands with real callstacks. On
		// an *installed* Engine that path is unreachable: the shipped Core.dll
		// was built with MALLOC_LEAKDETECTION=0 so `DumpOpenCallstacks` is not
		// exported, and a Unique build environment is rejected for installed
		// targets. The investigation therefore relies on LLM CSV evidence + the
		// FPlatformMemory probe in `AcquireTransientFullTestEngine` instead.
		// Re-enable this define only when building against an Engine source
		// tree (Plugins/Angelscript/Source/Angelscript.Build.cs sandbox).
	}
}
