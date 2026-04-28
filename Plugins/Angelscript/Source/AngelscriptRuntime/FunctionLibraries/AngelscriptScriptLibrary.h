#pragma once
#include "MatrixTypes.h"
#include "AngelscriptEngine.h"
#include "AngelscriptScriptLibrary.generated.h"

UCLASS(Meta = (ScriptName = "Script"))
class UAngelscriptScriptLibrary : public UObject
{
	GENERATED_BODY()

public:

	/**
	 * If we are currently initializing a script global variable, return its name.
	 * Returns an empty string if no global variable is currently being initialized.
	 */
	UFUNCTION(BlueprintCallable, Meta = (NotAngelscriptProperty))
	static FString GetNameOfGlobalVariableBeingInitialized();

	/**
	 * If we are currently initializing a script global variable, return the namespace it is in.
	 * Returns an empty string if no global variable is currently being initialized.
	 */
	UFUNCTION(BlueprintCallable, Meta = (NotAngelscriptProperty))
	static FString GetNamespaceOfGlobalVariableBeingInitialized();

	/**
	 * If we are currently initializing a script global variable, return the name of the module it is in.
	 * Returns an empty string if no global variable is currently being initialized.
	 */
	UFUNCTION(BlueprintCallable, Meta = (NotAngelscriptProperty))
	static FString GetModuleNameOfGlobalVariableBeingInitialized();
};
