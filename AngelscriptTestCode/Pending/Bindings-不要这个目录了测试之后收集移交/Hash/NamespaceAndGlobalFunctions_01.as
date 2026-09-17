/**
 * @version v1
 * @summary Observe Hash::CityHash 32/64 overloads for FString and TArray<int8> with unseeded, single-seed, and dual-seed variants.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe Hash::CityHash 32/64 overloads for FString and TArray<int8> with unseeded, single-seed, and dual-seed variants.
 * @topic Baseline
 */
// uint32 Hash::CityHash32(const TArray<int8>& buf);
// uint64 Hash::CityHash64(const FString& buf);
// uint64 Hash::CityHash64(const TArray<int8>& buf);
// uint64 Hash::CityHash64WithSeed(const FString& buf, uint64 seed);
// uint64 Hash::CityHash64WithSeed(const TArray<int8>& buf, uint64 seed);
// uint64 Hash::CityHash64WithSeeds(const FString& buf, uint64 seed0, uint64 seed1);
// uint64 Hash::CityHash64WithSeeds(const TArray<int8>& buf, uint64 seed0, uint64 seed1);
// Inputs: String "abc", empty string, byte array {97,98,99}, empty byte array,
// seed 1, and seeds (1, 2).
// Expected observations: The same buffer hashes deterministically. Empty
// buffers still return a value. Changing the seed changes the 64-bit result.
// Boundary/ownership: Hashing copies the bytes for the computation and does
// not retain the string or array.

namespace TS_Hash_NamespaceAndGlobalFunctions_01
{
	bool Observe_CityHash32_Nominal()
	{
		FString Text = "abc";
		uint32 TextHash = Hash::CityHash32(Text);
		uint32 TextHashAgain = Hash::CityHash32(Text);
		uint32 EmptyHash = Hash::CityHash32("");
		TArray<int8> Bytes;
		Bytes.Add(97);
		Bytes.Add(98);
		Bytes.Add(99);
		uint32 ByteHash = Hash::CityHash32(Bytes);
		TArray<int8> EmptyBytes;
		uint32 EmptyByteHash = Hash::CityHash32(EmptyBytes);
		return TextHash == TextHashAgain && EmptyHash != TextHash && ByteHash != EmptyByteHash && EmptyHash == EmptyByteHash;
	}

	bool Observe_CityHash64_Nominal()
	{
		FString Text = "abc";
		uint64 TextHash = Hash::CityHash64(Text);
		uint64 TextHashAgain = Hash::CityHash64(Text);
		TArray<int8> Bytes;
		Bytes.Add(97);
		Bytes.Add(98);
		Bytes.Add(99);
		uint64 ByteHash = Hash::CityHash64(Bytes);
		TArray<int8> EmptyBytes;
		uint64 EmptyByteHash = Hash::CityHash64(EmptyBytes);
		uint64 EmptyStringHash = Hash::CityHash64("");
		return TextHash == TextHashAgain && ByteHash != EmptyByteHash && EmptyStringHash == EmptyByteHash && EmptyStringHash != TextHash;
	}

	bool Observe_CityHash64WithSeed_Nominal()
	{
		FString Text = "abc";
		uint64 Unseeded = Hash::CityHash64(Text);
		uint64 Seeded = Hash::CityHash64WithSeed(Text, 1);
		uint64 SeededAgain = Hash::CityHash64WithSeed(Text, 1);
		TArray<int8> Bytes;
		Bytes.Add(97);
		uint64 ByteSeeded = Hash::CityHash64WithSeed(Bytes, 1);
		uint64 ByteSeededAgain = Hash::CityHash64WithSeed(Bytes, 1);
		return Seeded == SeededAgain && Seeded != Unseeded && ByteSeeded == ByteSeededAgain;
	}

	bool Observe_CityHash64WithSeeds_Nominal()
	{
		FString Text = "abc";
		uint64 OneSeed = Hash::CityHash64WithSeed(Text, 1);
		uint64 TwoSeeds = Hash::CityHash64WithSeeds(Text, 1, 2);
		uint64 TwoSeedsAgain = Hash::CityHash64WithSeeds(Text, 1, 2);
		TArray<int8> Bytes;
		Bytes.Add(97);
		uint64 ByteDual = Hash::CityHash64WithSeeds(Bytes, 1, 2);
		uint64 ByteDualAgain = Hash::CityHash64WithSeeds(Bytes, 1, 2);
		return TwoSeeds == TwoSeedsAgain && TwoSeeds != OneSeed && ByteDual == ByteDualAgain;
	}
}
/** @end */
