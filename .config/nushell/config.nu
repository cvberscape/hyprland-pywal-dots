# config.nu
#
# Installed by:
# version = "0.108.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R
use std/clip
use std null_device

$env.config.history.file_format = "sqlite"
$env.config.history.isolation = false
$env.config.history.max_size = 10_000_000
$env.config.history.sync_on_enter = true

source ~/.local/share/atuin/init.nu

alias c = clear
alias e = yazi
alias lsh = ls -a
alias grep = ^grep --color=auto
alias vim = nvim
alias py = python
alias code = cursor

def "nord c" [country: string] {
    sudo systemctl start nordvpnd 
    nordvpn c ($country)
}

def "nord d" [] {
    nordvpn d
    sudo systemctl stop nordvpnd
}

def tauri [] {
  with-env [WEBKIT_DISABLE_DMABUF_RENDERER: "1"] {
    bun tauri dev
  }
}

def tauribuild [] {
  with-env [WEBKIT_DISABLE_DMABUF_RENDERER: "1"] {
    bun tauri build
  }
}

def posix [cmd: string] {
    bash -c $cmd
}

let nix_profile = ($env.HOME | path join ".nix-profile")

#if ($nix_profile | path exists) {
#    # Keep system PATH first
#    $env.PATH = (
#        $env.PATH
#        | append $"($nix_profile)/bin"
#        | append $"($nix_profile)/sbin"
#    )
#
#    # Add only the Nix lib dir for libstdc++.so.6, after system libs
#    let nix_gcc_lib = (glob $"($nix_profile)/lib/libstdc++.so.6" | first | path dirname)
#
#    if ($nix_gcc_lib != null) {
#        $env.LD_LIBRARY_PATH = (
#            (if ($env.LD_LIBRARY_PATH? != null) { $env.LD_LIBRARY_PATH } else { "" })
#            | split row (char esep)
#            | append $nix_gcc_lib
#            | uniq
#            | str join (char esep)
#        )
#    }
#}

export-env {
  $env.EDITOR = "nvim"
  $env.ANDROID_HOME = $"($env.HOME)/Android/Sdk"
  $env.JAVA_HOME = "/usr/lib/jvm/java-17-openjdk"

  $env.PATH = ($env.PATH | split row (char esep) | append [
    $"($env.ANDROID_HOME)/emulator"
    $"($env.ANDROID_HOME)/platform-tools"
    $"($env.JAVA_HOME)/bin"
  ] | uniq | str join (char esep))
}

fastfetch


$env.config.show_banner = false

$env.config.rm.always_trash = false

$env.config.recursion_limit = 100

$env.config.edit_mode = "vi"

$env.config.cursor_shape.emacs = "line"
$env.config.cursor_shape.vi_insert = "line"
$env.config.cursor_shape.vi_normal = "block"

$env.config.completions.algorithm = "substring"
$env.config.completions.sort = "smart"
$env.config.completions.case_sensitive = false
$env.config.completions.quick = true
$env.config.completions.partial = true
$env.config.completions.use_ls_colors = true

$env.config.use_kitty_protocol = true

$env.config.shell_integration.osc2 = true
$env.config.shell_integration.osc7 = true
$env.config.shell_integration.osc8 = true
#$env.config.shell_integration.osc9_9 = true
$env.config.shell_integration.osc133 = true
$env.config.shell_integration.osc633 = true
$env.config.shell_integration.reset_application_mode = true

$env.config.bracketed_paste = true

$env.config.use_ansi_coloring = "auto"

$env.config.error_style = "fancy"

$env.config.highlight_resolved_externals = true

$env.config.display_errors.exit_code = false
$env.config.display_errors.termination_signal = true

$env.config.footer_mode = 25

$env.config.table.mode = "single"
$env.config.table.index_mode = "always"
$env.config.table.show_empty = true
$env.config.table.padding.left = 1
$env.config.table.padding.right = 1
$env.config.table.trim.methodology = "wrapping"
$env.config.table.trim.wrapping_try_keep_words = true
$env.config.table.trim.truncating_suffix =  "..."
$env.config.table.header_on_separator = true
$env.config.table.abbreviated_row_count = null
$env.config.table.footer_inheritance = true
$env.config.table.missing_value_symbol = $"(ansi magenta_bold)nope(ansi reset)"

