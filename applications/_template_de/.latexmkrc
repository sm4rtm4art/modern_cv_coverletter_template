# latexmk configuration for modern_cv templates / applications
# Auxiliaries → ./build/ ; PDF + synctex.gz stay next to the .tex file.
#
# Requires latexmk ≥ 4.70 ($emulate_aux). XeLaTeX has no native -aux-directory.
#
# TEXINPUTS: walk up to the repo root (directory containing common/cls) so
# \documentclass{main_cv} and module \input work at any depth under applications/.

use Cwd qw(abs_path);
use File::Basename qw(dirname);

# TeXStudio's default Latexmk command often includes -pdf, which overrides
# $pdf_mode = 5 and runs pdflatex (fontspec then aborts). Force XeLaTeX.
BEGIN {
  @ARGV = map { ($_ eq '-pdf' || $_ eq '--pdf') ? '-pdfxe' : $_ } @ARGV;
}

sub find_repo_root {
  my $dir = abs_path('.');
  while ($dir ne '/') {
    return $dir if -d "$dir/common/cls";
    my $parent = dirname($dir);
    last if $parent eq $dir;
    $dir = $parent;
  }
  die "modern_cv: could not find repo root (common/cls) from " . abs_path('.') . "\n";
}

my $repo_root = find_repo_root();
ensure_path('TEXINPUTS', "$repo_root/common/cls/cv//");
ensure_path('TEXINPUTS', "$repo_root/common/cls/cover_letter//");
ensure_path('TEXINPUTS', "$repo_root/common/cls/shared_cls//");
ensure_path('TEXINPUTS', "$repo_root/images//");

$pdf_mode = 5;                 # xelatex → pdf
$emulate_aux = 1;
$aux_dir = 'build';
# $out_dir left unset → PDF and .synctex.gz remain in the source directory

$xelatex = 'xelatex -synctex=1 -interaction=nonstopmode %O %S';

# Two passes are usually enough for lastpage / page refs; latexmk decides.
$max_repeat = 5;

# Create aux dir if missing (latexmk normally does this; belt-and-suspenders).
system('mkdir', '-p', $aux_dir) if $aux_dir;
