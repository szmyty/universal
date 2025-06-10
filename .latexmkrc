#!/usr/bin/env perl
################################################################################
# Universal LaTeXmk configuration (.latexmkrc)
# ------------------------------------------------------------------------------
# Author....: Alan Szmyt
# Purpose...: Provide sane defaults for automated LaTeX builds while remaining
#             fully tweakable per project.
# License...: MIT — distribute & modify freely.
# Docs......: https://ctan.org/pkg/latexmk
################################################################################

# -----------------------------------------------------------------------------#
# Perl hygiene                                                                 #
# -----------------------------------------------------------------------------#
use strict;
use warnings;

# -----------------------------------------------------------------------------#
# Helper subs                                                                  #
# -----------------------------------------------------------------------------#
# Cross-platform path separator
my $PATH_SEP = $^O =~ /Win32/ ? ';' : ':';

# Ensure a directory appears exactly once in a path-style env-var
sub ensure_path {
    my ($var, $dir) = @_;
    return unless $dir && -d $dir;
    my @parts = split /$PATH_SEP/, ($ENV{$var} // '');
    push @parts, $dir unless grep { $_ eq $dir } @parts;
    $ENV{$var} = join $PATH_SEP, @parts;
}

# Apply an option bundle to all engines
sub set_tex_cmds {
    my ($opts) = @_;
    $pdflatex = "pdflatex $opts";
    $lualatex = "lualatex $opts";
    $xelatex  = "xelatex  $opts";
}

# -----------------------------------------------------------------------------#
# Engine & compile options                                                     #
# -----------------------------------------------------------------------------#
# PDF modes: 1=pdfLaTeX  4=LuaLaTeX  5=XeLaTeX
$pdf_mode = 5;                                # default XeLaTeX

$warnings_as_errors          = 0;
$show_time                   = 0;
$max_repeat                  = 20;
$always_view_file_via_temporary = 0;
$preview_mode                = 1;
$emulate_aux                 = 1;
$silent                      = 1;
$silence_logfile_warnings    = 1;

# Allow CLI override: `latexmk -lualatex`
if (grep { /-lualatex/ } @ARGV) { $pdf_mode = 4 }
elsif (grep { /-xelatex/ } @ARGV) { $pdf_mode = 5 }

my $COMMON_FLAGS = join ' ', qw(
  -interaction=nonstopmode
  -file-line-error
  -synctex=1
  -shell-escape
  -recorder
  -8bit
);
set_tex_cmds("$COMMON_FLAGS %O %S");

# -----------------------------------------------------------------------------#
# Environment variables & project layout                                       #
# -----------------------------------------------------------------------------#
$ENV{max_print_line} = 9999;
$ENV{TZ}             = 'America/New_York';

$ENV{PROJECT_ROOT}     //= "$ENV{PWD}/../..";
$ENV{TEX_PROJECT_ROOT} //= "$ENV{PROJECT_ROOT}/docs/resume";

$ENV{MAIN_TEX_FILE} = "$ENV{TEX_PROJECT_ROOT}/main.tex";
$ENV{TEX_RESOURCES} = "$ENV{TEX_PROJECT_ROOT}/resources";
@default_files      = ($ENV{MAIN_TEX_FILE});

$ENV{TEX_STYLE}   = "$ENV{TEX_RESOURCES}/style";
$ENV{LUA_SCRIPTS} = "$ENV{TEX_RESOURCES}/scripts";
ensure_path('TEXINPUTS', "$ENV{TEX_STYLE}//");
ensure_path('TEXINPUTS', "$ENV{LUA_SCRIPTS}//");
ensure_path('TEXINPUTS', './texmf//');

# -----------------------------------------------------------------------------#
# Output directories                                                           #
# -----------------------------------------------------------------------------#
$out_dir  = "$ENV{TEX_PROJECT_ROOT}/.cache/latex/out";
$aux_dir  = "$out_dir/aux";
$tmpdir   = "$ENV{TEX_PROJECT_ROOT}/.cache/latex/tmp";
$deps_out = "$ENV{TEX_PROJECT_ROOT}/.cache/latex/dependencies.list";

# Route engines to build dir
for ($pdflatex, $lualatex, $xelatex) {
    s/%O/%O -output-directory=$out_dir/;
}

# -----------------------------------------------------------------------------#
# Bibliography                                                                 #
# -----------------------------------------------------------------------------#
$bibtex_use = 2;
$biber      = 'biber --validate-datamodel %O %S';

# -----------------------------------------------------------------------------#
# Glossaries / index support (harmless if unused)                              #
# -----------------------------------------------------------------------------#
add_cus_dep('glo', 'gls', 0, 'makeglossary');
sub makeglossary { system 'makeglossaries', $_[0] }

$makeindex = 'true';   # skip unless needed

# -----------------------------------------------------------------------------#
# Generated-file housekeeping                                                  #
# -----------------------------------------------------------------------------#
push @generated_exts, qw(
  acn acr alg glg glo gls ist
  nav snm synctex.gz fdb_latexmk
);

# -----------------------------------------------------------------------------#
# Viewers                                                                      #
# -----------------------------------------------------------------------------#
$view = 'pdf';
$pdf_previewer //= do {
    $^O =~ /darwin/  ? 'open %S.pdf'   :
    $^O =~ /Win32/   ? 'start "" %S.pdf' :
                       'xdg-open %S.pdf';
};
$pdf_previewer = 'mupdf %S.pdf' if `which mupdf 2>/dev/null` ne '';

# -----------------------------------------------------------------------------#
# Convenience make rules (use with `latexmk -use-make`)                        #
# -----------------------------------------------------------------------------#
add_make_rule('lint',  '', [], sub { system 'chktex', @default_files });
add_make_rule('clean', '', [], sub { unlink $_ for map { glob "*.$_" } @generated_exts });
