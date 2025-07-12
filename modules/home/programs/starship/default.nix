_: {
  programs.starship = {
    enableTransience = true;
    settings = {
      add_newline = false;
      format = builtins.concatStringsSep "" [
        "\n"
        "[╓](bold)"
        "$fill"
        "\n"
        "$username"
        "$hostname"
        "$kubernetes"
        "$vcsh"
        "$git_branch"
        "$git_commit"
        "$git_state"
        "$git_metrics"
        "$git_status"
        "$jj"
        "$jjstate"
        "$hg_branch"
        "$docker_context"
        "$package"
        "$cmake"
        "$dart"
        "$deno"
        "$direnv"
        "$dotnet"
        "$elixir"
        "$elm"
        "$erlang"
        "$golang"
        "$helm"
        "$java"
        "$julia"
        "$kotlin"
        "$nim"
        "$nodejs"
        "$ocaml"
        "$perl"
        "$php"
        "$purescript"
        "$red"
        "$ruby"
        "$rust"
        "$scala"
        "$swift"
        "$terraform"
        "$vlang"
        "$vagrant"
        "$zig"
        "$nix_shell"
        "\${custom.mob}"
        "$conda"
        "$memory_usage"
        "$aws"
        "$gcloud"
        "$openstack"
        "$env_var"
        "$crystal"
        "$cmd_duration"
        "$lua"
        "$jobs"
        "$battery"
        "\n"
        "$directory"
        "\n"
        "$status"
        " [ $shell](bold)"
        "$shlvl"
        "$character"
      ];
      fill = {
        symbol = "─";
        style = "bold";
      };
      directory = {
        truncation_length = 0;
        format = " [ : $path]($style)[$read_only]($read_only_style) ";
      };
      direnv.disabled = false;
      shell.disabled = false;
      shlvl = {
        disabled = false;
        threshold = 2;
        style = "bold red";
        symbol = "";
      };
      status = {
        disabled = false;
        symbol = " ";
      };
      username = {
        show_always = true;
        format = " [  $user]($style) ";
      };
      git_branch = {
        format = "[$symbol$branch]($style) ";
      };
      nix_shell = {
        format = "via [$symbol$state]($style) ";
      };
      custom = {
        mob = {
          command = "echo $MOB_TIMER_ROOM";
          format = "[ ($output)]($style) ";
          when = "[[ -v MOB_TIMER_ROOM ]]";
        };
        jj = {
          command = ''
            jj log -r@ -n1 --ignore-working-copy --no-graph --color always  -T '
              separate(" ",
                bookmarks.map(|x| truncate_end(10, x.name(), "…")).join(" "),
                tags.map(|x| truncate_end(10, x.name(), "…")).join(" "),
                surround("\"", "\"", truncate_end(24, description.first_line(), "…")),
                if(conflict, "conflict"),
                if(divergent, "divergent"),
                if(hidden, "hidden"),
              )
            '
          '';
          when = "jj root";
          symbol = " jj ";
          format = "[$symbol$output]($style) ";
        };
        jjstate = {
          when = "jj root";
          command = ''
            jj log -r@ -n1 --no-graph -T "" --stat | tail -n1 | sd "(\d+) files? changed, (\d+) insertions?\(\+\), (\d+) deletions?\(-\)" ' ''${1}m ''${2}+ ''${3}-' | sd " 0." ""
          '';
          format = "[$output]($style) ";
        };
      };
      aws.symbol = " ";
      conda.symbol = " ";
      dart.symbol = " ";
      directory.read_only = " ";
      docker_context.symbol = " ";
      elixir.symbol = " ";
      elm.symbol = " ";
      git_branch.symbol = " ";
      golang.symbol = " ";
      hg_branch.symbol = " ";
      java.symbol = " ";
      julia.symbol = " ";
      memory_usage.symbol = "󰍛 ";
      nim.symbol = " ";
      nix_shell.symbol = " ";
      package.symbol = "󰏗 ";
      perl.symbol = " ";
      php.symbol = " ";
      ruby.symbol = " ";
      rust.symbol = " ";
      scala.symbol = " ";
      swift.symbol = "ﯣ ";
    };
  };
}
