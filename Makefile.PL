use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojolicious::Plugin::MooseValidator',
  VERSION_FROM => 'lib/Mojolicious/Plugin/MooseValidator.pm',
  AUTHOR       => 'A Good Programmer <nospam@cpan.org>',
  PREREQ_PM    => {
      'Mojolicious' => '5.31',
      'Try::Tiny'   => '0'
  },
  test         => {TESTS => 't/*.t'}
);
