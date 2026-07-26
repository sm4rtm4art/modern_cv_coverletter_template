# latexmk configuration for modern_cv templates
# Auxiliaries → ./build/ ; PDF + synctex.gz stay next to the .tex file.
#
# Requires latexmk ≥ 4.70 ($emulate_aux). XeLaTeX has no native -aux-directory.

$pdf_mode = 5;                 # xelatex → pdf
$emulate_aux = 1;
$aux_dir = 'build';
# $out_dir left unset → PDF and .synctex.gz remain in the source directory

$xelatex = 'xelatex -synctex=1 -interaction=nonstopmode %O %S';

# Two passes are usually enough for lastpage / page refs; latexmk decides.
$max_repeat = 5;

# Create aux dir if missing (latexmk normally does this; belt-and-suspenders).
system('mkdir', '-p', $aux_dir) if $aux_dir;
