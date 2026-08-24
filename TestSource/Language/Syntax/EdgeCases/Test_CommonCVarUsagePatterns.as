// Theme: Language.Syntax.EdgeCases. Positive common CVar usage patterns.
// C++: AngelscriptCoverageCVarTests.cpp::CommonCVarUsagePatterns
// sha256=f483e04f00f68cb5b8de658ae1ef57104d5ed3717a2b868d70a4b9f03f9e61bf; lines 835-921.
// $ARGn$ become runner name parameters. Oracle: ApplyRenderScale==76.25,
// ApplyRenderQuality==11, ApplyPerformanceSettings==121, ApplyDebugToggles==4,
// ApplyHighQuality==106. Extra: ApplyScalabilitySettings(0)==85. DefaultSafe.

float ApplyRenderScale(const FString& ScreenPercentageName, const FString& ViewDistanceScaleName)
{
	FConsoleVariable ScreenPercentage(ScreenPercentageName, 100.0f, "screen percentage");
	FConsoleVariable ViewDistanceScale(ViewDistanceScaleName, 1.0f, "view distance scale");
	ScreenPercentage.SetFloat(75.0f);
	ViewDistanceScale.SetFloat(1.25f);
	return ScreenPercentage.GetFloat() + ViewDistanceScale.GetFloat();
}

int ApplyRenderQuality(
	const FString& VSyncName,
	const FString& ShadowQualityName,
	const FString& PostProcessQualityName,
	const FString& TextureQualityName,
	const FString& EffectsQualityName,
	const FString& FoliageQualityName)
{
	FConsoleVariable VSync(VSyncName, 0, "vsync");
	FConsoleVariable ShadowQuality(ShadowQualityName, 3, "shadow quality");
	FConsoleVariable PostProcessQuality(PostProcessQualityName, 3, "post process quality");
	FConsoleVariable TextureQuality(TextureQualityName, 3, "texture quality");
	FConsoleVariable EffectsQuality(EffectsQualityName, 3, "effects quality");
	FConsoleVariable FoliageQuality(FoliageQualityName, 3, "foliage quality");
	VSync.SetInt(1);
	ShadowQuality.SetInt(2);
	PostProcessQuality.SetInt(2);
	TextureQuality.SetInt(2);
	EffectsQuality.SetInt(2);
	FoliageQuality.SetInt(2);
	return VSync.GetInt()
		+ ShadowQuality.GetInt()
		+ PostProcessQuality.GetInt()
		+ TextureQuality.GetInt()
		+ EffectsQuality.GetInt()
		+ FoliageQuality.GetInt();
}

float ApplyPerformanceSettings(const FString& MaxFPSName, const FString& ResolutionName)
{
	FConsoleVariable MaxFPS(MaxFPSName, 0.0f, "max fps");
	FConsoleVariable Resolution(ResolutionName, "1280x720w", "resolution");
	MaxFPS.SetFloat(120.0f);
	Resolution.SetString("1920x1080w");
	return MaxFPS.GetFloat() + (Resolution.GetString() == "1920x1080w" ? 1.0f : 0.0f);
}

int ApplyDebugToggles(
	const FString& ShowCollisionName,
	const FString& ShowBoundsName,
	const FString& StatFPSName,
	const FString& StatUnitName)
{
	FConsoleVariable ShowCollision(ShowCollisionName, 0, "show collision");
	FConsoleVariable ShowBounds(ShowBoundsName, 0, "show bounds");
	FConsoleVariable StatFPS(StatFPSName, 0, "stat fps");
	FConsoleVariable StatUnit(StatUnitName, 0, "stat unit");
	ShowCollision.SetInt(1);
	ShowBounds.SetInt(1);
	StatFPS.SetInt(1);
	StatUnit.SetInt(1);
	return ShowCollision.GetInt() + ShowBounds.GetInt() + StatFPS.GetInt() + StatUnit.GetInt();
}

