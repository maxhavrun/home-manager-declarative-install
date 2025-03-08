{ config, lib, pkgs, ... }:

{

//Your config
////
///

environment.systemPackages = with pkgs; [
        home-manager
];
  
systemd.services.setup-home-manager = {
    description = "Setup Home Manager for all users";
    after = [ "network.target" "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "setup-home-manager" ''
        USERS=$(awk -F: '$3 >= 1000 {print $1}' /etc/passwd)

        for USER in $USERS; do
          HOME_DIR=$(eval echo ~$USER)
          
          if [ -z "$HOME_DIR" ] || [ ! -d "$HOME_DIR" ]; then
            continue
          fi

          if ! sudo -u $USER nix-channel --list | grep -q home-manager; then
            sudo -u $USER nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz home-manager
          fi
          
          sudo -u $USER nix-channel --update
          sudo -u $USER home-manager switch
        done
      '';
    };
  };

}
