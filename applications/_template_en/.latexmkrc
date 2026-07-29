# Thin stub — tooling only (hidden dotfile). Real config:
#   <repo>/common/latexmk/latexmkrc
# Safe to ignore while editing application .tex content.
use Cwd qw(abs_path);
use File::Basename qw(dirname);

my $dir = abs_path('.');
my $root;
while ($dir ne '/') {
  if (-f "$dir/common/latexmk/latexmkrc") {
    $root = $dir;
    last;
  }
  my $parent = dirname($dir);
  last if $parent eq $dir;
  $dir = $parent;
}

die "latexmk stub: could not find common/latexmk/latexmkrc from " . abs_path('.') . "\n"
  unless defined $root;

my $shared = "$root/common/latexmk/latexmkrc";
unless (my $ret = do $shared) {
  die "latexmk stub: failed to load $shared: $@" if $@;
  die "latexmk stub: failed to load $shared: $!" unless defined $ret;
}
