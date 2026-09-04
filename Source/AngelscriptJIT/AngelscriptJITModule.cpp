// @angelscript-jit-scaffold revision=2 kind=module-source
#include "Core/AngelscriptRuntimeModule.h"
#include "Modules/ModuleManager.h"
#include "StaticJIT/AngelscriptJITProvider.h"

#include "Generated/Provider.generated.h"

class FAngelscriptJITModule final
	: public IModuleInterface
	, public IAngelscriptJITArtifactProvider
{
public:
	virtual void StartupModule() override
	{
		if (!FAngelscriptRuntimeModule::IsLegacyRuntimeEnabled())
		{
			return;
		}

		IModularFeatures::Get().RegisterModularFeature(
			IAngelscriptJITArtifactProvider::FeatureName(), this);
		bRegistered = true;
	}

	virtual void ShutdownModule() override
	{
		if (bRegistered)
		{
			IModularFeatures::Get().UnregisterModularFeature(
				IAngelscriptJITArtifactProvider::FeatureName(), this);
			bRegistered = false;
		}
	}

	virtual const FAngelscriptJITProviderView*
	GetAngelscriptJITProviderView() const override
	{
		return GetCurrentGeneratedAngelscriptJITProviderView();
	}

	virtual bool SupportsDynamicReloading() override
	{
		return false;
	}

private:
	bool bRegistered = false;
};

IMPLEMENT_MODULE(FAngelscriptJITModule, AngelscriptJIT)
