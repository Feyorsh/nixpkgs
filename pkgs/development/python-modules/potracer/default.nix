{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
}:
buildPythonPackage rec {
  pname = "potracer";
  version = "0.0.4";

  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-MsvbmERGBmvPvotgAUKlS5D6baJ0tpIZRzIF1uTAlxM=";
  };

  propagatedBuildInputs = [ numpy ];

  # no upstream tests
  doCheck = false;

  meta = {
    description = "Pure Python Port of Potrace";
    homepage = "https://github.com/tatarize/potrace";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ jfvillablanca ];
  };
}
