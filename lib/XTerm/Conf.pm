# -*- perl -*-

#
# $Id: Conf.pm,v 1.17 2009/07/14 05:27:13 eserte Exp $
# Author: Slaven Rezic
#
# Copyright (C) 2006,2008,2009 Slaven Rezic. All rights reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
#
# Mail: srezic@cpan.org
# WWW:  http://www.rezic.de/eserte/
#

package XTerm::Conf;

use 5.006; # qr, autovivified filehandles

# Plethora of xterm control sequences:
# http://rtfm.etla.org/xterm/ctlseq.html

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

$VERSION = '0.07';

require Exporter;
@ISA = qw(Exporter);
@EXPORT    = qw(xterm_conf);
@EXPORT_OK = qw(xterm_conf_string);

use Getopt::Long 2.24; # OO interface

use constant BEL => "";
use constant ESC => "";

use constant IND   => ESC . "D"; # Index
use constant IND_8   => chr 0x84;
use constant NEL   => ESC . "E"; # Next Line
use constant NEL_8   => chr 0x85;
use constant HTS   => ESC . "H"; # Tab Set
use constant HTS_8   => chr 0x88;
use constant RI    => ESC . "M"; # Reverse Index
use constant RI_8    => chr 0x8d;
use constant SS2   => ESC . "N"; # Single Shift Select of G2 Character Set: affects next character only
use constant SS2_8   => chr 0x8e;
use constant SS3   => ESC . "O"; # Single Shift Select of G3 Character Set: affects next character only
use constant SS3_8   => chr 0x8f;
use constant DCS   => ESC . "P"; # Device Control String
use constant DCS_8   => chr 0x90;
use constant SPA   => ESC . "V"; # Start of Guarded Area
use constant SPA_8   => chr 0x96;
use constant EPA   => ESC . "W"; # End of Guarded Area
use constant EPA_8   => chr 0x97;
use constant SOS   => ESC . "X"; # Start of String
use constant SOS_8   => chr 0x98;
use constant DECID => ESC . "Z"; # Return Terminal ID Obsolete form of CSI c (DA).
use constant DECID_8 => chr 0x9a;
use constant CSI   => ESC . "["; # Control Sequence Introducer
use constant CSI_8   => chr 0x9b;
use constant ST    => ESC . "\\"; # String Terminator
use constant ST_8    => chr 0x9c;
use constant OSC   => ESC . "]";
use constant OSC_8   => chr 0x9d;
use constant PM    => ESC . "^"; # Privacy Message
use constant PM_8    => chr 0x9e;
use constant APC   => ESC . "_"; # Application Program Command
use constant APC_8   => chr 0x9f;

my %o;
my $need_reset_terminal;

