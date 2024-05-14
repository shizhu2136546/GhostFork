{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    systems,
    nixpkgs,
    ...
 
    # This gives us a central place to set the node version
    node_overlay = final: prev: {
        nodejs = prev.nodejs-18_x;
    };

    eachSystem = f:
      nixpkgs.lib.genAttrs (import systems) (
        system:
          f ((nixpkgs.legacyPackages.${system}.extend yarn_overlay).extend node_overlay)
      );
  in {

    devShells = eachSystem (pkgs: {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
            nodejs
            yarn
        ];

        shellHook = ''
            echo "node `${pkgs.nodejs}/bin/node --version`"
        '';
      };
    });
  };
}
