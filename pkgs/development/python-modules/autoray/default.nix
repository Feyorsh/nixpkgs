{ lib
, buildPythonPackage
, fetchPypi
, pythonOlder
, setuptools-scm
  # testing
, pytestCheckHook
, numpy
, scipy
}:

buildPythonPackage rec {
  pname = "autoray";
  version = "0.7.0";
  pyproject = true;

  disabled = pythonOlder "3.9";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-eCnSElhRL4fgLyPOdK5XWa9M6JmAadLM5TRo8dcBohk=";
  };

  build-system = [ setuptools-scm ];

  nativeCheckInputs = [
    pytestCheckHook
    numpy
    scipy
  ];

  pythonImportsCheck = [ "autoray" ];

  meta = with lib; {
    description = "";
    homepage = "https://autoray.readthedocs.io";
    license = licenses.asl20;
    maintainers = [ ];
  };
}