sub xterm_conf_string {
    local @ARGV = @_;

    %o = ();
    $need_reset_terminal++;

    my $p = Getopt::Long::Parser->new;
    $p->configure('no_ignore_case');
    $p->getoptions(\%o,
	       "iconname|n=s",
	       "title|T=s",
	       "fg|foreground=s",
	       "bg|background=s",
	       "textcursor|cr=s",
	       "mousefg|mouseforeground|ms=s",
	       "mousebg|mousebackground=s",
	       "tekfg|tekforeground=s",
	       "tekbg|tekbackground=s",
	       "highlightcolor|hc=s",
	       "bell",
	       "cs=s",
	       "fullreset",
	       "softreset",
	       "smoothscroll!", # no visual effect
	       "reverse|reversevideo!",
	       "origin!",
	       "wraparound!",
	       "autorepeat!",
	       "formfeed!",
	       "showcursor!",
	       "showscrollbar!", # rxvt
	       "tektronix!",
	       "marginbell!",
	       "reversewraparound!",
	       "backsendsdelete!",
	       "bottomscrolltty!", # rxvt
	       "bottomscrollkey!", # rxvt
	       "metasendsesc|metasendsescape!",
	       "scrollregion=s",
	       "deiconify",
	       "iconify",
	       "geometry=s",
	       "raise",
	       "lower",
	       "refresh|x11refresh",
	       "maximize",
	       "unmaximize",
	       "xproperty|x11property=s",
	       "font=s",
	       "nextfont",
	       "prevfont",
	       "report=s",
	       "debugreport",
	       "resize=i",
	      )
	or _usage();
    die _usage() if (@ARGV);

    my $rv = "";

    $rv .= BEL if $o{bell};

 CS_SWITCH: {
	if (defined $o{cs}) {
	    $rv .= (ESC . '%G'), last if $o{cs} =~ m{^utf-?8$}i;
	    $rv .= (ESC . '%@'), last if $o{cs} =~ m{^(latin-?1|iso-?8859-?1)$}i;
	    warn "Unhandled -cs parameter $o{cs}\n";
	}
    }

    $rv .= ESC . "c" if $o{fullreset};

    {
	my %DECSET = qw(smoothscroll 4
			reverse 5
			origin 6
			wraparound 7
			autorepeat 8
			formfeed 18
			showcursor 25
			showscrollbar 30
			tektronix 38
			marginbell 44
			reversewraparound 45
			backsendsdelete 67
			bottomscrolltty 1010
			bottomscrollkey 1011
			metasendsesc 1036
		      );
	while(my($optname, $Pm) = each %DECSET) {
	    if (defined $o{$optname}) {
		my $onoff = $o{$optname} ? 'h' : 'l';
		$rv .= CSI . '?' . $Pm . $onoff;
	    }
	}
    }

    $rv .= CSI . '!p' if $o{softreset};

    if (defined $o{scrollregion}) {
	if ($o{scrollregion} eq '' || $o{scrollregion} eq 'default') {
	    $rv .= CSI . 'r';
	} else {
	    my($top,$bottom) = split /,/, $o{scrollregion};
	    for ($top, $bottom) {
		die "Not a number: $_\n" if !/^\d*$/;
	    }
	    $rv .=  CSI . $top . ";" . $bottom . "r";
	}
    }

    $rv .= CSI . "1t" if $o{deiconify};
    $rv .= CSI . "2t" if $o{iconify};

    if (defined $o{geometry}) {
	if (my($w,$h,$wc,$hc,$x,$y) = $o{geometry} =~ m{^(?:(\d+)x(\d+)|(\d+)cx(\d+)c)?(?:\+(\d+)\+(\d+))?$}) {
	    $rv .=  CSI."3;".$x.";".$y."t" if defined $x;
	    $rv .=  CSI."4;".$h.";".$w."t" if defined $h; # does not work?
	    $rv .=  CSI."8;".$hc.";".$wc."t" if defined $hc; # does not work?
	} else {
	    die "Cannot parse geometry string, must be width x height+x+y\n";
	}
    }

    $rv .= CSI . "5t" if $o{raise};
    $rv .= CSI . "6t" if $o{lower};
    $rv .= CSI . "7t" if $o{refresh};
    $rv .= CSI . "9;0t" if $o{unmaximize}; # does not work?
    $rv .= CSI . "9;1t" if $o{maximize}; # does not work?
    if ($o{resize}) {
	die "-resize parameter must be at least 24\n"
	    if $o{resize} < 24 || $o{resize} !~ /^\d+$/;
	$rv .= CSI . $o{resize} . 't';
    }

    $rv .= OSC .  "1;$o{iconname}" . BEL if defined $o{iconname};
    $rv .= OSC .  "2;$o{title}" . BEL if defined $o{title};
    $rv .= OSC .  "3;$o{xproperty}" . BEL if defined $o{xproperty};    
    $rv .= OSC . "10;$o{fg}" . BEL if defined $o{fg};
    $rv .= OSC . "11;$o{bg}" . BEL if defined $o{bg};
    $rv .= OSC . "12;$o{textcursor}" . BEL if defined $o{textcursor};
    $rv .= OSC . "13;$o{mousefg}" . BEL if defined $o{mousefg};
    $rv .= OSC . "14;$o{mousebg}" . BEL if defined $o{mousebg};
    $rv .= OSC . "15;$o{tekfg}" . BEL if defined $o{tekfg};
    $rv .= OSC . "16;$o{tekbg}" . BEL if defined $o{tekbg};
    $rv .= OSC . "17;$o{highlightcolor}" . BEL if defined $o{highlightcolor};
    $rv .= OSC . "50;#$o{font}" . BEL if defined $o{font};
    $rv .= OSC . "50;#-" . BEL if $o{prevfont};
    $rv .= OSC . "50;#+" . BEL if $o{nextfont};

    if ($o{report}) {
	if ($o{report} eq 'cgeometry') {
	    my($h,$w) = _report_cgeometry();
	    $rv .= $w."x".$h."\n";
	} else {
	    my $sub = "_report_" . $o{report};
	    no strict 'refs';
	    my(@args) = &$sub;
	    $rv .= join(" ", @args) . "\n";
	}
    }

    $rv;
}

