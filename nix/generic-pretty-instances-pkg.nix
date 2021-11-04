{ mkDerivation, base, base16-bytestring, bytestring, GenericPretty
, hpack, hspec, lib, pretty, pretty-simple, proto-lens
, proto-lens-runtime, text, universum, vector
}:
mkDerivation {
  pname = "generic-pretty-instances";
  version = "0.1.0.0";
  src = ./../generic-pretty-instances;
  libraryHaskellDepends = [
    base base16-bytestring bytestring GenericPretty pretty
    pretty-simple proto-lens proto-lens-runtime text universum vector
  ];
  libraryToolDepends = [ hpack ];
  testHaskellDepends = [
    base base16-bytestring bytestring GenericPretty hspec pretty
    pretty-simple proto-lens proto-lens-runtime text universum vector
  ];
  prePatch = "hpack";
  homepage = "https://github.com/coingaming/hs/generic-pretty-instances";
  description = "GenericPretty canonical instances";
  license = lib.licenses.bsd3;
}