int ApplyScalabilitySettings(
	int Quality,
	const FString& ResolutionQualityName,
	const FString& ViewDistanceQualityName,
	const FString& AntiAliasingQualityName,
	const FString& ShadowQualityName,
	const FString& PostProcessQualityName,
	const FString& TextureQualityName,
	const FString& EffectsQualityName,
	const FString& FoliageQualityName)
{
	FConsoleVariable ResolutionQuality(ResolutionQualityName, 100, "resolution quality");
	FConsoleVariable ViewDistanceQuality(ViewDistanceQualityName, 3, "view distance quality");
	FConsoleVariable AntiAliasingQuality(AntiAliasingQualityName, 3, "anti aliasing quality");
	FConsoleVariable ShadowQuality(ShadowQualityName, 3, "shadow quality");
	FConsoleVariable PostProcessQuality(PostProcessQualityName, 3, "post process quality");
	FConsoleVariable TextureQuality(TextureQualityName, 3, "texture quality");
	FConsoleVariable EffectsQuality(EffectsQualityName, 3, "effects quality");
	FConsoleVariable FoliageQuality(FoliageQualityName, 3, "foliage quality");
	ResolutionQuality.SetInt(85);
	ViewDistanceQuality.SetInt(Quality);
	AntiAliasingQuality.SetInt(Quality);
	ShadowQuality.SetInt(Quality);
	PostProcessQuality.SetInt(Quality);
	TextureQuality.SetInt(Quality);
	EffectsQuality.SetInt(Quality);
	FoliageQuality.SetInt(Quality);
	return ResolutionQuality.GetInt()
		+ ViewDistanceQuality.GetInt()
		+ AntiAliasingQuality.GetInt()
		+ ShadowQuality.GetInt()
		+ PostProcessQuality.GetInt()
		+ TextureQuality.GetInt()
		+ EffectsQuality.GetInt()
		+ FoliageQuality.GetInt();
}

int ApplyHighQuality(
	const FString& ResolutionQualityName,
	const FString& ViewDistanceQualityName,
	const FString& AntiAliasingQualityName,
	const FString& ShadowQualityName,
	const FString& PostProcessQualityName,
	const FString& TextureQualityName,
	const FString& EffectsQualityName,
	const FString& FoliageQualityName)
{
	return ApplyScalabilitySettings(
		3,
		ResolutionQualityName,
		ViewDistanceQualityName,
		AntiAliasingQualityName,
		ShadowQualityName,
		PostProcessQualityName,
		TextureQualityName,
		EffectsQualityName,
		FoliageQualityName);
}

bool Observe_CommonCVar_ScaleAndQuality(
	const FString& ScreenPercentageName,
	const FString& ViewDistanceScaleName,
	const FString& VSyncName,
	const FString& ShadowQualityName,
	const FString& PostProcessQualityName,
	const FString& TextureQualityName,
	const FString& EffectsQualityName,
	const FString& FoliageQualityName)
{
	if (ScreenPercentageName.Len() == 0 || VSyncName.Len() == 0)
	{
		throw("TS-LANG-0083 setup: required CVar names are empty");
	}
	return Math::IsNearlyEqual(ApplyRenderScale(ScreenPercentageName, ViewDistanceScaleName), 76.25f, 0.001f)
		&& ApplyRenderQuality(VSyncName, ShadowQualityName, PostProcessQualityName, TextureQualityName, EffectsQualityName, FoliageQualityName) == 11;
}

bool Observe_CommonCVar_PerfAndDebug(
	const FString& MaxFPSName,
	const FString& ResolutionName,
	const FString& ShowCollisionName,
	const FString& ShowBoundsName,
	const FString& StatFPSName,
	const FString& StatUnitName)
{
	if (MaxFPSName.Len() == 0 || ShowCollisionName.Len() == 0)
	{
		throw("TS-LANG-0083 setup: required CVar names are empty");
	}
	return Math::IsNearlyEqual(ApplyPerformanceSettings(MaxFPSName, ResolutionName), 121.0f, 0.001f)
		&& ApplyDebugToggles(ShowCollisionName, ShowBoundsName, StatFPSName, StatUnitName) == 4;
}

bool Observe_CommonCVar_HighQualityNominal(
	const FString& ResolutionQualityName,
	const FString& ViewDistanceQualityName,
	const FString& AntiAliasingQualityName,
	const FString& ShadowQualityName,
	const FString& PostProcessQualityName,
	const FString& TextureQualityName,
	const FString& EffectsQualityName,
	const FString& FoliageQualityName)
{
	if (ResolutionQualityName.Len() == 0)
	{
		throw("TS-LANG-0083 setup: required scalability CVar names are empty");
	}
	return ApplyHighQuality(
		ResolutionQualityName,
		ViewDistanceQualityName,
		AntiAliasingQualityName,
		ShadowQualityName,
		PostProcessQualityName,
		TextureQualityName,
		EffectsQualityName,
		FoliageQualityName) == 106;
}

bool Observe_CommonCVar_ZeroQualityBoundary(
	const FString& ResolutionQualityName,
	const FString& ViewDistanceQualityName,
	const FString& AntiAliasingQualityName,
	const FString& ShadowQualityName,
	const FString& PostProcessQualityName,
	const FString& TextureQualityName,
	const FString& EffectsQualityName,
	const FString& FoliageQualityName)
{
	if (ResolutionQualityName.Len() == 0)
	{
		throw("TS-LANG-0083 setup: required scalability CVar names are empty");
	}
	return ApplyScalabilitySettings(
		0,
		ResolutionQualityName,
		ViewDistanceQualityName,
		AntiAliasingQualityName,
		ShadowQualityName,
		PostProcessQualityName,
		TextureQualityName,
		EffectsQualityName,
		FoliageQualityName) == 85;
}