sub xterm_conf {
    return if !$ENV{TERM};
    return if $ENV{TERM} !~ m{^xterm};
    my $rv = xterm_conf_string(@_);
    local $| = 1;
    print $rv;
}

sub _report ($$) {
    my($cmd, $rx) = @_;

    require Term::ReadKey;
    Term::ReadKey::ReadMode(5);

    require IO::Select;

    my $debug = $o{debugreport};

    open my $TTY, "+< /dev/tty" or die "Cannot open terminal /dev/tty: $!";
    syswrite $TTY, $cmd;

    my $sel = IO::Select->new;
    $sel->add($TTY);

    my $res = "";
    my @args;
    my $err;
    while() {
	my(@ready) = $sel->can_read(5);
	if (!@ready) {
	    $err = "Cannot report, maybe allowWindowOps is set to false?";
	    last;
	}
	sysread $TTY, my $ch, 1 or die "Cannot sysread: $!";
	print STDERR ord($ch)." " if $debug;
	$res .= $ch;
	last if (@args = $res =~ $rx);
    }

    Term::ReadKey::ReadMode(0);

    if ($err) {
	die "$err\n";
    }
    @args;
}

sub _report_status      { _report CSI.'5n', qr{0n} }
sub _report_cursorpos   { _report CSI.'6n', qr{(\d+);(\d+)R} }
sub _report_windowpos   { _report CSI.'13t', qr{;(\d+);(\d+)t} }
sub _report_geometry    { _report CSI.'14t', qr{;(\d+);(\d+)t} }
sub _report_cgeometry   { _report CSI.'18t', qr{;(\d+);(\d+)t} }
sub _report_cscreengeom { _report CSI.'19t', qr{;(\d+);(\d+)t} }
sub _report_iconname    { _report CSI.'20t', qr{L(.*?)(?:\Q@{[ST]}\E|\Q@{[ST_8]}\E)} }
sub _report_title       { _report CSI.'21t', qr{l(.*?)(?:\Q@{[ST]}\E|\Q@{[ST_8]}\E)} }

sub _usage {
    die <<EOF;
usage: $0 [-n|iconname string] [-T|title string] [-cr|textcursor color]
        [-fg|-foreground color] [-bg|-background color color]
        [-ms|mousefg|-mouseforeground color] [-mousebg|-mousebackground color]
        [-tekfg|-tekforeground color] [-tekbg|-tekbackground color]
        [-hc|highlightcolor color] [-bell] [-cs ...] [-fullreset] [-softreset]
	[-[no]smoothscroll] [-[no]reverse|reversevideo], [-[no]origin]
	[-[no]wraparound] [-[no]autorepeat] [-[no]formfeed] [-[no]showcursor]
        [-[no]showscrollbar] [-[no]tektronix] [-[no]marginbell]
	[-[no]reversewraparound] [-[no]backsendsdelete]
        [-[no]bottomscrolltty] [-[no]bottomscrollkey]
	[-[no]metasendsesc|metasendsescape] [-scrollregion ...]
	[-deiconify] [-iconify] [-geometry x11geom] [-raise] [-lower]
	[-refresh|x11refresh] [-maximize] [-unmaximize]
	[-xproperty|x11property ...] [-font ...] [-nextfont] [-prevfont]
	[-report ...] [-debugreport] [-resize ...]

EOF
}

END {
    Term::ReadKey::ReadMode(0)
	    if $need_reset_terminal && defined &Term::ReadKey::ReadMode;
}

return 1 if caller;

xterm_conf(@ARGV);

