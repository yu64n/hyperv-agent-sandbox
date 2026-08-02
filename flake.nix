{
  description = "Tools for the Hyper-V agent sandbox";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }: let system = "x86_64-linux"; pkgs = import nixpkgs { inherit system; }; in {
    devShells.${system}.default = pkgs.mkShell { packages = with pkgs; [ ansible-core git gnumake jq openssh shellcheck shfmt yamllint yq-go xorriso ]; };
  };
}

