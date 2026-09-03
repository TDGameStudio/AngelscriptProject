/**
 * Console variables registered under runner-supplied names across the value
 * kinds: float pairs, int pairs, a single float, a string, and an eight-name
 * scalability matrix. Each applier writes then reads back its variables.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.RegisteredCVarNameMatrix
 * @Harness Function
 * @Tag Language.Syntax.EdgeCases.RegisteredCVarNameMatrix
 * @Namespace SyntaxTest
 * @Provenance C++: AngelscriptCoverageCVarTests.cpp::RegisteredCVarNameMatrix
 * @Provenance sha256=caee1b7c929895cbd0c30c374c41f67ea48400a1ed4fea2c9b2b0dbd5685ddcf; lines 706-768.
 * @Provenance $ARGn$ become runner name parameters. Oracle: ApplyRenderScaleCVars==78.5,
 * @Provenance ApplyRenderQualityCVars==12, ApplyPerformanceCVar==144,
 * @Provenance ApplyResolutionStringCVar==1, ApplyScalabilityCVars==101.
 * @Provenance Extra: resolution mismatch returns 0. DefaultSafe.
 */

namespace SyntaxTest
{
	/**
	 * Writes and reads two float console variables.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs two CVar names
	 * @Return the sum of both written floats
	 * @Param ScreenPercentageName the screen percentage CVar name
	 * @Param ViewDistanceScaleName the view distance CVar name
	 */
	float ApplyRenderScaleCVars(const FString&in ScreenPercentageName, const FString&in ViewDistanceScaleName)
	{
		FConsoleVariable ScreenPercentage(ScreenPercentageName, 100.0f, "screen percentage");
		FConsoleVariable ViewDistanceScale(ViewDistanceScaleName, 1.0f, "view distance scale");
		ScreenPercentage.SetFloat(77.0f);
		ViewDistanceScale.SetFloat(1.5f);
		return ScreenPercentage.GetFloat() + ViewDistanceScale.GetFloat();
	}

	/**
	 * Writes and reads two int console variables.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs two CVar names
	 * @Return the encoded pair of written ints
	 * @Param VSyncName the vsync CVar name
	 * @Param ShadowQualityName the shadow quality CVar name
	 */
	int ApplyRenderQualityCVars(const FString&in VSyncName, const FString&in ShadowQualityName)
	{
		FConsoleVariable VSync(VSyncName, 0, "vsync");
		FConsoleVariable ShadowQuality(ShadowQualityName, 3, "shadow quality");
		VSync.SetInt(1);
		ShadowQuality.SetInt(2);
		return VSync.GetInt() * 10 + ShadowQuality.GetInt();
	}

	/**
	 * Writes and reads one float console variable.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs one CVar name
	 * @Return the written float
	 * @Param MaxFPSName the max fps CVar name
	 */
	float ApplyPerformanceCVar(const FString&in MaxFPSName)
	{
		FConsoleVariable MaxFPS(MaxFPSName, 0.0f, "max fps");
		MaxFPS.SetFloat(144.0f);
		return MaxFPS.GetFloat();
	}

	/**
	 * Writes and reads one string console variable.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs one CVar name
	 * @Return 1 when the written string reads back, otherwise 0
	 * @Param ResolutionName the resolution CVar name
	 */
	int ApplyResolutionStringCVar(const FString&in ResolutionName)
	{
		FConsoleVariable Resolution(ResolutionName, "1280x720w", "resolution command");
		Resolution.SetString("1920x1080w");
		return Resolution.GetString() == "1920x1080w" ? 1 : 0;
	}

