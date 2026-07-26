{ config, pkgs, ... }:

{
  home.username = "cvberscape";
  home.homeDirectory = "/home/cvberscape";

  home.stateVersion = "26.11";

  nixpkgs.config.allowUnfree = true;

  systemd.user.enable = false;

  nix = {
    package = pkgs.nix;
      settings = {
      build-users-group = "";
      sandbox = false;
      experimental-features = [ "nix-command" "flakes" ];
    };
  };

  home.packages = with pkgs; [
    android-studio
    watchman
    vesktop
    catppuccin-cursors.mochaSky
    code-cursor
    carapace
    helix-db
    bitwarden-cli
    heroic
  ];

    home.sessionVariables = {
    XCURSOR_THEME = "catppuccin-mocha-sky-cursors";
    XCURSOR_SIZE = "24";
    XCURSOR_PATH = "${config.home.profileDirectory}/share/icons:/usr/share/icons:${config.home.homeDirectory}/.icons";
  };

  home.file = {
  };

  programs.home-manager.enable = true;
}
