/**
 * @version v1
 * @summary Observe named-category Log/Error/Warning families and If variants.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe named-category Log/Error/Warning families and If variants.
 * @topic Baseline
 */
// Each function returns that CategoryName and Text are unchanged after the
// void call.
// AS-facing API: void Log(const FName& CategoryName, const FString& Text);
// void LogInfo(const FName& CategoryName, const FString& Text);
// void LogDisplay(const FName& CategoryName, const FString& Text);
// void Error(const FName& CategoryName, const FString& Text);
// void Warning(const FName& CategoryName, const FString& Text);
// void LogIf(bool Condition, const FName& CategoryName, const FString& Text);
// void LogInfoIf(bool Condition, const FName& CategoryName, const FString& Text);
// void LogDisplayIf(bool Condition, const FName& CategoryName, const FString& Text);
// void ErrorIf(bool Condition, const FName& CategoryName, const FString& Text);
// void WarningIf(bool Condition, const FName& CategoryName, const FString& Text);
// Inputs: Category n"LogAngelscript", NAME_None as the empty-name boundary,
// Text "nominal", and Condition true/false.
// Expected observations: Named-category calls return. False If variants do
// not emit. NAME_None is accepted as a category boundary.
// Boundary/ownership: CategoryName is a copied FName. The log system owns the
// emitted message after the call.

namespace TS_Logging_Behavior_02
{
	bool Observe_Log_Nominal()
	{
		FName Category = n"LogAngelscript";
		FString Text = "nominal";
		Log(Category, Text);
		Log(NAME_None, "");
		return Category == n"LogAngelscript" && Text == "nominal";
	}

	bool Observe_LogInfo_Nominal()
	{
		FName Category = n"LogAngelscript";
		FString Text = "nominal";
		LogInfo(Category, Text);
		return Category == n"LogAngelscript" && Text == "nominal";
	}

	bool Observe_LogDisplay_Nominal()
	{
		FName Category = n"LogAngelscript";
		FString Text = "nominal";
		LogDisplay(Category, Text);
		return Category == n"LogAngelscript" && Text == "nominal";
	}

	bool Observe_Error_Nominal()
	{
		FName Category = n"LogAngelscript";
		FString Text = "nominal";
		Error(Category, Text);
		return Category == n"LogAngelscript" && Text == "nominal";
	}

	bool Observe_Warning_Nominal()
	{
		FName Category = n"LogAngelscript";
		FString Text = "nominal";
		Warning(Category, Text);
		return Category == n"LogAngelscript" && Text == "nominal";
	}

	bool Observe_LogIf_Nominal()
	{
		FName Category = n"LogAngelscript";
		FString Emitted = "nominal";
		FString Suppressed = "suppressed";
		LogIf(true, Category, Emitted);
		LogIf(false, Category, Suppressed);
		return Category == n"LogAngelscript" && Emitted == "nominal" && Suppressed == "suppressed";
	}

	bool Observe_LogInfoIf_Nominal()
	{
		FName Category = n"LogAngelscript";
		FString Emitted = "nominal";
		FString Suppressed = "suppressed";
		LogInfoIf(true, Category, Emitted);
		LogInfoIf(false, Category, Suppressed);
		return Category == n"LogAngelscript" && Emitted == "nominal" && Suppressed == "suppressed";
	}

	bool Observe_LogDisplayIf_Nominal()
	{
		FName Category = n"LogAngelscript";
		FString Emitted = "nominal";
		FString Suppressed = "suppressed";
		LogDisplayIf(true, Category, Emitted);
		LogDisplayIf(false, Category, Suppressed);
		return Category == n"LogAngelscript" && Emitted == "nominal" && Suppressed == "suppressed";
	}

	bool Observe_ErrorIf_Nominal()
	{
		FName Category = n"LogAngelscript";
		FString Emitted = "nominal";
		FString Suppressed = "suppressed";
		ErrorIf(true, Category, Emitted);
		ErrorIf(false, Category, Suppressed);
		return Category == n"LogAngelscript" && Emitted == "nominal" && Suppressed == "suppressed";
	}

	bool Observe_WarningIf_Nominal()
	{
		FName Category = n"LogAngelscript";
		FString Emitted = "nominal";
		FString Suppressed = "suppressed";
		WarningIf(true, Category, Emitted);
		WarningIf(false, Category, Suppressed);
		return Category == n"LogAngelscript" && Emitted == "nominal" && Suppressed == "suppressed";
	}

	void ExerciseExpectedFailure()
	{
		Error(n"LogAngelscript", "expected named-category error diagnostic");
	}
}
/** @end */