$env.config.datetime_format.table = null
$env.config.datetime_format.normal = $"(ansi blue_bold)%Y(ansi reset)(ansi yellow)-(ansi blue_bold)%m(ansi reset)(ansi yellow)-(ansi blue_bold)%d(ansi reset)(ansi black)T(ansi magenta_bold)%H(ansi reset)(ansi yellow):(ansi magenta_bold)%M(ansi reset)(ansi yellow):(ansi magenta_bold)%S(ansi reset)"

$env.config.filesize.unit = "metric"
$env.config.filesize.show_unit = true
$env.config.filesize.precision = 1

$env.config.render_right_prompt_on_last_line = false

$env.config.float_precision = 2

$env.config.ls.use_ls_colors = true

# `nu-highlight` with default colors
#
# Custom themes can produce a lot more ansi color codes and make the output
# exceed discord's character limits
def nu-highlight-default [] {
  let input = $in
  $env.config.color_config = {}
  $input | nu-highlight
}

# Copy the current commandline, add syntax highlighting, wrap it in a
# markdown code block, copy that to the system clipboard.
#
# Perfect for sharing code snippets on Discord.
def "nu-keybind commandline-copy" []: nothing -> nothing {
  commandline
  | nu-highlight-default
  | [
    "```ansi"
    $in
    "```"
  ]
  | str join (char nl)
  | clip copy --ansi
}

$env.config.keybindings ++= [
  {
    name: copy_color_commandline
    modifier: control
    keycode: char_y
    mode: [ emacs vi_insert vi_normal ]
    event: {
      send: executehostcommand
      cmd: 'nu-keybind commandline-copy'
    }
  }
]

$env.config.color_config.bool = {||
  if $in {
    "light_green_bold"
  } else {
    "light_red_bold"
  }
}

$env.config.color_config.string = {||
  if $in =~ "^(#|0x)[a-fA-F0-9]+$" {
    $in | str replace "0x" "#"
  } else {
    "white"
  }
}

$env.config.color_config.row_index = "light_yellow_bold"
$env.config.color_config.header = "light_yellow_bold"

# Clean nix generations and garbage collect
def nix-clean [] {
    home-manager expire-generations 0
    nix-collect-garbage -d
}

# Update nix channels and switch home-manager
def nix-update [] {
    nix-channel --update
    home-manager switch
}

# Sync git repos
def gitsync [] {
    let base_dir = ($env.HOME | path join "code")
    mut failures = []

    for dir in (ls $base_dir | where type == "dir") {
        let git_path = ($dir.name | path join ".git")
        if ($git_path | path exists) {
            let repo_name = ($dir.name | path basename)
            print $"Updating ($repo_name)"

            let result = (git -C $dir.name pull --ff-only | complete)

            if not ($result.stdout | is-empty) {
                print $result.stdout
            }
            if not ($result.stderr | is-empty) {
                print $result.stderr
            }

            if $result.exit_code != 0 {
                $failures ++= [$repo_name]
            }
        }
    }

    if ($failures | is-empty) {
        print "\nAll repositories updated successfully."
    } else {
        print "\n===== SUMMARY OF FAILURES ====="
        for repo in $failures {
            print $"($repo) needs manual intervention"
        }
    }
}

