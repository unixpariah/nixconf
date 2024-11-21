ROOT := `which sudo > /dev/null 2>&1 && echo sudo || echo doas`
GENERATION := `readlink /nix/var/nix/profiles/system | awk -F'-' '{print $1"-"($2+1)"-"$3}'`

default:
    @just --list

generation:
    @readlink /nix/var/nix/profiles/system

specialisation:
    @cat /etc/specialisation

switch:
    @nix-env -p /nix/var/nix/profiles/system --set /tmp/{{GENERATION}}/result
    @/tmp/{{GENERATION}}/result/specialisation/$(just specialisation)/bin/switch-to-configuration test
    @nix-env --profile /nix/var/nix/profiles/system --set /tmp/{{GENERATION}}/result
    @/tmp/{{GENERATION}}/result/bin/switch-to-configuration boot

rebuild:
    @nix build ".#nixosConfigurations.$(hostname).config.system.build.toplevel" --log-format internal-json -v --out-link /tmp/{{GENERATION}}/result |& nom --json
    @nvd diff /run/current-system /tmp/{{GENERATION}}/result/specialisation/$(just specialisation)

rebuild-switch:
    @just rebuild
    @{{ROOT}} just switch

rebuild-switch-update:
    @nix flake update
    @just rebuild-switch
