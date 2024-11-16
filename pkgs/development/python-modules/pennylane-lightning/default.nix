{ lib
, stdenv
, pythonOlder
, buildPythonPackage
, fetchFromGitHub
, setuptools
, cmake
, tomli
, ninja
, pybind11
# pennylane
# LAPACK
, scipy
, lapack
, pytestCheckHook
}:
buildPythonPackage rec {
  pname = "pennylane-lightning";
  version = "0.39.0";
  pyproject = true;

  disabled = pythonOlder "3.10";

  src = fetchFromGitHub {
    inherit version;
    owner = "PennyLaneAI";
    repo = "pennylane-lightning";
    rev = "refs/tags/v${version}";
    hash = "sha256-CxWlKoizGlL/YMXfaY88eszwL6xjhJSgkrkX5UU6CQQ=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail \
      'FetchContent_MakeAvailable(pybind11)' \
      'add_subdirectory(${pybind11.src} pybind11 SYSTEM)' \
      --replace-fail \
      'SCIPY_LIBS_PATH="''${SCIPYLIBS}"' \
      'SCIPY_LIBS_PATH="${lib.getLib lapack}"'

    substituteInPlace pyproject.toml --replace-fail \
      "cmake~=3.27.0" \
      "cmake"
  '';

  dontUseCmakeConfigure = true;
  preBuild = ''
    export CMAKE_ARGS="-DPL_BACKEND=lightning_qubit -DENABLE_LAPACK=1"
  '';

  build-system = [
    setuptools
    cmake
    ninja
    tomli
    pybind11
    # isort
  ];

  dependencies = [
    # pennylane
    scipy
    lapack
  # ] ++ lib.optionals (stdenv.hostPlatform.isDarwin) [
  #   llvmPackages.openmp
  ];

  # dependencies = [
  # numpy
  # scipy
  # networkx
  # rustworkx
  # autograd
  # toml
  # appdirs
  # semantic-version
  # # autoray
  # cachetools
  # # pennylane-lightning
  # requests
  # typing-extensions
  # ];
  # pypaBuildFlags = [
  #   "-C-DENABLE_LAPACK=ON"
  # ];

  cmakeFlags = [
    "-DENABLE_LAPACK=ON"
  ];

  # needed to break circular dependency between pennylane and pennylane-lightning
  dontCheckRuntimeDeps = true;

  # nativeCheckInputs = [ pytestCheckHook ];

  meta = with lib; {
    description = "Cross-platform Python library for differentiable programming of quantum computers.";
    homepage = "https://pennylane.ai";
    downloadPage = "https://github.com/PennyLaneAI/pennylane/releases";
    changelog = "https://docs.pennylane.ai/en/stable/development/release_notes.html";
    license = licenses.asl20;
    maintainers = with maintainers; [ shorden ];
  };
}