do --env {
  def prompt-header [
    --left-char: string
  ]: nothing -> string {
    let code = $env.LAST_EXIT_CODE

    let jj_workspace_root = try {
      jj workspace root err> $null_device
    } catch { ""
    }

    let hostname = if ($env.SSH_CONNECTION? | is-not-empty) {
      let hostname = try {
        hostname
      } catch {
        "remote"
      }

      $"(ansi light_green_bold)@($hostname)(ansi reset) "
    } else {
      ""
    }

    # https://github.com/nushell/nushell/issues/16205
    #
    # Case insensitive filesystems strike again!
    let pwd = pwd | path expand

    let body = if ($jj_workspace_root | is-not-empty) {
      let subpath = $pwd | path relative-to $jj_workspace_root
      let subpath = if ($subpath | is-not-empty) {
        $"(ansi magenta_bold) → (ansi reset)(ansi blue)($subpath)"
      }

      $"($hostname)(ansi light_yellow_bold)($jj_workspace_root | path basename)($subpath)(ansi reset)"
    } else {
      let pwd = if ($pwd | str starts-with $env.HOME) {
        "~" | path join ($pwd | path relative-to $env.HOME)
      } else {
        $pwd
      }

      $"($hostname)(ansi cyan)($pwd)(ansi reset)"
    }

    let command_duration = ($env.CMD_DURATION_MS | into int) * 1ms
    let command_duration = if $command_duration <= 2sec {
      ""
    } else {
      $"┫(ansi light_magenta_bold)($command_duration)(ansi light_yellow_bold)┣━"
    }

    let exit_code = if $code == 0 {
      ""
    } else {
      $"┫(ansi light_red_bold)($code)(ansi light_yellow_bold)┣━"
    }

    let middle = if $command_duration == "" and $exit_code == "" {
      "━"
    } else {
      ""
    }

    $"(ansi light_yellow_bold)($left_char)($exit_code)($middle)($command_duration)(ansi reset) ($body)(char newline)"
  }

  $env.PROMPT_INDICATOR = $"(ansi light_yellow_bold)┃(ansi reset) "
  $env.PROMPT_INDICATOR_VI_NORMAL = $env.PROMPT_INDICATOR
  $env.PROMPT_INDICATOR_VI_INSERT = $env.PROMPT_INDICATOR
  $env.PROMPT_MULTILINE_INDICATOR = $env.PROMPT_INDICATOR
  $env.PROMPT_COMMAND = {||
    prompt-header --left-char "┏"
  }
  $env.PROMPT_COMMAND_RIGHT = {||
    let jj_status = try {
      jj --quiet --color always --ignore-working-copy log --no-graph --revisions @ --template '
        separate(
          " ",
          if(empty, label("empty", "(empty)")),
          coalesce(
            surround(
              "\"",
              "\"",
              if(
                description.first_line().substr(0, 24).starts_with(description.first_line()),
                description.first_line().substr(0, 24),
                description.first_line().substr(0, 23) ++ "…"
              )
            ),
            label(if(empty, "empty"), description_placeholder)
          ),
          bookmarks.join(", "),
          change_id.shortest(),
          commit_id.shortest(),
          if(conflict, label("conflict", "(conflict)")),
          if(divergent, label("divergent prefix", "(divergent)")),
          if(hidden, label("hidden prefix", "(hidden)")),
        )
      ' err> $null_device
    } catch {
      ""
    }

    $jj_status
  }

  $env.TRANSIENT_PROMPT_INDICATOR = "  "
  $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = $env.TRANSIENT_PROMPT_INDICATOR
  $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = $env.TRANSIENT_PROMPT_INDICATOR
  $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = $env.TRANSIENT_PROMPT_INDICATOR
  $env.TRANSIENT_PROMPT_COMMAND = {||
    prompt-header --left-char "━"
  }
  $env.TRANSIENT_PROMPT_COMMAND_RIGHT = $env.PROMPT_COMMAND_RIGHT
}

let menus = [
  {
    name: completion_menu
    only_buffer_difference: false
    marker: $env.PROMPT_INDICATOR
    type: {
      layout: ide
      min_completion_width: 0
      max_completion_width: 150
      max_completion_height: 25
      padding: 0
      border: false
      cursor_offset: 0
      description_mode: "prefer_right"
      min_description_width: 0
      max_description_width: 50
      max_description_height: 10
      description_offset: 1
      correct_cursor_pos: true
    }
    style: {
      text: white
      selected_text: white_reverse
      description_text: yellow
      match_text: { attr: u }
      selected_match_text: { attr: ur }
    }
  }
]

def "nu-complete zoxide path" [context: string] {
    let parts = $context | str trim --left | split row " " | skip 1 | each { str lowercase }
    let completions = (
        ^zoxide query --list --exclude $env.PWD -- ...$parts
            | lines
            | each { |dir|
                if ($parts | length) <= 1 {
                    $dir
                } else {
                    let dir_lower = $dir | str lowercase
                    let rem_start = $parts | drop 1 | reduce --fold 0 { |part, rem_start|
                        ($dir_lower | str index-of --range $rem_start.. $part) + ($part | str length)
                    }
                    {
                        value: ($dir | str substring $rem_start..),
                        description: $dir
                    }
                }
            })
    {
        options: {
            sort: false,
            completion_algorithm: substring,
            case_sensitive: false,
        },
        completions: $completions,
    }
}
source $"($nu.cache-dir)/carapace.nu"
source ~/.zoxide.nu

