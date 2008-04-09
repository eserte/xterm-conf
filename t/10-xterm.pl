#!/usr/bin/perl -w
# -*- perl -*-

#
# $Id: 10-xterm.pl,v 1.1 2008/04/09 18:58:26 eserte Exp $
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
use XTerm::Conf;

sub S () { select undef, undef, undef, 0.4 }

my $file = shift;

print STDERR "Some text for the xterm...\n";
eval {
    xterm_conf(-title => "Title changed");
    S;
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
} else {
    print FH "success\n";
}
close FH
    or die $!;

__END__
