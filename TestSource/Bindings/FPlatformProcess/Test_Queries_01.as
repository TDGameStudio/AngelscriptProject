// Purpose: Observe FPlatformProcess::CanLaunchURL for supported and
// unsupported targets.
// AS-facing API: bool bSupported = FPlatformProcess::CanLaunchURL(const FString& URL);
// Inputs: "https://example.com" as the known-positive URL, empty URL, and
// "not-a-protocol" as a boundary value.
// Expected observations: https is true on this host. Empty URL is false.
// A non-URL string is false.
// Boundary/ownership: CanLaunchURL does not launch. The URL string is
// borrowed.

namespace TS_FPlatformProcess_Queries_01
{
	bool Observe_CanLaunchURL_Nominal()
	{
		bool bHttps = FPlatformProcess::CanLaunchURL("https://example.com");
		bool bEmpty = FPlatformProcess::CanLaunchURL("");
		bool bInvalid = FPlatformProcess::CanLaunchURL("not-a-protocol");
		return bHttps && !bEmpty && !bInvalid;
	}
}
