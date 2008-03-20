#!perl

use Test;

plan tests => 1;

eval qq{ require XTerm::Config };
ok($@, "", "Error loading XTerm::Config");

