{
  lib,
  rustPlatform,
  fetchFromGitLab,
  fetchpatch,
  meson,
  ninja,
  pkg-config,
  scdoc,
  libgbm,
  lz4,
  zstd,
  ffmpeg,
  cargo,
  rustc,
  vulkan-headers,
  vulkan-loader,
  shaderc,
  llvmPackages,
  autoPatchelfHook,
  wayland-scanner,
  rust-bindgen,
  nix-update-script,
}:
llvmPackages.stdenv.mkDerivation (finalAttrs: {
  pname = "waypipe";
  version = "0.11.0";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "mstoeckl";
    repo = "waypipe";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Tbd/yY90yb2+/ODYVL3SudHaJCGJKatZ9FuGM2uAX+8=";
  };

  cargoPatches = lib.optionals (llvmPackages.stdenv.hostPlatform.isDarwin) [
    (fetchpatch {
      url = "https://github.com/J-x-Z/waypipe-darwin/commit/38d4b535e0e0168cfba0cb1ad6ec846253629f09.patch";
      hash = "sha256-UJXToroFteOkslfRy8i4yzb2Q4bWWKVs22wKQ6dGBr8=";
    })
  ];

  patches = lib.optionals (llvmPackages.stdenv.hostPlatform.isDarwin) [
    (fetchpatch {
      url = "https://github.com/J-x-Z/waypipe-darwin/commit/38d4b535e0e0168cfba0cb1ad6ec846253629f09.patch";
      hash = "sha256-aioIUTwl9/Z2CKagSYHsaz6yOZKxt0O5fFRtsjIeKSE=";
      excludes = [ "Cargo.lock" ];
    })
  ];

  postPatch = ''
    sed -e '/gbmfallback/d' -i meson.build
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = if (llvmPackages.stdenv.hostPlatform.isDarwin) then "sha256-IUvXHLxrhc2Au57wsE53Q+NL1cZzFcaRG3HDV8s3xWw=" else "sha256-IUvXHLxrhc2Au57wsE53Q+NL1cZzFcaRG3HDV8s3xWw=";
  };

  strictDeps = true;
  env.LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
  depsBuildBuild = [ pkg-config ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
    cargo
    shaderc # for glslc
    rustc
    wayland-scanner
    rustPlatform.cargoSetupHook
    rust-bindgen
  ] ++ lib.optionals (llvmPackages.stdenv.hostPlatform.isLinux) [
    autoPatchelfHook
  ];

  buildInputs = [
    lz4
    zstd
    ffmpeg
    vulkan-headers
    vulkan-loader
  ] ++ lib.optionals (llvmPackages.stdenv.hostPlatform.isLinux) [
    libgbm
  ];

  runtimeDependencies = [
    ffmpeg.lib
    vulkan-loader
  ] ++ lib.optionals (llvmPackages.stdenv.hostPlatform.isLinux) [
    libgbm
  ];

  mesonFlags = lib.optionals (llvmPackages.stdenv.hostPlatform.isDarwin) [
    (lib.mesonEnable "with_gbm" false)
    (lib.mesonEnable "with_video" false)
    (lib.mesonEnable "with_dmabuf" false)
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Network proxy for Wayland clients (applications)";
    longDescription = ''
      waypipe is a proxy for Wayland clients. It forwards Wayland messages and
      serializes changes to shared memory buffers over a single socket. This
      makes application forwarding similar to ssh -X feasible.
    '';
    homepage = "https://mstoeckl.com/notes/gsoc/blog.html";
    changelog = "https://gitlab.freedesktop.org/mstoeckl/waypipe/-/releases#v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ mic92 ];
    mainProgram = "waypipe";
  };
})
