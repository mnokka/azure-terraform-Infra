# shell.nix

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.azure-cli
    pkgs.terraform
    # Add other dependencies as needed
  ];
}


