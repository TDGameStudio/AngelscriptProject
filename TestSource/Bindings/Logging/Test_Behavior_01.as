// Purpose: Observe default-category Log/Error/Warning families and their
// Condition-gated If variants. Each function returns that the message text
// is unchanged after the void call.
// AS-facing API: void Log(const FString& Text); void LogInfo(const FString& Text);
// void LogDisplay(const FString& Text); void Error(const FString& Text);
// void Warning(const FString& Text); void LogIf(bool Condition, const FString& Text);
// void LogInfoIf(bool Condition, const FString& Text);
// void LogDisplayIf(bool Condition, const FString& Text);
// void ErrorIf(bool Condition, const FString& Text);
// void WarningIf(bool Condition, const FString& Text);
// Inputs: Text "nominal", empty text, Condition true and false.
// Expected observations: Ungated calls always emit. If variants emit only when
// Condition is true; the false path is a silent no-op. Text is not mutated.
// Boundary/ownership: Messages are copied into the log system. Error/Warning
// do not throw; Throw lives in the later behavior file.

namespace TS_Logging_Behavior_01
{
	bool Observe_Log_Nominal()
	{
		FString Text = "nominal";
		FString Empty;
		Log(Text);
		Log(Empty);
		return Text == "nominal" && Empty.Len() == 0;
	}

	bool Observe_LogInfo_Nominal()
	{
		FString Text = "nominal";
		FString Empty;
		LogInfo(Text);
		LogInfo(Empty);
		return Text == "nominal" && Empty.Len() == 0;
	}

	bool Observe_LogDisplay_Nominal()
	{
		FString Text = "nominal";
		FString Empty;
		LogDisplay(Text);
		LogDisplay(Empty);
		return Text == "nominal" && Empty.Len() == 0;
	}

	bool Observe_Error_Nominal()
	{
		FString Text = "nominal";
		Error(Text);
		return Text == "nominal";
	}

	bool Observe_Warning_Nominal()
	{
		FString Text = "nominal";
		Warning(Text);
		return Text == "nominal";
	}

	bool Observe_LogIf_Nominal()
	{
		FString Emitted = "nominal";
		FString Suppressed = "suppressed";
		LogIf(true, Emitted);
		LogIf(false, Suppressed);
		return Emitted == "nominal" && Suppressed == "suppressed";
	}

	bool Observe_LogInfoIf_Nominal()
	{
		FString Emitted = "nominal";
		FString Suppressed = "suppressed";
		LogInfoIf(true, Emitted);
		LogInfoIf(false, Suppressed);
		return Emitted == "nominal" && Suppressed == "suppressed";
	}

	bool Observe_LogDisplayIf_Nominal()
	{
		FString Emitted = "nominal";
		FString Suppressed = "suppressed";
		LogDisplayIf(true, Emitted);
		LogDisplayIf(false, Suppressed);
		return Emitted == "nominal" && Suppressed == "suppressed";
	}

	bool Observe_ErrorIf_Nominal()
	{
		FString Emitted = "nominal";
		FString Suppressed = "suppressed";
		ErrorIf(true, Emitted);
		ErrorIf(false, Suppressed);
		return Emitted == "nominal" && Suppressed == "suppressed";
	}

	bool Observe_WarningIf_Nominal()
	{
		FString Emitted = "nominal";
		FString Suppressed = "suppressed";
		WarningIf(true, Emitted);
		WarningIf(false, Suppressed);
		return Emitted == "nominal" && Suppressed == "suppressed";
	}

	void ExerciseExpectedFailure()
	{
		Error("expected default-category error diagnostic");
	}
}