__END__

=head1 NAME

XTerm::Conf - change configuration of a running xterm

=head1 SYNOPSIS

    use XTerm::Conf;
    xterm_conf(-fg => "white", -bg => "black", -title => "Hello, world", ...);

=head1 DESCRIPTION

=head2 xterm_conf(I<options ...>)

The xterm_conf function (exported by default) checks first if the
current terminal looks like an xterm (by looking at the C<TERM>
environment variable) and prints the escape sequences for the
following options:

=over

=item -n string

=item -iconname string

Change name of the associated X11 icon.

=item -T string

=item -title string

Change xterm's title name.

=item -fg color

=item -foreground color

Change text color. You can use either X11 named colors or the
#rrggbb notation.

=item -bg color

=item -background color

Change background color

=item -cr ...

=item -textcursor ...

Change cursor color

=item -ms color

=item -mousefg color

=item -mouseforeground color

Change the foreground color of the mouse pointer.

=item -mousebg color

=item -mousebackground color

Change the background/border color of the mouse pointer.

=item -tekfg color

=item -tekforeground color

Change foreground color of Tek window.

=item -tekbg color

=item -tekbackground color

Change background color of Tek window.

=item -highlightcolor color

Change selection background color.

=item -bell

Ring the bell (either visual or audible)

=item -cs utf-8|iso-8859-1

Switch charset. Valid values are C<utf-8> and C<iso-8859-1>.

=item -fullreset

Perform a full reset.

=item -softreset

Perform a soft reset.

=item -[no]smoothscroll

Turn smooth scrolling on or off (which is probably the opposite of
jump scroll, see L<xterm(1)>).

=item -[no]reverse

=item -[no]reversevideo

Turn reverse video on or off.

=item -[no]origin

???

=item -[no]wraparound

???

=item -[no]autorepeat

Turn auto repeat on or off

=item -[no]formfeed

???

=item -[no]showcursor

Show or hide the cursor.

=item -[no]showscrollbar

rxvt only?

=item -[no]tektronix

Show the Tek window and switch to Tek mode (XXX -notektronix does not
seem to work).

=item -[no]marginbell

???

=item -[no]reversewraparound

???

=item -[no]backsendsdelete

???

=item -[no]bottomscrolltty

rxvt only?

=item -[no]bottomscrollkey

rxvt only?

=item -[no]metasendsesc

=item -[no]metasendsescape

???

=item -scrollregion ...

???

=item -deiconify

Deiconify an iconified xterm window.

=item -iconify

Iconify the xterm window.

=item -geometry geomtry

Change the geometry of the xterm window. The geometry is in the usual
X11 notation I<width>xI<height>+I<left>+I<top>. The numbers are in
pixels. The width and height may be suffixed with a C<c>, which means
that the number are interpreted as characters.

=item -raise

Raise the xterm window.

=item -lower

Lower the xterm window

=item -refresh

=item -x11refresh

Force a X11 refresh

=item -maximize

Maximize the xterm window

=item -unmaximize

Restore to the state before maximization.

=item -xproperty ...

=item -x11property ...

???

=item -font number

Change font. Number may be from 0 (default font) to 6 (usually the
largest font, but this could be changed using Xdefaults).

=item -nextfont

Use the next font in list.

=item -prevfont

Use the previous font in ilist.

=item -report what

Report to STDOUT:

=over

=item status

???

=item cursorpos

The cursor position (I<line column>).

=item windowpos

The XTerm window position (I<x y>).

=item geometry

The geometry of the window in pixels (I<width> I<height>).

=item cgeometry

The geometry of the window in characters (I<width>C<x>I<height>).

=item cscreengeom

???

=item iconname

The icon name.

=item title

The title name.

=back

=item -debugreport

???

=item -resize integer

???

=back

=head2 xterm_conf_string(I<options ...>)

xterm_conf_string just returns a string with the escape sequences for
the given options (same as in xterm_conf). No terminal check will be
performed here.

xterm_conf_string may be exported.

=head1 AUTHOR

Slaven ReziE<0x107>

=head1 SEE ALSO

L<xterm-conf>, L<xterm(1)>, L<Term::Title>.

=cut
