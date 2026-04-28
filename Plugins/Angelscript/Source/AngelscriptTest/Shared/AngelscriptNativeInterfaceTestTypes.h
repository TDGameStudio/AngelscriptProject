#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "UObject/Interface.h"

#include "AngelscriptNativeInterfaceTestTypes.generated.h"

UINTERFACE(BlueprintType)
class ANGELSCRIPTTEST_API UAngelscriptNativeParentInterface : public UInterface
{
	GENERATED_BODY()
};

class ANGELSCRIPTTEST_API IAngelscriptNativeParentInterface
{
	GENERATED_BODY()

public:
	UFUNCTION(BlueprintCallable, BlueprintNativeEvent)
	int32 GetNativeValue() const;

	UFUNCTION(BlueprintCallable, BlueprintNativeEvent)
	void SetNativeMarker(FName Marker);

	UFUNCTION(BlueprintCallable, BlueprintNativeEvent)
	void AdjustNativeValue(int32 Delta, UPARAM(ref) int32& Value);
};

UINTERFACE(BlueprintType)
class ANGELSCRIPTTEST_API UAngelscriptNativeChildInterface : public UAngelscriptNativeParentInterface
{
	GENERATED_BODY()
};

class ANGELSCRIPTTEST_API IAngelscriptNativeChildInterface : public IAngelscriptNativeParentInterface
{
	GENERATED_BODY()

public:
	UFUNCTION(BlueprintCallable, BlueprintNativeEvent)
	int32 GetChildValue() const;
};

UCLASS()
class ANGELSCRIPTTEST_API ATestNativeParentInterfaceActor : public AActor, public IAngelscriptNativeParentInterface
{
	GENERATED_BODY()

public:
	ATestNativeParentInterfaceActor();

	UPROPERTY()
	int32 NativeValue = 123;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	int32 LastAdjustedValue = 0;

	UPROPERTY()
	int32 LastAdjustmentDelta = 0;

	virtual int32 GetNativeValue_Implementation() const override;
	virtual void SetNativeMarker_Implementation(FName Marker) override;
	virtual void AdjustNativeValue_Implementation(int32 Delta, int32& Value) override;
};

// Secondary interface used together with the parent interface on
// `ATestNativeMultiInterfaceActor` to exercise the non-zero `PointerOffset`
// branch of `UObject::GetInterfaceAddress`. The two interfaces together force
// the native implementing class to embed two distinct interface vtables at
// different offsets — the precise test case that `GetInterfacePointerForCast`
// is designed to handle correctly.
UINTERFACE(BlueprintType)
class ANGELSCRIPTTEST_API UAngelscriptNativeSecondaryInterface : public UInterface
{
	GENERATED_BODY()
};

class ANGELSCRIPTTEST_API IAngelscriptNativeSecondaryInterface
{
	GENERATED_BODY()

public:
	UFUNCTION(BlueprintCallable, BlueprintNativeEvent)
	int32 GetSecondaryValue() const;

	UFUNCTION(BlueprintCallable, BlueprintNativeEvent)
	void SetSecondaryLabel(const FString& NewLabel);
};

UCLASS()
class ANGELSCRIPTTEST_API ATestNativeMultiInterfaceActor : public AActor,
	public IAngelscriptNativeParentInterface,
	public IAngelscriptNativeSecondaryInterface
{
	GENERATED_BODY()

public:
	ATestNativeMultiInterfaceActor();

	// State for IAngelscriptNativeParentInterface
	UPROPERTY()
	int32 NativeValue = 777;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	int32 LastAdjustedValue = 0;

	UPROPERTY()
	int32 LastAdjustmentDelta = 0;

	// State for IAngelscriptNativeSecondaryInterface
	UPROPERTY()
	int32 SecondaryValue = 4242;

	UPROPERTY()
	FString SecondaryLabel;

	virtual int32 GetNativeValue_Implementation() const override;
	virtual void SetNativeMarker_Implementation(FName Marker) override;
	virtual void AdjustNativeValue_Implementation(int32 Delta, int32& Value) override;

	virtual int32 GetSecondaryValue_Implementation() const override;
	virtual void SetSecondaryLabel_Implementation(const FString& NewLabel) override;
};
