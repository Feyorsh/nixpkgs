{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
with python3Packages;
buildPythonApplication rec {
  pname = "supernote-tool";
  version = "0.6.4";

  format = "pyproject";
  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "jya-dev";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-EKfhg0puWu41cY3v+cV1f/0eel08sOAFf5tx+csFO1g=";
  };

  nativeBuildInputs = [
    setuptools
    hatchling
  ];
  propagatedBuildInputs = [
    colour
    pillow
    potracer
    pypng
    svglib
    svgwrite
    fusepy
  ];

  meta = {
    description = "Unofficial python tool for Supernote";
    license = lib.licenses.asl20;
    homepage = "https://github.com/jya-dev/supernote-tool";
    maintainers = with lib.maintainers; [ jfvillablanca ];
    mainProgram = "supernote-tool";
    platforms = lib.platforms.all;
  };
}
