/**
 * @version v1
 * @summary Hash host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic Hash
 *
 * city-hash-32
 * city-hash-64
 * city-hash-64-with-seed
 * city-hash-64-with-seeds
 */
/**
 * @begin city-hash-32
 * @summary seed 1,
 * @topic Unreal
 */
/**
 * @function ObserveCityHash32Nominal
 * @summary seed 1,
 * @covers Hash.city-hash-32
 * @inputs Hash values exercised by this observe
 * @return true when the observe comparison holds
 */
// seed 1,

 and seeds (1, 2).
// Expected observations: The same buffer hashes deterministically. Empty
// buffers still return a value. Changing the seed changes the 64-bit result.
// Boundary/ownership: Hashing copies the bytes for the computation and does
// not retain the string or array.
bool ObserveCityHash32Nominal()
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
/** @end */
/**
 * @begin city-hash-64
 * @summary not retain the string or array.
 * @topic Unreal
 */
/**
 * @function ObserveCityHash64Nominal
 * @summary not retain the string or array.
 * @covers Hash.city-hash-64
 * @inputs Hash values exercised by this observe
 * @return true when the observe comparison holds
 */
// seed 1,

bool ObserveCityHash64Nominal()
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
/** @end */
/**
 * @begin city-hash-64-with-seed
 * @summary not retain the string or array.
 * @topic Unreal
 */
/**
 * @function ObserveCityHash64WithSeedNominal
 * @summary not retain the string or array.
 * @covers Hash.city-hash-64-with-seed
 * @inputs Hash values exercised by this observe
 * @return true when the observe comparison holds
 */
// seed 1,

bool ObserveCityHash64WithSeedNominal()
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
/** @end */
/**
 * @begin city-hash-64-with-seeds
 * @summary not retain the string or array.
 * @topic Unreal
 */
/**
 * @function ObserveCityHash64WithSeedsNominal
 * @summary not retain the string or array.
 * @covers Hash.city-hash-64-with-seeds
 * @inputs Hash values exercised by this observe
 * @return true when the observe comparison holds
 */
// seed 1,

bool ObserveCityHash64WithSeedsNominal()
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
/** @end */
