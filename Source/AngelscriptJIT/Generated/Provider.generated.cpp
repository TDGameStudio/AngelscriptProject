// @angelscript-jit-scaffold revision=2 kind=provider-selector-source
#include "Provider.generated.h"

#if WITH_EDITOR && UE_BUILD_DEVELOPMENT && __has_include("EditorDevelopment/Provider.generated.inl")
#include "EditorDevelopment/Provider.generated.inl"
#define ANGELSCRIPT_JIT_HAS_SELECTED_PROVIDER 1
#elif !WITH_EDITOR && UE_BUILD_SHIPPING && __has_include("GameShipping/Provider.generated.inl")
#include "GameShipping/Provider.generated.inl"
#define ANGELSCRIPT_JIT_HAS_SELECTED_PROVIDER 1
#elif !WITH_EDITOR && UE_BUILD_DEVELOPMENT && __has_include("GameDevelopment/Provider.generated.inl")
#include "GameDevelopment/Provider.generated.inl"
#define ANGELSCRIPT_JIT_HAS_SELECTED_PROVIDER 1
#else
#define ANGELSCRIPT_JIT_HAS_SELECTED_PROVIDER 0
#endif

const FAngelscriptJITProviderView*
GetCurrentGeneratedAngelscriptJITProviderView()
{
#if ANGELSCRIPT_JIT_HAS_SELECTED_PROVIDER
	static thread_local FAngelscriptJITProviderView View;
	View = GetGeneratedAngelscriptJITProviderView();
	return &View;
#else
	return nullptr;
#endif
}