	/**
	 * Writes and reads eight scalability console variables.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs eight CVar names
	 * @Return the sum of all eight written values
	 * @Param ResolutionQualityName the resolution quality CVar name
	 * @Param ViewDistanceQualityName the view distance quality CVar name
	 * @Param AntiAliasingQualityName the anti-aliasing quality CVar name
	 * @Param ShadowQualityName the shadow quality CVar name
	 * @Param PostProcessQualityName the post-process quality CVar name
	 * @Param TextureQualityName the texture quality CVar name
	 * @Param EffectsQualityName the effects quality CVar name
	 * @Param FoliageQualityName the foliage quality CVar name
	 */
	float ApplyScalabilityCVars(
		const FString&in ResolutionQualityName,
		const FString&in ViewDistanceQualityName,
		const FString&in AntiAliasingQualityName,
		const FString&in ShadowQualityName,
		const FString&in PostProcessQualityName,
		const FString&in TextureQualityName,
		const FString&in EffectsQualityName,
		const FString&in FoliageQualityName)
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

	/**
	 * Observe the float-pair application.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs two CVar names
	 * @Return true when the sum is 78.5
	 * @Param ScreenPercentageName the screen percentage CVar name
	 * @Param ViewDistanceScaleName the view distance CVar name
	 */
	UFUNCTION()
	bool RegisteredCVarMatrixScaleNominal(const FString&in ScreenPercentageName, const FString&in ViewDistanceScaleName)
	{
		if (ScreenPercentageName.Len() == 0 || ViewDistanceScaleName.Len() == 0)
		{
			throw("TS-LANG-0082 setup: required CVar names are empty");
		}
		return Math::IsNearlyEqual(ApplyRenderScaleCVars(ScreenPercentageName, ViewDistanceScaleName), 78.5f, 0.001f);
	}

	/**
	 * Observe the int-pair, single-float and string applications.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs four CVar names
	 * @Return true when all three applications match
	 * @Param VSyncName the vsync CVar name
	 * @Param ShadowQualityName the shadow quality CVar name
	 * @Param MaxFPSName the max fps CVar name
	 * @Param ResolutionName the resolution CVar name
	 */
	UFUNCTION()
	bool RegisteredCVarMatrixQualityAndPerf(
		const FString&in VSyncName,
		const FString&in ShadowQualityName,
		const FString&in MaxFPSName,
		const FString&in ResolutionName)
	{
		if (VSyncName.Len() == 0 || ShadowQualityName.Len() == 0 || MaxFPSName.Len() == 0 || ResolutionName.Len() == 0)
		{
			throw("TS-LANG-0082 setup: required CVar names are empty");
		}

		if (ApplyRenderQualityCVars(VSyncName, ShadowQualityName) != 12)
		{
			return false;
		}

		if (!Math::IsNearlyEqual(ApplyPerformanceCVar(MaxFPSName), 144.0f, 0.001f))
		{
			return false;
		}

		return ApplyResolutionStringCVar(ResolutionName) == 1;
	}

	/**
	 * Observe the eight-name scalability application.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs eight CVar names
	 * @Return true when the sum is 101
	 * @Param ResolutionQualityName the resolution quality CVar name
	 * @Param ViewDistanceQualityName the view distance quality CVar name
	 * @Param AntiAliasingQualityName the anti-aliasing quality CVar name
	 * @Param ShadowQualityName the shadow quality CVar name
	 * @Param PostProcessQualityName the post-process quality CVar name
	 * @Param TextureQualityName the texture quality CVar name
	 * @Param EffectsQualityName the effects quality CVar name
	 * @Param FoliageQualityName the foliage quality CVar name
	 */
	UFUNCTION()
	bool RegisteredCVarMatrixScalabilityNominal(
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

	/**
	 * Observe the resolution CVar's default before any write.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs one CVar name
	 * @Return true when the default string reads back
	 * @Boundary default value
	 * @Param ResolutionName the resolution CVar name
	 */
	UFUNCTION()
	bool RegisteredCVarMatrixResolutionDefaultBoundary(const FString&in ResolutionName)
	{
		if (ResolutionName.Len() == 0)
		{
			throw("TS-LANG-0082 setup: required ResolutionName is empty");
		}
		FConsoleVariable Resolution(ResolutionName, "1280x720w", "resolution command");
		return Resolution.GetString() == "1280x720w";
	}
}
