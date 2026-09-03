/**
 * Writing through FConsoleVariable handles bound to existing render and
 * scalability CVars. Each helper writes a set of native variables and sums the
 * values read back.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.ExistingEngineRenderAndScalabilityCVarsPreserveAndRestoreValues
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.ExistingEngineRenderAndScalabilityCVarsPreserveAndRestoreValues
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageCVarTests.cpp::ExistingEngineRenderAndScalabilityCVarsPreserveAndRestoreValues
 * @Provenance sha256=4ce210dfbf32d70e9f29a86923622146dd01fef66016af40b47afb8aeaa40209; lines 608-659.
 * @Provenance Oracle: ApplyExistingFloatCVars == 243.25; ApplyExistingIntCVars == 15.
 * @Provenance Extra: int path is independent of the float sum. DefaultSafe (mutates native
 * @Provenance engine CVars until the runner restores them).
 */

namespace SyntaxTest
{
	/**
	 * Writes five render CVars and sums the values read back.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the existing render CVars
	 * @Return the sum of the written values
	 */
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

		float Total = MaxFPS.GetFloat();
		Total += ScreenPercentage.GetFloat();
		Total += ViewDistanceScale.GetFloat();
		Total += ResolutionQuality.GetFloat();
		Total += RenderShadowQuality.GetInt();
		return Total;
	}

	/**
	 * Writes eight scalability CVars and sums the values read back.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the existing scalability CVars
	 * @Return the sum of the written values
	 */
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

		int Total = VSync.GetInt();
		Total += ViewDistanceQuality.GetInt();
		Total += AntiAliasingQuality.GetInt();
		Total += ShadowQuality.GetInt();
		Total += PostProcessQuality.GetInt();
		Total += TextureQuality.GetInt();
		Total += EffectsQuality.GetInt();
		Total += FoliageQuality.GetInt();
		return Total;
	}

	/**
	 * Observe that the five float writes sum to the expected total.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs ApplyExistingFloatCVars()
	 * @Return true when the sum is 243.25
	 */
	UFUNCTION()
	bool ExistingRenderCVarsFloatNominal()
	{
		return Math::IsNearlyEqual(ApplyExistingFloatCVars(), 243.25f, 0.001f);
	}

	/**
	 * Observe that the eight int writes sum to the expected total.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs ApplyExistingIntCVars()
	 * @Return true when the sum is 15
	 */
	UFUNCTION()
	bool ExistingRenderCVarsIntNominal()
	{
		return ApplyExistingIntCVars() == 15;
	}
}
