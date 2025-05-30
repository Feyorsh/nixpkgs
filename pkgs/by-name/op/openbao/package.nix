{
  lib,
  fetchFromGitHub,
  buildGoModule,
  go_1_24,
  versionCheckHook,
  nix-update-script,
  nixosTests,
  callPackage,
  stdenvNoCC,
  withUi ? true,
  withHsm ? stdenvNoCC.hostPlatform.isLinux,
}:

buildGoModule.override { go = go_1_24; } (finalAttrs: {
  pname = "openbao";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "openbao";
    repo = "openbao";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qbLaa7EUQywPRTIgUclTomDDBxzdQnyVAqCGD+iOlpg=";
  };

  vendorHash = "sha256-Upvv3dxS6HIFxR6T+2/dqnFsUtemjOGUaiICgPlepJ8=";

  proxyVendor = true;

  subPackages = [ "." ];

  tags = lib.optional withHsm "hsm" ++ lib.optional withUi "ui";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/openbao/openbao/version.GitCommit=${finalAttrs.src.rev}"
    "-X github.com/openbao/openbao/version.fullVersion=${finalAttrs.version}"
    "-X github.com/openbao/openbao/version.buildDate=1970-01-01T00:00:00Z"
  ];

  postConfigure = lib.optionalString withUi ''
    cp -r --no-preserve=mode ${finalAttrs.passthru.ui} http/web_ui
  '';

  postInstall = ''
    mv $out/bin/openbao $out/bin/bao
  '';

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  versionCheckProgram = "${placeholder "out"}/bin/bao";
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  passthru = {
    ui = callPackage ./ui.nix { };
    tests = { inherit (nixosTests) openbao; };
    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "ui"
      ];
    };
  };

  meta = {
    homepage = "https://www.openbao.org/";
    description = "Open source, community-driven fork of Vault managed by the Linux Foundation";
    changelog = "https://github.com/openbao/openbao/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    mainProgram = "bao";
    maintainers = with lib.maintainers; [ brianmay ];
  };
})
