#!perl

use Test;

plan tests => 1;

eval qq{ require XTerm::Conf };
ok($@, "", "Error loading XTerm::Conf");

