with import <nixpkgs> { };
(vscode-with-extensions.override {
  vscodeExtensions =
    with vscode-extensions;
    [ ms-vscode.cpptools ]
    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "code-gnu-global";
        publisher = "austin";
        version = "0.2.2";
        hash = "sha256-pcFfBbcELEEBrOHSIZeZUu0CnYDpfc2Ni6oIJU1N6Ls=";
      }
    ];
})
