// Theme: Containers.TArray. TArray<FString> Add Hello. Extra: empty string element vs empty array.

void Test()
{
	TArray<FString> Names;
	Names.Add("Hello");
}

bool Observe_StringArrayNominal()
{
	TArray<FString> Names;
	Names.Add("Hello");
	return Names.Num() == 1 && Names[0] == "Hello";
}

bool Observe_StringArrayEmptyElement()
{
	TArray<FString> Names;
	Names.Add("");
	return Names.Num() == 1 && Names[0].Len() == 0;
}
