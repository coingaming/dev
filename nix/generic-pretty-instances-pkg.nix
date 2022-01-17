{ mkDerivation, base, base16-bytestring, bytestring, GenericPretty
, hpack, hspec, persistent, pretty, pretty-simple, proto-lens
, proto-lens-runtime, secp256k1-haskell, signable, stdenv, text
, time, universum, unix, vector
}:
mkDerivation {
  pname = "generic-pretty-instances";
  version = "0.1.0.0";
  src = ./../generic-pretty-instances;
  libraryHaskellDepends = [
    base base16-bytestring bytestring GenericPretty persistent pretty
    pretty-simple proto-lens proto-lens-runtime secp256k1-haskell
    signable text time universum unix vector
  ];
  libraryToolDepends = [ hpack ];
  testHaskellDepends = [
    base base16-bytestring bytestring GenericPretty hspec persistent
    pretty pretty-simple proto-lens proto-lens-runtime
    secp256k1-haskell signable text time universum unix vector
  ];
  prePatch = "hpack";
  homepage = "https://github.com/coingaming/hs/generic-pretty-instances";
  description = "GenericPretty canonical instances";
  license = stdenv.lib.licenses.bsd3;
}
