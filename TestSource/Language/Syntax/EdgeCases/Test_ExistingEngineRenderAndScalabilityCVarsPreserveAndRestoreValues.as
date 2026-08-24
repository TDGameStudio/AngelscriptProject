// Theme: Language.Syntax.EdgeCases. Positive existing render/scalability CVars.
// C++: AngelscriptCoverageCVarTests.cpp::ExistingEngineRenderAndScalabilityCVarsPreserveAndRestoreValues
// sha256=4ce210dfbf32d70e9f29a86923622146dd01fef66016af40b47afb8aeaa40209; lines 608-659.
// Oracle: ApplyExistingFloatCVars == 243.25; ApplyExistingIntCVars == 15.
// Extra: int path is independent of the float sum. DefaultSafe (mutates native
// engine CVars until the runner restores them).

float ApplyExistingFloatCVars()
{
	FConsoleVariable MaxFPS("t.MaxFPS", 0.0f, "max fps");
	FConsoleVariable ScreenPercentage("r.ScreenPercentage", 100.0f, "screen percentage");
	FConsoleVariable ViewDistanceScale("r.ViewDistanceScale", 1.0f, "view distance scale");
	FConsoleVariable ResolutionQuality("sg.ResolutionQuality", 100.0f, "resolution quality");
	FConsoleVariable RenderShadowQuality("r.ShadowQuality", 3, "render shadow quality");

	MaxFPS.SetFloat(90.0f);
	ScreenPercentage.SetFloat(80.0f);
	ViewDistanceScale.SetFloat(1.25f);
	ResolutionQuality.SetFloat(70.0f);
	RenderShadowQuality.SetInt(2);

	return MaxFPS.GetFloat()
		+ ScreenPercentage.GetFloat()
		+ ViewDistanceScale.GetFloat()
		+ ResolutionQuality.GetFloat()
		+ RenderShadowQuality.GetInt();
}

int ApplyExistingIntCVars()
{
	FConsoleVariable VSync("r.VSync", 0, "vsync");
	FConsoleVariable ViewDistanceQuality("sg.ViewDistanceQuality", 3, "view distance quality");
	FConsoleVariable AntiAliasingQuality("sg.AntiAliasingQuality", 3, "anti aliasing quality");
	FConsoleVariable ShadowQuality("sg.ShadowQuality", 3, "shadow quality");
	FConsoleVariable PostProcessQuality("sg.PostProcessQuality", 3, "post process quality");
	FConsoleVariable TextureQuality("sg.TextureQuality", 3, "texture quality");
	FConsoleVariable EffectsQuality("sg.EffectsQuality", 3, "effects quality");
	FConsoleVariable FoliageQuality("sg.FoliageQuality", 3, "foliage quality");

	VSync.SetInt(1);
	ViewDistanceQuality.SetInt(1);
	AntiAliasingQuality.SetInt(2);
	ShadowQuality.SetInt(3);
	PostProcessQuality.SetInt(2);
	TextureQuality.SetInt(1);
	EffectsQuality.SetInt(2);
	FoliageQuality.SetInt(3);

	return VSync.GetInt()
		+ ViewDistanceQuality.GetInt()
		+ AntiAliasingQuality.GetInt()
		+ ShadowQuality.GetInt()
		+ PostProcessQuality.GetInt()
		+ TextureQuality.GetInt()
		+ EffectsQuality.GetInt()
		+ FoliageQuality.GetInt();
}

bool Observe_ExistingRenderCVars_FloatNominal()
{
	return Math::IsNearlyEqual(ApplyExistingFloatCVars(), 243.25f, 0.001f);
}

bool Observe_ExistingRenderCVars_IntNominal()
{
	return ApplyExistingIntCVars() == 15;
}
