#pragma once

#include "CoreMinimal.h"
#include "Kismet/BlueprintFunctionLibrary.h"
#include "UObject/Object.h"

#include "AngelscriptUhtCoverageTestTypes.generated.h"

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptUhtCoverageTestObject : public UObject
{
	GENERATED_BODY()

public:
	UPROPERTY()
	int32 StoredValue = 42;
};

UCLASS()
class ANGELSCRIPTTEST_API UAngelscriptUhtCoverageTestLibrary : public UBlueprintFunctionLibrary
{
	GENERATED_BODY()

public:
	UFUNCTION(BlueprintCallable, meta = (BlueprintInternalUseOnly = "true", UsableInAngelscript = "true"))
	static int32 InternalCallableWithOverride(UAngelscriptUhtCoverageTestObject* Target);

	UFUNCTION(BlueprintCallable, meta = (BlueprintInternalUseOnly = "true"))
	static int32 InternalCallableWithoutOverride(UAngelscriptUhtCoverageTestObject* Target);

	UFUNCTION(BlueprintCallable, meta = (ScriptMethod, DisplayName = "Get Coverage Value"))
	static int32 GetCoverageValue(const UObject* Target);

	UFUNCTION(BlueprintCallable, meta = (WorldContext = "WorldContextObject"))
	static int32 RequiresWorldContext(UObject* WorldContextObject, int32 Value);

	UFUNCTION(BlueprintCallable, meta = (WorldContext = "WorldContextObject", CallableWithoutWorldContext))
	static int32 CallableWithoutWorldContext(UObject* WorldContextObject, int32 Value);

	UFUNCTION(BlueprintCallable, meta = (ScriptMethod, ScriptAllowTemporaryThis))
	static int32 GetTemporaryThisValue(const UObject* Target);

	UFUNCTION(BlueprintCallable, meta = (UnsafeDuringActorConstruction))
	static int32 UnsafeDuringConstruction(UObject* Target);

	UFUNCTION(BlueprintCallable, meta = (UnsafeDuringActorConstruction = "false"))
	static int32 SafeDuringConstruction(UObject* Target);
};
