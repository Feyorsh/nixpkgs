{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  doxygen,
  libGL,
  glew,
  xorg,
  ffmpeg,
  libjpeg,
  libpng,
  libtiff,
  eigen,
  Carbon,
  Cocoa,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pangolin";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "stevenlovegrove";
    repo = "Pangolin";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-B5YuNcJZHjR3dlVs66rySi68j29O3iMtlQvCjTUZBeY=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    doxygen
  ];

  buildInputs =
    [
      libGL
      glew
      xorg.libX11
      ffmpeg
      libjpeg
      libpng
      libtiff.out
      eigen
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      Carbon
      Cocoa
    ];

  # The tests use cmake's findPackage to find the installed version of
  # pangolin, which isn't what we want (or available).
  doCheck = false;
  cmakeFlags = [ (lib.cmakeBool "BUILD_TESTS" false) ];

  meta = {
    description = "Lightweight portable rapid development library for managing OpenGL display / interaction and abstracting video input";
    longDescription = ''
      Pangolin is a lightweight portable rapid development library for managing
      OpenGL display / interaction and abstracting video input. At its heart is
      a simple OpenGl viewport manager which can help to modularise 3D
      visualisation without adding to its complexity, and offers an advanced
      but intuitive 3D navigation handler. Pangolin also provides a mechanism
      for manipulating program variables through config files and ui
      integration, and has a flexible real-time plotter for visualising
      graphical data.
    '';
    homepage = "https://github.com/stevenlovegrove/Pangolin";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
