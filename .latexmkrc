#!/usr/bin/env perl
###############################################################################
# Universal LaTeXmk RC  ·  robust path handling + color/file logging
###############################################################################
use strict;
use warnings;
use Cwd            qw(abs_path getcwd);
use File::Basename qw(basename dirname);
use File::Path     qw(make_path);

no warnings 'redefine';  # silence harmless dup-subs

###############################################################################
# Globals required by 'use strict'
###############################################################################
our ($out_dir, $tmpdir, $deps_out, $post_latex_hook, $failure_hook);
our @default_files;  # <-- fixed: ensure @default_files is declared

###############################################################################
# 0 ▪ Tiny logger  (color only when LATEXMK_DEBUG=1 and tty)
###############################################################################
my $DEBUG = $ENV{LATEXMK_DEBUG} // 0;
my %CLR   = (RESET=>"\e[0m", INFO=>"\e[32m", WARN=>"\e[33m",
             ERROR=>"\e[31m", NOTE=>"\e[36m");

sub log_msg {
    my ($lvl,$msg)=@_;
    my $color = ($DEBUG && -t STDERR) ? ($CLR{$lvl}//'') : '';
    print STDERR "[${color}$lvl$CLR{RESET}] $msg\n" if $DEBUG;

    my $log_dir = '.cache/latex';
    make_path($log_dir) unless -d $log_dir;

    if ( open my $FH, '>>', "$log_dir/latex.log" ) {
        print $FH "[$lvl] $msg\n";
        close $FH;
    }
}

###############################################################################
# 1 ▪ Calculate directories
###############################################################################
# main tex given on CLI
my ($main_cli) = grep { $_ !~ /^-/ } @ARGV;
$main_cli   //= 'main.tex';
my $main_abs    = abs_path($main_cli);        # works even before -cd
my $project_dir = dirname($main_abs);         # docs/<subdir>
my $sub_name    = basename($project_dir);     # proposal, paper, etc.

# repo root = first parent with .git, else parent of docs/<subdir>
my $repo_root = $project_dir;
until (-d "$repo_root/.git" || $repo_root eq '/' ) {
    my $up = dirname($repo_root);
    last if $up eq $repo_root;    # reached root
    $repo_root = $up;
}
$repo_root = dirname(dirname($project_dir)) unless -d "$repo_root/.git";

$out_dir  = "$repo_root/.cache/latex/$sub_name/out";
$tmpdir   = "$repo_root/.cache/latex/$sub_name/tmp";
$deps_out = "$repo_root/.cache/latex/$sub_name/dependencies.list";
make_path($out_dir, $tmpdir);

log_msg(INFO => "Project    : $sub_name");
log_msg(INFO => "Main .tex  : $main_abs");
log_msg(INFO => "Out dir    : $out_dir");

###############################################################################
# 2 ▪ Resource env-vars
###############################################################################
$ENV{PROJECT_ROOT} = $project_dir;
$ENV{TEX_RESOURCES}= "$project_dir/resources";
$ENV{FIGURES_DIR}  = "$project_dir/figures";
$ENV{TEX_STYLE}    = "$ENV{TEX_RESOURCES}/style";
$ENV{LUA_SCRIPTS}  = "$ENV{TEX_RESOURCES}/scripts";

sub ensure_path {
    my ($var,$dir)=@_; return unless -d $dir;
    my $sep=$^O=~/Win32/?';':':';
    my @p=split/$sep/,$ENV{$var}//''; push @p,$dir unless grep{$_ eq $dir}@p;
    $ENV{$var}=join $sep,@p;
}
ensure_path('TEXINPUTS', "$ENV{TEX_STYLE}//");
ensure_path('TEXINPUTS', "$ENV{LUA_SCRIPTS}//");
ensure_path('TEXINPUTS', './texmf//');

@default_files = ($main_abs);  # <-- now properly declared

###############################################################################
# 3 ▪ Engine & compile options
###############################################################################
sub set_tex_cmds {
    my($o)=@_;
    $pdflatex = "pdflatex $o";
    $lualatex = "lualatex $o";
    $xelatex  = "xelatex  $o";
}

$pdf_mode = grep /^-lualatex/, @ARGV ? 4 : 5;  # 4 = LuaLaTeX, 5 = XeLaTeX

my $COMMON = join ' ',
  "-jobname=%R",
  "-output-directory=$out_dir",
  qw(-interaction=nonstopmode -file-line-error -synctex=1 -shell-escape
     -recorder -8bit);

# ✅ Let latexmk insert the correct input path
set_tex_cmds("$COMMON %O %S");

# 🔥 Remove this (it's redundant and overrides your engines)
# $latex = 'pdflatex %O %S';

$max_repeat   = 20;
$preview_mode = 1;
$silent       = 1;

###############################################################################
# 4 ▪ Bibliography
###############################################################################
$bibtex_use = 2;
$biber = "biber --output_directory=$out_dir --validate-datamodel %O %S";

###############################################################################
# 5 ▪ Smart PDF viewer
###############################################################################
sub _cmd_exists { ( `which $_[0] 2>/dev/null` ) ? 1 : 0 }
sub detect_pdf_viewer {
    if ($ENV{TERM_PROGRAM}//'' eq 'vscode') {
        return _cmd_exists('code') ? 'code -r %S' : '';
    }
    if ($ENV{WSL_DISTRO_NAME}) {
        for ('wslview %S','explorer.exe %S','cmd.exe /C start "" "%S"'){
            (my$p=$_)=~s/ .*$//; return $_ if _cmd_exists($p);
        }
    }
    return 'open %S'       if $^O=~/darwin/ && _cmd_exists('open');
    return 'start "" %S'   if $^O=~/Win32/;
    for ('zathura %S','okular %S','evince %S','mupdf %S','xdg-open %S'){
        (my$p=$_)=~s/ .*$//; return $_ if _cmd_exists($p);
    }
    return '';
}
$pdf_previewer = detect_pdf_viewer();

###############################################################################
# 6 ▪ Hooks
###############################################################################
$post_latex_hook = sub { log_msg(NOTE  => "LaTeX pass complete"); };
$failure_hook    = sub { log_msg(ERROR => "Build failed"); };

# Optional: override texmfvar/config for isolation
$ENV{TEXMFVAR}    = "$tmpdir/texmf-var";
$ENV{TEXMFCONFIG} = "$tmpdir/texmf-config";
