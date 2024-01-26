# shell.nix

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.azure-cli
    pkgs.terraform
    # Optionally, set up any other configurations or commands you need
  ];
}