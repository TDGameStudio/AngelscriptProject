/**
 * Common CVar usage patterns: writing render scales, quality levels,
 * performance settings, debug toggles and full scalability groups through
 * FConsoleVariable. Each helper takes the CVar names as parameters because the
 * runner supplies unique names per execution.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.CommonCVarUsagePatterns
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.CommonCVarUsagePatterns
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageCVarTests.cpp::CommonCVarUsagePatterns
 * @Provenance sha256=f483e04f00f68cb5b8de658ae1ef57104d5ed3717a2b868d70a4b9f03f9e61bf; lines 835-921.
 * @Provenance $ARGn$ become runner name parameters. Oracle: ApplyRenderScale==76.25,
 * @Provenance ApplyRenderQuality==11, ApplyPerformanceSettings==121, ApplyDebugToggles==4,
 * @Provenance ApplyHighQuality==106. Extra: ApplyScalabilitySettings(0)==85. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Writes two render-scale CVars and returns their sum.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the two CVar names
	 * @Return 76.25 after writing 75.0 and 1.25
	 * @Param ScreenPercentageName the screen percentage CVar name
	 * @Param ViewDistanceScaleName the view distance scale CVar name
	 */
	float ApplyRenderScale(const FString&in ScreenPercentageName, const FString&in ViewDistanceScaleName)
	{
		FConsoleVariable ScreenPercentage(ScreenPercentageName, 100.0f, "screen percentage");
		FConsoleVariable ViewDistanceScale(ViewDistanceScaleName, 1.0f, "view distance scale");
		ScreenPercentage.SetFloat(75.0f);
		ViewDistanceScale.SetFloat(1.25f);
		return ScreenPercentage.GetFloat() + ViewDistanceScale.GetFloat();
	}

	/**
	 * Writes six render-quality CVars and returns their sum.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the six CVar names
	 * @Return 11 after writing 1 and five 2s
	 * @Param VSyncName the vsync CVar name
	 * @Param ShadowQualityName the shadow quality CVar name
	 * @Param PostProcessQualityName the post process quality CVar name
	 * @Param TextureQualityName the texture quality CVar name
	 * @Param EffectsQualityName the effects quality CVar name
	 * @Param FoliageQualityName the foliage quality CVar name
	 */
	int ApplyRenderQuality(
		const FString&in VSyncName,
		const FString&in ShadowQualityName,
		const FString&in PostProcessQualityName,
		const FString&in TextureQualityName,
		const FString&in EffectsQualityName,
		const FString&in FoliageQualityName)
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

	/**
	 * Writes a float and a string CVar and returns their combined value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the two CVar names
	 * @Return 121 after writing 120.0 and the expected resolution string
	 * @Param MaxFPSName the max fps CVar name
	 * @Param ResolutionName the resolution CVar name
	 */
	float ApplyPerformanceSettings(const FString&in MaxFPSName, const FString&in ResolutionName)
	{
		FConsoleVariable MaxFPS(MaxFPSName, 0.0f, "max fps");
		FConsoleVariable Resolution(ResolutionName, "1280x720w", "resolution");
		MaxFPS.SetFloat(120.0f);
		Resolution.SetString("1920x1080w");
		return MaxFPS.GetFloat() + (Resolution.GetString() == "1920x1080w" ? 1.0f : 0.0f);
	}

	/**
	 * Writes four debug toggle CVars and returns their sum.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the four CVar names
	 * @Return 4 after enabling all four toggles
	 * @Param ShowCollisionName the show collision CVar name
	 * @Param ShowBoundsName the show bounds CVar name
	 * @Param StatFPSName the stat fps CVar name
	 * @Param StatUnitName the stat unit CVar name
	 */
	int ApplyDebugToggles(
		const FString&in ShowCollisionName,
		const FString&in ShowBoundsName,
		const FString&in StatFPSName,
		const FString&in StatUnitName)
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

	/**
	 * Writes a full scalability group, with resolution held at 85.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a quality level and the eight CVar names
	 * @Return 85 plus eight times the quality level
	 * @Param Quality the quality level written to all but resolution
	 * @Param ResolutionQualityName the resolution quality CVar name
	 * @Param ViewDistanceQualityName the view distance quality CVar name
	 * @Param AntiAliasingQualityName the anti aliasing quality CVar name
	 * @Param ShadowQualityName the shadow quality CVar name
	 * @Param PostProcessQualityName the post process quality CVar name
	 * @Param TextureQualityName the texture quality CVar name
	 * @Param EffectsQualityName the effects quality CVar name
	 * @Param FoliageQualityName the foliage quality CVar name
	 */
	int ApplyScalabilitySettings(
		int Quality,
		const FString&in ResolutionQualityName,
		const FString&in ViewDistanceQualityName,
		const FString&in AntiAliasingQualityName,
		const FString&in ShadowQualityName,
		const FString&in PostProcessQualityName,
		const FString&in TextureQualityName,
		const FString&in EffectsQualityName,
		const FString&in FoliageQualityName)
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

	/**
	 * Applies the scalability group at the highest quality level.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the eight CVar names
	 * @Return 106
	 * @Param ResolutionQualityName the resolution quality CVar name
	 * @Param ViewDistanceQualityName the view distance quality CVar name
	 * @Param AntiAliasingQualityName the anti aliasing quality CVar name
	 * @Param ShadowQualityName the shadow quality CVar name
	 * @Param PostProcessQualityName the post process quality CVar name
	 * @Param TextureQualityName the texture quality CVar name
	 * @Param EffectsQualityName the effects quality CVar name
	 * @Param FoliageQualityName the foliage quality CVar name
	 */
	int ApplyHighQuality(
		const FString&in ResolutionQualityName,
		const FString&in ViewDistanceQualityName,
		const FString&in AntiAliasingQualityName,
		const FString&in ShadowQualityName,
		const FString&in PostProcessQualityName,
		const FString&in TextureQualityName,
		const FString&in EffectsQualityName,
		const FString&in FoliageQualityName)
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

	/**
	 * Observe that the render scale and quality helpers match their values.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the render and quality CVar names
	 * @Return true when the scale is 76.25 and the quality sum is 11
	 * @Param ScreenPercentageName the screen percentage CVar name
	 * @Param ViewDistanceScaleName the view distance scale CVar name
	 * @Param VSyncName the vsync CVar name
	 * @Param ShadowQualityName the shadow quality CVar name
	 * @Param PostProcessQualityName the post process quality CVar name
	 * @Param TextureQualityName the texture quality CVar name
	 * @Param EffectsQualityName the effects quality CVar name
	 * @Param FoliageQualityName the foliage quality CVar name
	 */
	UFUNCTION()
	bool CommonCVarScaleAndQualityMatch(
		const FString&in ScreenPercentageName,
		const FString&in ViewDistanceScaleName,
		const FString&in VSyncName,
		const FString&in ShadowQualityName,
		const FString&in PostProcessQualityName,
		const FString&in TextureQualityName,
		const FString&in EffectsQualityName,
		const FString&in FoliageQualityName)
	{
		if (ScreenPercentageName.Len() == 0 || VSyncName.Len() == 0)
		{
			throw("TS-LANG-0083 setup: required CVar names are empty");
		}

		if (!Math::IsNearlyEqual(ApplyRenderScale(ScreenPercentageName, ViewDistanceScaleName), 76.25f, 0.001f))
		{
			return false;
		}

		return ApplyRenderQuality(VSyncName, ShadowQualityName, PostProcessQualityName, TextureQualityName, EffectsQualityName, FoliageQualityName) == 11;
	}

	/**
	 * Observe that the performance and debug helpers match their values.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the performance and debug CVar names
	 * @Return true when the performance sum is 121 and the toggle sum is 4
	 * @Param MaxFPSName the max fps CVar name
	 * @Param ResolutionName the resolution CVar name
	 * @Param ShowCollisionName the show collision CVar name
	 * @Param ShowBoundsName the show bounds CVar name
	 * @Param StatFPSName the stat fps CVar name
	 * @Param StatUnitName the stat unit CVar name
	 */
	UFUNCTION()
	bool CommonCVarPerfAndDebugMatch(
		const FString&in MaxFPSName,
		const FString&in ResolutionName,
		const FString&in ShowCollisionName,
		const FString&in ShowBoundsName,
		const FString&in StatFPSName,
		const FString&in StatUnitName)
	{
		if (MaxFPSName.Len() == 0 || ShowCollisionName.Len() == 0)
		{
			throw("TS-LANG-0083 setup: required CVar names are empty");
		}

		if (!Math::IsNearlyEqual(ApplyPerformanceSettings(MaxFPSName, ResolutionName), 121.0f, 0.001f))
		{
			return false;
		}

		return ApplyDebugToggles(ShowCollisionName, ShowBoundsName, StatFPSName, StatUnitName) == 4;
	}

	/**
	 * Observe that the high-quality preset sums to 106.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the eight scalability CVar names
	 * @Return true when the sum is 106
	 * @Param ResolutionQualityName the resolution quality CVar name
	 * @Param ViewDistanceQualityName the view distance quality CVar name
	 * @Param AntiAliasingQualityName the anti aliasing quality CVar name
	 * @Param ShadowQualityName the shadow quality CVar name
	 * @Param PostProcessQualityName the post process quality CVar name
	 * @Param TextureQualityName the texture quality CVar name
	 * @Param EffectsQualityName the effects quality CVar name
	 * @Param FoliageQualityName the foliage quality CVar name
	 */
	UFUNCTION()
	bool CommonCVarHighQualityMatches(
		const FString&in ResolutionQualityName,
		const FString&in ViewDistanceQualityName,
		const FString&in AntiAliasingQualityName,
		const FString&in ShadowQualityName,
		const FString&in PostProcessQualityName,
		const FString&in TextureQualityName,
		const FString&in EffectsQualityName,
		const FString&in FoliageQualityName)
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

	/**
	 * Observe the zero-quality boundary of the scalability group.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs the eight scalability CVar names
	 * @Return true when the sum is 85
	 * @Boundary zero quality
	 * @Param ResolutionQualityName the resolution quality CVar name
	 * @Param ViewDistanceQualityName the view distance quality CVar name
	 * @Param AntiAliasingQualityName the anti aliasing quality CVar name
	 * @Param ShadowQualityName the shadow quality CVar name
	 * @Param PostProcessQualityName the post process quality CVar name
	 * @Param TextureQualityName the texture quality CVar name
	 * @Param EffectsQualityName the effects quality CVar name
	 * @Param FoliageQualityName the foliage quality CVar name
	 */
	UFUNCTION()
	bool CommonCVarZeroQualityBoundary(
		const FString&in ResolutionQualityName,
		const FString&in ViewDistanceQualityName,
		const FString&in AntiAliasingQualityName,
		const FString&in ShadowQualityName,
		const FString&in PostProcessQualityName,
		const FString&in TextureQualityName,
		const FString&in EffectsQualityName,
		const FString&in FoliageQualityName)
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
}
