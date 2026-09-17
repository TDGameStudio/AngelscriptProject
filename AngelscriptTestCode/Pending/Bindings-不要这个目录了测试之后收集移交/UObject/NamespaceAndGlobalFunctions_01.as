/**
 * @version v1
 * @summary Observe UClass::__StaticClass resolving an internal static-class request by script type name.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe UClass::__StaticClass resolving an internal static-class request by script type name.
 * @topic Baseline
 */
// string, and "DefinitelyMissingClass".
// Expected observations: __StaticClass("Texture2D") matches
// UTexture2D::StaticClass(). The script class name resolves to the generated
// class. Missing and empty names return null.
// Boundary/ownership: The returned UClass is a borrowed engine handle.
// DefaultSafe; no fixture.

UCLASS()
class UTSObjectStaticClassCarrier : UObject
{
}

namespace TS_UObject_NamespaceAndGlobalFunctions_01
{
	bool Observe___StaticClass_Nominal()
	{
		UClass ObjectClass = UClass::__StaticClass("UObject");
		UClass TextureClass = UClass::__StaticClass("Texture2D");
		UClass ScriptClass = UClass::__StaticClass("UTSObjectStaticClassCarrier");
		UClass Missing = UClass::__StaticClass("DefinitelyMissingClass");
		UClass Empty = UClass::__StaticClass("");
		return ObjectClass == UObject::StaticClass() && TextureClass == UTexture2D::StaticClass() && ScriptClass == UTSObjectStaticClassCarrier::StaticClass() && Missing is null && Empty is null;
	}
}
/** @end */
