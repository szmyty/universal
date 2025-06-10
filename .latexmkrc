#!/usr/bin/env perl
###############################################################################
# Universal LaTeXmk RC – project-relative, cache at project root
# Author : Alan Szmyt (public domain / MIT)
###############################################################################
use strict;
use warnings;
use Cwd    qw(abs_path getcwd);
use File::Basename qw(dirname);

# ---------- globals required under 'use strict' -----------------------------
our ($deps_out, $out_dir, $aux_dir, $tmpdir);

# ---------- engine & compile options ---------------------------------------
$pdf_mode = 5;                                # XeLaTeX default
$pdf_mode = 4 if grep { /-lualatex/ } @ARGV;  # CLI override

my $COMMON = join ' ',
  qw(-interaction=nonstopmode -file-line-error -synctex=1 -shell-escape
     -recorder -8bit);
set_tex_cmds("$COMMON %O %S");

$warnings_as_errors       = 0;
$show_time                = 0;
$max_repeat               = 20;
$always_view_file_via_temporary = 0;
$preview_mode             = 1;
$emulate_aux              = 1;
$silent                   = 1;
$silence_logfile_warnings = 1;
$ENV{max_print_line}      = 9999;
$ENV{TZ}                  = 'America/New_York';

# ---------- project-relative roots -----------------------------------------
# latexmk has already chdir’d because of -cd (if supplied), so '.' *is* project root
$ENV{PROJECT_ROOT} //= abs_path('.');
$ENV{TEX_RESOURCES}     = "$ENV{PROJECT_ROOT}/resources";
$ENV{FIGURES_DIR}       = "$ENV{PROJECT_ROOT}/figures";

$ENV{TEX_STYLE}   = "$ENV{TEX_RESOURCES}/style";
$ENV{LUA_SCRIPTS} = "$ENV{TEX_RESOURCES}/scripts";
ensure_path('TEXINPUTS', "$ENV{TEX_STYLE}//");
ensure_path('TEXINPUTS', "$ENV{LUA_SCRIPTS}//");
ensure_path('TEXINPUTS', './texmf//');

# main entry point & defaults
$ENV{MAIN_TEX_FILE} ||= "$ENV{PROJECT_ROOT}/main.tex";
@default_files        = ($ENV{MAIN_TEX_FILE});

# ---------- build/cache directories (stay at project root) -----------------
$out_dir  = "$ENV{PROJECT_ROOT}/.cache/latex/out";
$aux_dir  = "$out_dir/aux";
$tmpdir   = "$ENV{PROJECT_ROOT}/.cache/latex/tmp";
$deps_out = "$ENV{PROJECT_ROOT}/.cache/latex/dependencies.list";

# ---------- bibliography ----------------------------------------------------
$bibtex_use = 2;
$biber      = 'biber --validate-datamodel %O %S';

# ---------- files eligible for 'clean' --------------------------------------
push @generated_exts, qw(
  acn acr alg glg glo gls ist nav snm synctex.gz fdb_latexmk
);

# ---------- smart PDF previewer -------------------------------------------
sub _cmd_exists {
    my ($cmd) = @_;
    return ( `which $cmd 2>/dev/null` ) ? 1 : 0;
}

sub detect_pdf_viewer {
    my @candidates;

    # ---- VS Code terminal (local, WSL, or Dev-Container) -------------------
    if ($ENV{TERM_PROGRAM} && $ENV{TERM_PROGRAM} eq 'vscode') {
        return _cmd_exists('code')
          ? 'code -r %S'        # reuse window, let VS Code render PDF tab
          : '';                 # extension (LaTeX-Workshop) will auto-refresh
    }

    # ---- Native Windows-Subsystem-for-Linux shell --------------------------
    if ($ENV{WSL_DISTRO_NAME}) {
        @candidates = (
          'wslview %S',                     # opens with Windows default
          'explorer.exe %S',
          'cmd.exe /C start "" "%S"'
        );
    }
    # ---- macOS -------------------------------------------------------------
    elsif ($^O =~ /darwin/) {
        @candidates = ('open %S');
    }
    # ---- Native Windows perl ----------------------------------------------
    elsif ($^O =~ /Win32/) {
        @candidates = ('start "" %S');
    }
    # ---- Standard desktop Linux/BSD ---------------------------------------
    else {
        @candidates = (
          'zathura %S', 'okular %S', 'evince %S',
          'mupdf %S',   'xdg-open %S',
        );
    }

    for my $cmd (@candidates) {
        (my $probe = $cmd) =~ s/ .*$//;  $probe =~ s/^"//;   # first word
        return $cmd if _cmd_exists($probe);
    }
    return '';                      # headless CI: no viewer
}

$pdf_previewer = detect_pdf_viewer();
