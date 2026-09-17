/**
 * @version v1
 * @summary Observe world/on-screen print helpers, including default-argument omission and null WorldContext. Each function returns that Text is unchanged after the void call.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe world/on-screen print helpers, including default-argument omission and null WorldContext. Each function returns that Text is unchanged after the void call.
 * @topic Baseline
 */
// void PrintFromObject(const UObject WorldContextObject, const FString& Text, float32 Duration = 0.f, FLinearColor Color = FLinearColor::LucBlue);
// void PrintToScreen(const FString& Text, float32 Duration = 0.f, FLinearColor Color = FLinearColor::LucBlue);
// void PrintDirectToScreen(const FString& Text, float32 Duration = 5.f, FLinearColor Color = FLinearColor::LucBlue);
// void DrawDebugStringFromObject(const UObject WorldContextObject, const FVector& TextLocation, const FString& Text, float32 Duration = 5.f, FLinearColor Color = FLinearColor::White);
// void PrintWarning(const FString& Text, float32 Duration = 8.f, FLinearColor Color = FLinearColor::Yellow);
// void PrintError(const FString& Text, float32 Duration = 8.f, FLinearColor Color = FLinearColor::Red);
// Inputs: Text "nominal", empty text, Duration 0 and default omission, colors
// LucBlue/White/Yellow/Red, a null WorldContextObject, and ZeroVector location.
// Expected observations: Each void call returns; empty text is still accepted.
// Null WorldContext is the diagnostic boundary for FromObject helpers.
// Boundary/ownership: These helpers do not retain Text. WorldContext is
// borrowed to resolve the world and is not owned by the print call.

namespace TS_Logging_NamespaceAndGlobalFunctions_01
{
	bool Observe_Print_Nominal()
	{
		FString Text = "nominal";
		FString Empty;
		Print(Text);
		Print(Text, 0.0);
		Print(Text, 5.0, FLinearColor::LucBlue);
		Print(Empty);
		return Text == "nominal" && Empty.Len() == 0;
	}

	bool Observe_PrintFromObject_Nominal()
	{
		UObject Context = nullptr;
		FString Text = "nominal";
		PrintFromObject(Context, Text);
		PrintFromObject(Context, Text, 0.0, FLinearColor::LucBlue);
		return Context is null && Text == "nominal";
	}

	bool Observe_PrintToScreen_Nominal()
	{
		FString Text = "nominal";
		FString Empty;
		PrintToScreen(Text);
		PrintToScreen(Text, 0.0, FLinearColor::LucBlue);
		PrintToScreen(Empty);
		return Text == "nominal" && Empty.Len() == 0;
	}

	bool Observe_PrintDirectToScreen_Nominal()
	{
		FString Text = "nominal";
		PrintDirectToScreen(Text);
		PrintDirectToScreen(Text, 5.0, FLinearColor::LucBlue);
		return Text == "nominal";
	}

	bool Observe_DrawDebugStringFromObject_Nominal()
	{
		UObject Context = nullptr;
		FVector Location = FVector::ZeroVector;
		FString Text = "nominal";
		DrawDebugStringFromObject(Context, Location, Text);
		DrawDebugStringFromObject(Context, Location, Text, 5.0, FLinearColor::White);
		return Context is null && Location.Equals(FVector::ZeroVector) && Text == "nominal";
	}

	bool Observe_PrintWarning_Nominal()
	{
		FString Text = "nominal";
		PrintWarning(Text);
		PrintWarning(Text, 8.0, FLinearColor::Yellow);
		return Text == "nominal";
	}

	bool Observe_PrintError_Nominal()
	{
		FString Text = "nominal";
		PrintError(Text);
		PrintError(Text, 8.0, FLinearColor::Red);
		return Text == "nominal";
	}

	void ExerciseExpectedFailure()
	{
		PrintError("expected print-error diagnostic");
	}
}
/** @end */
