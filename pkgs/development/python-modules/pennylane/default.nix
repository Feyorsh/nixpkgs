{ lib
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, setuptools
# runtime
, numpy
, scipy
, networkx
, rustworkx
, autograd
, toml
, appdirs
, semantic-version
, autoray
, cachetools
, pennylane-lightning
, requests
, typing-extensions
# optional
# , openfermionpyscf # for qml.qchem
, withJax ? true , jax, jaxlib
, withPytorch ? false , pytorch
, withTensorflow ? false , tensorflow
, withQChem ? false , pyscf # openfermion, pyscf-openfermion
# tests
, pytestCheckHook
, pytest-cov
, pytest-mock
, pytest-benchmark
, pytest-xdist
, flaky
, matplotlib
, writeText
}:
buildPythonPackage rec {
  pname = "pennylane";
  version = "0.37.0";
  pyproject = true;

  disabled = pythonOlder "3.10";

  src = fetchFromGitHub {
    inherit version;
    owner = "PennyLaneAI";
    repo = "pennylane";
    rev = "refs/tags/v${version}";
    hash = "sha256-cU3n3OV+UjT25Cu1LSmoCGvFezpGR6mveRS9Fw+blBM=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    numpy
    scipy
    networkx
    rustworkx
    autograd
    toml
    appdirs
    semantic-version
    autoray
    cachetools
    pennylane-lightning
    requests
    typing-extensions

    matplotlib # technically optional?
  ] ++ lib.optionals (withJax) [
    jax
    jaxlib
  ] ++ lib.optionals (withPytorch) [
    pytorch
  ] ++ lib.optionals (withTensorflow) [
    tensorflow
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov
    pytest-mock
    pytest-benchmark
    pytest-xdist
    flaky
  ];
  MATPLOTLIBRC = writeText "" ''
    backend: Agg
  '';

  dontUsePytestXdist = true;

  pytestFlagsArray = let
    disabledTests = [
      "slow"
      "autograd"
    ] ++ lib.optional (!withJax) "jax"
    ++ lib.optional (!withJax) "torch"
    ++ lib.optional (!withJax) "tf"
    ++ lib.optional (!withQChem) "qchem"
      ;
  in
    [
      "--benchmark-skip"
      "-x"
      "tests"
      # "pennylane/devices/tests"
      # "-m '${lib.concatMapStringsSep " and " (x: "not " + x) disabledTests}'"
      "-m 'qcut and not slow'"
    ];


  meta = with lib; {
    description = "Cross-platform Python library for differentiable programming of quantum computers.";
    homepage = "https://pennylane.ai";
    downloadPage = "https://github.com/PennyLaneAI/pennylane/releases";
    changelog = "https://docs.pennylane.ai/en/stable/development/release_notes.html";
    license = licenses.asl20;
    maintainers = with maintainers; [ shorden ];
  };
}
