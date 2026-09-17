/**
 * @version v1
 * @summary Logging host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic Logging
 *
 * log-info
 * log-display
 * error
 * warning
 * log-if
 * log-info-if
 * log-display-if
 * error-if
 * warning-if
 * Logging-Behavior_02-log-info
 * Logging-Behavior_02-log-display
 * Logging-Behavior_02-error
 * Logging-Behavior_02-warning
 * Logging-Behavior_02-log-if
 * Logging-Behavior_02-log-info-if
 * Logging-Behavior_02-log-display-if
 * Logging-Behavior_02-error-if
 * Logging-Behavior_02-warning-if
 * throw
 * throw-if
 * print-from-object
 * print-to-screen
 * print-direct-to-screen
 * draw-debug-string-from-object
 * print-warning
 * print-error
 */
/**
 * @begin log-info
 * @summary do not throw.
 * @topic Unreal
 */
/**
 * @function ObserveLogInfoNominal
 * @summary do not throw.
 * @covers Logging.log-info
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLogInfoNominal()
{
	FString Text = "nominal";
	FString Empty;
	LogInfo(Text);
	LogInfo(Empty);
	return Text == "nominal" && Empty.Len() == 0;
}
/** @end */
/**
 * @begin log-display
 * @summary do not throw.
 * @topic Unreal
 */
/**
 * @function ObserveLogDisplayNominal
 * @summary do not throw.
 * @covers Logging.log-display
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLogDisplayNominal()
{
	FString Text = "nominal";
	FString Empty;
	LogDisplay(Text);
	LogDisplay(Empty);
	return Text == "nominal" && Empty.Len() == 0;
}
/** @end */
/**
 * @begin error
 * @summary do not throw.
 * @topic Unreal
 */
/**
 * @function ObserveErrorNominal
 * @summary do not throw.
 * @covers Logging.error
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveErrorNominal()
{
	FString Text = "nominal";
	Error(Text);
	return Text == "nominal";
}
/** @end */
/**
 * @begin warning
 * @summary do not throw.
 * @topic Unreal
 */
/**
 * @function ObserveWarningNominal
 * @summary do not throw.
 * @covers Logging.warning
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveWarningNominal()
{
	FString Text = "nominal";
	Warning(Text);
	return Text == "nominal";
}
/** @end */
/**
 * @begin log-if
 * @summary do not throw.
 * @topic Unreal
 */
/**
 * @function ObserveLogIfNominal
 * @summary do not throw.
 * @covers Logging.log-if
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLogIfNominal()
{
	FString Emitted = "nominal";
	FString Suppressed = "suppressed";
	LogIf(true, Emitted);
	LogIf(false, Suppressed);
	return Emitted == "nominal" && Suppressed == "suppressed";
}
/** @end */
/**
 * @begin log-info-if
 * @summary do not throw.
 * @topic Unreal
 */
/**
 * @function ObserveLogInfoIfNominal
 * @summary do not throw.
 * @covers Logging.log-info-if
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLogInfoIfNominal()
{
	FString Emitted = "nominal";
	FString Suppressed = "suppressed";
	LogInfoIf(true, Emitted);
	LogInfoIf(false, Suppressed);
	return Emitted == "nominal" && Suppressed == "suppressed";
}
/** @end */
/**
 * @begin log-display-if
 * @summary do not throw.
 * @topic Unreal
 */
/**
 * @function ObserveLogDisplayIfNominal
 * @summary do not throw.
 * @covers Logging.log-display-if
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveLogDisplayIfNominal()
{
	FString Emitted = "nominal";
	FString Suppressed = "suppressed";
	LogDisplayIf(true, Emitted);
	LogDisplayIf(false, Suppressed);
	return Emitted == "nominal" && Suppressed == "suppressed";
}
/** @end */
/**
 * @begin error-if
 * @summary do not throw.
 * @topic Unreal
 */
/**
 * @function ObserveErrorIfNominal
 * @summary do not throw.
 * @covers Logging.error-if
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveErrorIfNominal()
{
	FString Emitted = "nominal";
	FString Suppressed = "suppressed";
	ErrorIf(true, Emitted);
	ErrorIf(false, Suppressed);
	return Emitted == "nominal" && Suppressed == "suppressed";
}
/** @end */
/**
 * @begin warning-if
 * @summary do not throw.
 * @topic Unreal
 */
/**
 * @function ObserveWarningIfNominal
 * @summary do not throw.
 * @covers Logging.warning-if
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveWarningIfNominal()
{
	FString Emitted = "nominal";
	FString Suppressed = "suppressed";
	WarningIf(true, Emitted);
	WarningIf(false, Suppressed);
	return Emitted == "nominal" && Suppressed == "suppressed";
}
/** @end */
/**
 * @begin Logging-Behavior_02-log-info
 * @summary emitted message after the call.
 * @topic Unreal
 */
