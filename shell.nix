{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    (python311Packages.python.withPackages (
      p: with p; [
        numpy
        scipy
        matplotlib
      ]
    ))
    ffmpeg
  ];
}