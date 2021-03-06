use strict;
use warnings;

use Archive::Tar;
use Test::More 0.88;
use Test::DZil;

my $tzil = Builder->from_config(
    { dist_root => 'corpus/dist/DZT' },
    { add_files => {
        'source/zero'     => '',
        'source/dist.ini' => simple_ini({
            name => 'DZT',
        }, 'GatherDir', 'MakeMaker', 'FakeRelease')
      },
    },
);

$tzil->release;

my $basename = $tzil->dist_basename;
my $tarball  = $tzil->archive_filename;

$tarball = $tzil->built_in->parent->subdir('source')->file($tarball);
$tarball = Archive::Tar->new($tarball->stringify);

my $makefile_pl = File::Spec::Unix->catfile($basename, 'Makefile.PL');

ok(
  $tarball->contains_file( $makefile_pl ),
  "Makefile.PL is located at the root of a Test-built archive",
);

my ($file) = $tarball->get_files( $makefile_pl );

like($file->get_content, qr{ExtUtils}, "the file contains the real content");

my $zero_byte = File::Spec::Unix->catfile($basename, 'zero');

my ($zero_byte_file) = $tarball->get_files( $zero_byte );

is($zero_byte_file->get_content, "", "zero byte file is empty");

done_testing;
