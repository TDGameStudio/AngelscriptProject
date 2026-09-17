/**
 * @version v1
 * @summary Observe mobility/init-type enumerators and the engine default query/response/object-parameter constants.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe mobility/init-type enumerators and the engine default query/response/object-parameter constants.
 * @topic Baseline
 */
// EQueryMobilityType::Dynamic; ECollisionObjectQueryInitType::AllObjects;
// ECollisionObjectQueryInitType::AllStaticObjects;
// ECollisionObjectQueryInitType::AllDynamicObjects;
// const FCollisionQueryParams FCollisionQueryParams::DefaultQueryParam;
// const FComponentQueryParams FComponentQueryParams::DefaultComponentQueryParams;
// const FCollisionResponseParams FCollisionResponseParams::DefaultResponseParam;
// const FCollisionObjectQueryParams FCollisionObjectQueryParams::DefaultObjectQueryParam;
// Inputs: Each enumerator and each Default* constant compared with a local
// default-constructed object.
// Expected observations: Any != Static != Dynamic. AllObjects !=
// AllStaticObjects != AllDynamicObjects. DefaultQueryParam is usable.
// DefaultObjectQueryParam.IsValid is the engine default validity.
// Boundary/ownership: These are shared engine/bind constants.

namespace TS_FCollisionQueryParams_NamespaceAndGlobalFunctions_01
{
	// EQueryMobilityType::Any is distinct from Static. Shared enumerator, no fixture.
	bool Observe_Surface002_Nominal()
	{
		EQueryMobilityType Any = EQueryMobilityType::Any;
		return Any != EQueryMobilityType::Static;
	}

	// EQueryMobilityType::Static is distinct from Dynamic. Shared enumerator, no fixture.
	bool Observe_Surface003_Nominal()
	{
		EQueryMobilityType Static = EQueryMobilityType::Static;
		return Static != EQueryMobilityType::Dynamic;
	}

	// EQueryMobilityType::Dynamic is distinct from Any. Shared enumerator, no fixture.
	bool Observe_Surface004_Nominal()
	{
		EQueryMobilityType Dynamic = EQueryMobilityType::Dynamic;
		return Dynamic != EQueryMobilityType::Any;
	}

	// ECollisionObjectQueryInitType::AllObjects is distinct from AllStaticObjects.
	bool Observe_Surface006_Nominal()
	{
		ECollisionObjectQueryInitType AllObjects = ECollisionObjectQueryInitType::AllObjects;
		return AllObjects != ECollisionObjectQueryInitType::AllStaticObjects;
	}

	// ECollisionObjectQueryInitType::AllStaticObjects is distinct from AllDynamicObjects.
	bool Observe_Surface007_Nominal()
	{
		ECollisionObjectQueryInitType AllStaticObjects = ECollisionObjectQueryInitType::AllStaticObjects;
		return AllStaticObjects != ECollisionObjectQueryInitType::AllDynamicObjects;
	}

	// ECollisionObjectQueryInitType::AllDynamicObjects is distinct from AllObjects.
	bool Observe_Surface008_Nominal()
	{
		ECollisionObjectQueryInitType AllDynamicObjects = ECollisionObjectQueryInitType::AllDynamicObjects;
		return AllDynamicObjects != ECollisionObjectQueryInitType::AllObjects;
	}

	// FCollisionQueryParams::DefaultQueryParam, TraceTag NAME_None, empty ignore lists.
	// Oracle: ToString is non-empty. Shared constant, not uniquely owned.
	bool Observe_Surface017_Nominal()
	{
		FCollisionQueryParams DefaultQueryParams = FCollisionQueryParams::DefaultQueryParam;
		FString Text = DefaultQueryParams.ToString();
		return DefaultQueryParams.TraceTag == NAME_None && DefaultQueryParams.GetIgnoredActors().Num() == 0 && Text.Len() > 0;
	}

	// FComponentQueryParams::DefaultComponentQueryParams, empty ignore lists.
	// Oracle: ToString is non-empty. Shared constant, not uniquely owned.
	bool Observe_Surface024_Nominal()
	{
		FComponentQueryParams DefaultComponentParams = FComponentQueryParams::DefaultComponentQueryParams;
		FString Text = DefaultComponentParams.ToString();
		return DefaultComponentParams.TraceTag == NAME_None && DefaultComponentParams.GetIgnoredActors().Num() == 0 && Text.Len() > 0;
	}

	// FCollisionResponseParams::DefaultResponseParam copies the engine default
	// container. Oracle: Visibility on that container is ECR_Block. Shared constant.
	bool Observe_Surface028_Nominal()
	{
		FCollisionResponseParams DefaultResponseParam = FCollisionResponseParams::DefaultResponseParam;
		FCollisionResponseParams Copied = DefaultResponseParam;
		FCollisionResponseContainer DefaultContainer = FCollisionResponseContainer::GetDefaultResponseContainer();
		FCollisionResponseParams FromDefault(DefaultContainer);
		return DefaultContainer.GetResponse(ECollisionChannel::Visibility) == ECollisionResponse::ECR_Block && DefaultContainer.GetResponse(ECollisionChannel::WorldStatic) == ECollisionResponse::ECR_Block;
	}

	// FCollisionObjectQueryParams::DefaultObjectQueryParam is the empty engine default.
	// Oracle: IsValid is false and the bitfield is 0. Shared constant.
	bool Observe_Surface031_Nominal()
	{
		FCollisionObjectQueryParams DefaultObjectParams = FCollisionObjectQueryParams::DefaultObjectQueryParam;
		return !DefaultObjectParams.IsValid() && DefaultObjectParams.GetObjectTypesToQuery() == 0;
	}
}
/** @end */
