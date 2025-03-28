{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage rec {
  pname = "intiface-engine";
  version = "3.0.6";

  src = fetchFromGitHub {
    owner = "intiface";
    repo = "intiface-engine";
    rev = "v${version}";
    hash = "sha256-YDXUhbj5KQdn2VVSzJu5dg9V4HxeF2cjT/kIzDoxRes=";
  };

  cargoHash = "sha256-20+llGRSlvH9Jt+zKGyh0qAuHjvizgUn3nHXIJHJuVo=";

  meta = {
    description = "CLI and library frontend for Buttplug.io";
    homepage = "https://intiface.com/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
    mainProgram = "intiface-engine";
  };
}
