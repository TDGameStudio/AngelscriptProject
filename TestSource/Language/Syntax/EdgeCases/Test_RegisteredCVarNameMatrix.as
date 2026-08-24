// Theme: Language.Syntax.EdgeCases. Positive registered CVar name matrix.
// C++: AngelscriptCoverageCVarTests.cpp::RegisteredCVarNameMatrix
// sha256=caee1b7c929895cbd0c30c374c41f67ea48400a1ed4fea2c9b2b0dbd5685ddcf; lines 706-768.
// $ARGn$ become runner name parameters. Oracle: ApplyRenderScaleCVars==78.5,
// ApplyRenderQualityCVars==12, ApplyPerformanceCVar==144,
// ApplyResolutionStringCVar==1, ApplyScalabilityCVars==101.
// Extra: resolution mismatch returns 0. DefaultSafe.

float ApplyRenderScaleCVars(const FString& ScreenPercentageName, const FString& ViewDistanceScaleName)
{
	FConsoleVariable ScreenPercentage(ScreenPercentageName, 100.0f, "screen percentage");
	FConsoleVariable ViewDistanceScale(ViewDistanceScaleName, 1.0f, "view distance scale");
	ScreenPercentage.SetFloat(77.0f);
	ViewDistanceScale.SetFloat(1.5f);
	return ScreenPercentage.GetFloat() + ViewDistanceScale.GetFloat();
}

int ApplyRenderQualityCVars(const FString& VSyncName, const FString& ShadowQualityName)
{
	FConsoleVariable VSync(VSyncName, 0, "vsync");
	FConsoleVariable ShadowQuality(ShadowQualityName, 3, "shadow quality");
	VSync.SetInt(1);
	ShadowQuality.SetInt(2);
	return VSync.GetInt() * 10 + ShadowQuality.GetInt();
}

float ApplyPerformanceCVar(const FString& MaxFPSName)
{
	FConsoleVariable MaxFPS(MaxFPSName, 0.0f, "max fps");
	MaxFPS.SetFloat(144.0f);
	return MaxFPS.GetFloat();
}

int ApplyResolutionStringCVar(const FString& ResolutionName)
{
	FConsoleVariable Resolution(ResolutionName, "1280x720w", "resolution command");
	Resolution.SetString("1920x1080w");
	return Resolution.GetString() == "1920x1080w" ? 1 : 0;
}

float ApplyScalabilityCVars(
	const FString& ResolutionQualityName,
	const FString& ViewDistanceQualityName,
	const FString& AntiAliasingQualityName,
	const FString& ShadowQualityName,
	const FString& PostProcessQualityName,
	const FString& TextureQualityName,
	const FString& EffectsQualityName,
	const FString& FoliageQualityName)
{
	FConsoleVariable ResolutionQuality(ResolutionQualityName, 100.0f, "resolution quality");
	FConsoleVariable ViewDistanceQuality(ViewDistanceQualityName, 3, "view distance quality");
	FConsoleVariable AntiAliasingQuality(AntiAliasingQualityName, 3, "anti aliasing quality");
	FConsoleVariable ShadowQuality(ShadowQualityName, 3, "shadow quality");
	FConsoleVariable PostProcessQuality(PostProcessQualityName, 3, "post process quality");
	FConsoleVariable TextureQuality(TextureQualityName, 3, "texture quality");
	FConsoleVariable EffectsQuality(EffectsQualityName, 3, "effects quality");
	FConsoleVariable FoliageQuality(FoliageQualityName, 3, "foliage quality");

	ResolutionQuality.SetFloat(85.0f);
	ViewDistanceQuality.SetInt(1);
	AntiAliasingQuality.SetInt(2);
	ShadowQuality.SetInt(3);
	PostProcessQuality.SetInt(4);
	TextureQuality.SetInt(1);
	EffectsQuality.SetInt(2);
	FoliageQuality.SetInt(3);

	return ResolutionQuality.GetFloat()
		+ ViewDistanceQuality.GetInt()
		+ AntiAliasingQuality.GetInt()
		+ ShadowQuality.GetInt()
		+ PostProcessQuality.GetInt()
		+ TextureQuality.GetInt()
		+ EffectsQuality.GetInt()
		+ FoliageQuality.GetInt();
}

bool Observe_RegisteredCVarMatrix_ScaleNominal(const FString& ScreenPercentageName, const FString& ViewDistanceScaleName)
{
	if (ScreenPercentageName.Len() == 0 || ViewDistanceScaleName.Len() == 0)
	{
		throw("TS-LANG-0082 setup: required CVar names are empty");
	}
	return Math::IsNearlyEqual(ApplyRenderScaleCVars(ScreenPercentageName, ViewDistanceScaleName), 78.5f, 0.001f);
}

bool Observe_RegisteredCVarMatrix_QualityAndPerf(
	const FString& VSyncName,
	const FString& ShadowQualityName,
	const FString& MaxFPSName,
	const FString& ResolutionName)
{
	if (VSyncName.Len() == 0 || ShadowQualityName.Len() == 0 || MaxFPSName.Len() == 0 || ResolutionName.Len() == 0)
	{
		throw("TS-LANG-0082 setup: required CVar names are empty");
	}
	return ApplyRenderQualityCVars(VSyncName, ShadowQualityName) == 12
		&& Math::IsNearlyEqual(ApplyPerformanceCVar(MaxFPSName), 144.0f, 0.001f)
		&& ApplyResolutionStringCVar(ResolutionName) == 1;
}

bool Observe_RegisteredCVarMatrix_ScalabilityNominal(
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
		throw("TS-LANG-0082 setup: required scalability CVar names are empty");
	}
	return Math::IsNearlyEqual(
		ApplyScalabilityCVars(
			ResolutionQualityName,
			ViewDistanceQualityName,
			AntiAliasingQualityName,
			ShadowQualityName,
			PostProcessQualityName,
			TextureQualityName,
			EffectsQualityName,
			FoliageQualityName),
		101.0f,
		0.001f);
}

bool Observe_RegisteredCVarMatrix_ResolutionDefaultBoundary(const FString& ResolutionName)
{
	if (ResolutionName.Len() == 0)
	{
		throw("TS-LANG-0082 setup: required ResolutionName is empty");
	}
	FConsoleVariable Resolution(ResolutionName, "1280x720w", "resolution command");
	return Resolution.GetString() == "1280x720w";
}
