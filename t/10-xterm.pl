#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: 10-xterm.pl,v 1.2 2008/09/18 20:48:40 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 2008 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: slaven@rezic.de
# WWW:  http://www.rezic.de/eserte/
#

use FindBin;
use blib "$FindBin::RealBin/..";
use XTerm::Conf qw(xterm_conf xterm_conf_string);
use Data::Dumper qw(Dumper);
use Test::More qw(no_plan);

sub S () { select undef, undef, undef, 0.4 }

my $file = shift;

print STDERR "Some text for the xterm...\n";
eval {
    # This test has to be the first one, right after the print above!
    is(xterm_conf_string(-report => 'cursorpos'), "2 1\n", "cursor position");
    
    xterm_conf(-title => "Title changed");
    S;
    is(xterm_conf_string(-report => 'title'), "Title changed\n", "report of title");

    xterm_conf(-iconname => "Iconname changed");
    S;
    is(xterm_conf_string(-report => 'iconname'), "Iconname changed\n", "report of iconname");
    
    xterm_conf(-fg => 'blue', -bg => 'white',
	       -title => "Foreground and background colors changed",
	      );
    S;
    xterm_conf('-reverse',
	       -title => "Reversed video");
    S;
## Strange: the -geometry option works like a toogle on my
## system (xorg 6.9): first time the window gets tiny, the next time
## it's the requested geometry.
#     xterm_conf(-geometry => "640x400",
#  	       -title => "Changed geometry (top/left)");
#     S;
#      xterm_conf(-geometry => "80cx25c+10+10",
#  	       -title => "Changed geometry (character size)");
#      S;
    xterm_conf('-lower',
	       -title => "Lowered");
    S;
    xterm_conf('-raise',
	       -title => "Raised");
    S;
    xterm_conf('-iconify',
	       -title => "Iconify");
    S;
    xterm_conf('-deiconify',
	       -title => "Deiconified");
    S;
};
my $err = $@;

open FH, "> $file"
    or die "Can't write to $file: $!";
if ($err) {
    print FH "error: $err\n";
} elsif (!grep { $_ } Test::More->builder->summary) {
    print FH "error: tests failed: " . Dumper(Test::More->builder->details) . "\n";
} else {
    print FH "success\n";
}
close FH
    or die $!;

__END__
