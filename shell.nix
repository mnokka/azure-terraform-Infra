# shell.nix

{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs. azure-cli
    # Add other dependencies as needed
  ];
}