/**
 * @function ObserveLogInfoNominal
 * @summary emitted message after the call.
 * @covers Logging.log-info
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveLogInfoNominal()
{
	FName Category = n"LogAngelscript";
	FString Text = "nominal";
	LogInfo(Category, Text);
	return Category == n"LogAngelscript" && Text == "nominal";
}
/** @end */
/**
 * @begin Logging-Behavior_02-log-display
 * @summary emitted message after the call.
 * @topic Unreal
 */
/**
 * @function ObserveLogDisplayNominal
 * @summary emitted message after the call.
 * @covers Logging.log-display
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveLogDisplayNominal()
{
	FName Category = n"LogAngelscript";
	FString Text = "nominal";
	LogDisplay(Category, Text);
	return Category == n"LogAngelscript" && Text == "nominal";
}
/** @end */
/**
 * @begin Logging-Behavior_02-error
 * @summary emitted message after the call.
 * @topic Unreal
 */
/**
 * @function ObserveErrorNominal
 * @summary emitted message after the call.
 * @covers Logging.error
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveErrorNominal()
{
	FName Category = n"LogAngelscript";
	FString Text = "nominal";
	Error(Category, Text);
	return Category == n"LogAngelscript" && Text == "nominal";
}
/** @end */
/**
 * @begin Logging-Behavior_02-warning
 * @summary emitted message after the call.
 * @topic Unreal
 */
/**
 * @function ObserveWarningNominal
 * @summary emitted message after the call.
 * @covers Logging.warning
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveWarningNominal()
{
	FName Category = n"LogAngelscript";
	FString Text = "nominal";
	Warning(Category, Text);
	return Category == n"LogAngelscript" && Text == "nominal";
}
/** @end */
/**
 * @begin Logging-Behavior_02-log-if
 * @summary emitted message after the call.
 * @topic Unreal
 */
/**
 * @function ObserveLogIfNominal
 * @summary emitted message after the call.
 * @covers Logging.log-if
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveLogIfNominal()
{
	FName Category = n"LogAngelscript";
	FString Emitted = "nominal";
	FString Suppressed = "suppressed";
	LogIf(true, Category, Emitted);
	LogIf(false, Category, Suppressed);
	return Category == n"LogAngelscript" && Emitted == "nominal" && Suppressed == "suppressed";
}
/** @end */
/**
 * @begin Logging-Behavior_02-log-info-if
 * @summary emitted message after the call.
 * @topic Unreal
 */
/**
 * @function ObserveLogInfoIfNominal
 * @summary emitted message after the call.
 * @covers Logging.log-info-if
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveLogInfoIfNominal()
{
	FName Category = n"LogAngelscript";
	FString Emitted = "nominal";
	FString Suppressed = "suppressed";
	LogInfoIf(true, Category, Emitted);
	LogInfoIf(false, Category, Suppressed);
	return Category == n"LogAngelscript" && Emitted == "nominal" && Suppressed == "suppressed";
}
/** @end */
/**
 * @begin Logging-Behavior_02-log-display-if
 * @summary emitted message after the call.
 * @topic Unreal
 */
/**
 * @function ObserveLogDisplayIfNominal
 * @summary emitted message after the call.
 * @covers Logging.log-display-if
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveLogDisplayIfNominal()
{
	FName Category = n"LogAngelscript";
	FString Emitted = "nominal";
	FString Suppressed = "suppressed";
	LogDisplayIf(true, Category, Emitted);
	LogDisplayIf(false, Category, Suppressed);
	return Category == n"LogAngelscript" && Emitted == "nominal" && Suppressed == "suppressed";
}
/** @end */
/**
 * @begin Logging-Behavior_02-error-if
 * @summary emitted message after the call.
 * @topic Unreal
 */
/**
 * @function ObserveErrorIfNominal
 * @summary emitted message after the call.
 * @covers Logging.error-if
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveErrorIfNominal()
{
	FName Category = n"LogAngelscript";
	FString Emitted = "nominal";
	FString Suppressed = "suppressed";
	ErrorIf(true, Category, Emitted);
	ErrorIf(false, Category, Suppressed);
	return Category == n"LogAngelscript" && Emitted == "nominal" && Suppressed == "suppressed";
}
/** @end */
/**
 * @begin Logging-Behavior_02-warning-if
 * @summary emitted message after the call.
 * @topic Unreal
 */
