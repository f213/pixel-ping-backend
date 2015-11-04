#!/usr/bin/env perl

use strict;
use Test::More;
use Test::Mojo;
use JSON::XS qw /encode_json/;
use Carp;

use FindBin;
require "$FindBin::Bin/../backend.pl";


my $t = new Test::Mojo;


$t->get_ok('/')->status_is(200);

my %first = (
  firstkey => 5,
  secondkey => 2
);

my %second = (
  firstkey => 3,
  secondkey => 1
);

$t->post_ok('/stats.json' => form => {json => encode_json(\%first)})->status_is(200);

my @res = Model::Stats->select('where key=?', 'firstkey');
my $firstKeyCount = $res[0]->count;
is($firstKeyCount, 5);
done_testing();