/**
 * @function ObserveWarningIfNominal
 * @summary emitted message after the call.
 * @covers Logging.warning-if
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
// AS-facing API:

bool ObserveWarningIfNominal()
{
	FName Category = n"LogAngelscript";
	FString Emitted = "nominal";
	FString Suppressed = "suppressed";
	WarningIf(true, Category, Emitted);
	WarningIf(false, Category, Suppressed);
	return Category == n"LogAngelscript" && Emitted == "nominal" && Suppressed == "suppressed";
}
/** @end */
/**
 * @begin throw
 * @summary script does not continue after a successful Throw.
 * @topic Unreal
 */
/**
 * @function ObserveThrowNominal
 * @summary script does not continue after a successful Throw.
 * @covers Logging.throw
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveThrowNominal()
{
	FString Prepared = "expected logging throw";
	return Prepared == "expected logging throw" && Prepared.Len() > 0;
}
/** @end */
/**
 * @begin throw-if
 * @summary script does not continue after a successful Throw.
 * @topic Unreal
 */
/**
 * @function ObserveThrowIfNominal
 * @summary script does not continue after a successful Throw.
 * @covers Logging.throw-if
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveThrowIfNominal()
{
	FString Suppressed = "suppressed throw";
	ThrowIf(false, Suppressed);
	ThrowIf(false, "");
	return Suppressed == "suppressed throw";
}
/** @end */
/**
 * @begin print-from-object
 * @summary borrowed to resolve the world and is not owned by the print call.
 * @topic Unreal
 */
/**
 * @function ObservePrintFromObjectNominal
 * @summary borrowed to resolve the world and is not owned by the print call.
 * @covers Logging.print-from-object
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObservePrintFromObjectNominal()
{
	UObject Context = nullptr;
	FString Text = "nominal";
	PrintFromObject(Context, Text);
	PrintFromObject(Context, Text, 0.0, FLinearColor::LucBlue);
	return Context is null && Text == "nominal";
}
/** @end */
/**
 * @begin print-to-screen
 * @summary borrowed to resolve the world and is not owned by the print call.
 * @topic Unreal
 */
/**
 * @function ObservePrintToScreenNominal
 * @summary borrowed to resolve the world and is not owned by the print call.
 * @covers Logging.print-to-screen
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObservePrintToScreenNominal()
{
	FString Text = "nominal";
	FString Empty;
	PrintToScreen(Text);
	PrintToScreen(Text, 0.0, FLinearColor::LucBlue);
	PrintToScreen(Empty);
	return Text == "nominal" && Empty.Len() == 0;
}
/** @end */
/**
 * @begin print-direct-to-screen
 * @summary borrowed to resolve the world and is not owned by the print call.
 * @topic Unreal
 */
/**
 * @function ObservePrintDirectToScreenNominal
 * @summary borrowed to resolve the world and is not owned by the print call.
 * @covers Logging.print-direct-to-screen
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObservePrintDirectToScreenNominal()
{
	FString Text = "nominal";
	PrintDirectToScreen(Text);
	PrintDirectToScreen(Text, 5.0, FLinearColor::LucBlue);
	return Text == "nominal";
}
/** @end */
/**
 * @begin draw-debug-string-from-object
 * @summary borrowed to resolve the world and is not owned by the print call.
 * @topic Unreal
 */
/**
 * @function ObserveDrawDebugStringFromObjectNominal
 * @summary borrowed to resolve the world and is not owned by the print call.
 * @covers Logging.draw-debug-string-from-object
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveDrawDebugStringFromObjectNominal()
{
	UObject Context = nullptr;
	FVector Location = FVector::ZeroVector;
	FString Text = "nominal";
	DrawDebugStringFromObject(Context, Location, Text);
	DrawDebugStringFromObject(Context, Location, Text, 5.0, FLinearColor::White);
	return Context is null && Location.Equals(FVector::ZeroVector) && Text == "nominal";
}
/** @end */
/**
 * @begin print-warning
 * @summary borrowed to resolve the world and is not owned by the print call.
 * @topic Unreal
 */
/**
 * @function ObservePrintWarningNominal
 * @summary borrowed to resolve the world and is not owned by the print call.
 * @covers Logging.print-warning
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObservePrintWarningNominal()
{
	FString Text = "nominal";
	PrintWarning(Text);
	PrintWarning(Text, 8.0, FLinearColor::Yellow);
	return Text == "nominal";
}
/** @end */
/**
 * @begin print-error
 * @summary borrowed to resolve the world and is not owned by the print call.
 * @topic Unreal
 */
/**
 * @function ObservePrintErrorNominal
 * @summary borrowed to resolve the world and is not owned by the print call.
 * @covers Logging.print-error
 * @inputs Logging values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObservePrintErrorNominal()
{
	FString Text = "nominal";
	PrintError(Text);
	PrintError(Text, 8.0, FLinearColor::Red);
	return Text == "nominal";
}
/** @end */
