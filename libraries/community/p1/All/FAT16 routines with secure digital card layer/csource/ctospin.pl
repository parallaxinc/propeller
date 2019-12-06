my $ignore = 0 ;
my $nocon = 0 ;
my @dat = () ;
while (<>) {
   next if /^#/ ; # skip preprocessor stuff
   s,//,', ;
   s/ ;// ;
   if (/^const int (.*)$/) {
      print "con\n" if !$nocon++ ;
      print "   $1\n" ;
   } elsif (m,^',) {
      s,'{,{{, ;
      s,'},}}, ;
      print ;
   } else {
      $ignore = 1 if /BEGIN IGNORE/ ;
      last ;
   }
}
print <<EOF ;
'
'   The object that provides the block-level access.
'
obj
   sdspi: "safe_spi"
   'sdspi: "mb_rawb_spi"
var
EOF
while (<>) {
   if (/BEGIN IGNORE/) {
      $ignore = 1 ;
      next ;
   } elsif (/END IGNORE/) {
      $ignore = 0 ;
      next ;
   }
   next if $ignore ;
   s,//,', ;
   s/ ;// ;
   if (/^shared int ([^']+)('?.*)$/) {
      push @dat, "$1 long 0 $2\n" ;
   } elsif (/^shared char ([^']+)\[([^]]+)\]('?.*)$/) {
      push @dat, "$1 byte 0[$2] $3\n" ;
   } elsif (/^int (.*)$/) {
      print "   long $1\n" ;
   } elsif (/^char (.*)$/) {
      print "   byte $1\n" ;
   } elsif (m,^',) {
      s,'{,{{, ;
      s,'},}}, ;
      print ;
   } else {
 print STDERR "Eating line [$_]\n" ;
      last ;
   }
}
sub fixdec {
   my ($s, $vars) = @_ ;
   my $fd = '' ;
   if ($s ne '') {
      $s =~ s/\*// ;
      my @f = split ',', $s ;
      $fd = '(' . (join ', ', map { (split " ", $_)[1] } @f) . ')' ;
   }
   if ($vars ne '') {
      $vars =~ s/r=0/r/g ;
      $vars =~ s/\s*int //g ;
      $vars =~ s/\s*char //g ;
      $vars =~ s/\*//g ;
      $vars =~ s/\s*;\s*/, /g ;
      $vars =~ s/,\s*$// ;
      if ($vars ne '') {
         $fd .= " | $vars" ;
      }
   }
   $fd =~ s/\| r,/: r |/ ;
   $fd =~ s/\| r\s*$,/: r/ ;
   return $fd ;
}
sub fixfor {
   my $s = shift ;
   $s =~ /^(\s*)for\s*\((.*);(.*);(.*)\)\s*{?\s*$/ or die "Bad for $_\n" ;
   my $indent = $1 ;
   my $init = $2 ;
   my $test = $3 ;
   my $inc = $4 ;
   $init =~ /^\s*(.*)\s*=\s*(.*)\s*$/ ;
   my $var = $1 ;
   my $ival = $2 ;
   my $incval = '1' ;
   if ($inc !~ /\+\+/) {
      $inc =~ /\+=\s*(.*)/ ;
      $incval = $1 ;
      die "Bad for" if !defined($incval) ;
   }
   $test =~ /.*<\s*(.*)/ ;
   my $limit = $1 ;
   die "Bad for" if !defined($limit) ;
   if ($limit =~ /^[0-9]*$/ && $incval =~ /^[0-9]*$/) {
      $limit = ($limit - $incval) . '' ;
   } elsif ($limit =~ /^[0-9A-Z]*$/ && $incval =~ /^[0-9A-Z]*$/) {
      $limit = "constant($limit - $incval)" ;
   } else {
      $limit = "$limit - $incval" ;
   }
   my $stat = "${indent}repeat $var from $ival to $limit" ;
   if ($incval ne '1') {
      $stat .= " step $incval" ;
   }
   return "$stat\n" ;
}
while (<>) {
   if (/BEGIN IGNORE/) {
      $ignore = 1 ;
      next ;
   }
   if (/END IGNORE/) {
      $ignore = 0 ;
      next ;
   }
   next if $ignore ;
   next if /printf/ ;
   next if /^\s*}\s*$/ ;
   s/\/\/SPIN\s*//g ; # uncomment spin-only stuff
   if (/^(pri\s+)?(\S+) (\S+)\((.*)\)\s+{\s+(.*)/) {
      $pref = $1 ;
      $pref = "pub " if $pref eq '' ;
      $newdec = fixdec($4, $5) ;
      $procname = $3 ;
      $procname =~ s/\*//g ;
      print "$pref$procname$newdec\n" ;
   } else {
      if (/^\s*for\s+/) {
         $_ = fixfor($_) ;
      }
      if (m,^//,) {
         s,//{,{{, ;
         s,//},}}, ;
      } else {
         s/[;{}]\s*//g ;
      }
      s/ = / := / ;
      s/<=/=</g ;
      s/>=/=>/g ;
      s/!=/<>/g ;
      s/\|\|/or/g ;
      s/\&\&/and/g ;
      s/\(\)//g ;
      s/\s+$// ;
      s/'/"/g ;
      s,//,',g ;
      s/0x/\$/g ;
      s/while/repeat while/ ;
      s/repeat while \(1\)/repeat/ ;
      s/>=>/>>=/g ;
      s/<=</<<=/g ;
      s/\(char\)//g ;
      s/~/!/g ;
      s/else if/elseif/g ;
      s/break/quit/g ;
      s/memset/bytefill/g ;
      s/memcpy/bytemove/g ;
      s/strlen/strsize/g ;
      s/eight//g ;
      s/asint//g ;
      s/min\(([^,]+)\s*,\s*([^,]+)\)/($1) <\# ($2)/ ;
      s/max\(([^,]+)\s*,\s*([^,]+)\)/($1) >\# ($2)/ ;
      s/return r\b/' return r (default return)/ ;
#
#   Fix all the array shenanigans.
#
      s/\bbuf\b/\@buf/g ;
      s/\bbuf2\b/\@buf2/g ;
      s/\bpadname\b/\@padname/g ;
#
#   Fix array dereferences.
#
      s/([\@a-zA-Z0-9@_-]+(\+\+)?)\[/byte\[$1\]\[/g ;
#
#   Now, fix any byte[@xxx] back to just xxx.
#
      s/byte\[\@([a-zA-Z0-9@_-]+)\]/$1/g ;
#
#   Minor optimization:  eliminate [0] throughout
#
      s/\[0\]//g ;
#
      s/error\((".*")\)/abort(string($1))/g ;
      s/spinabort/abort/g ;
      s/\breadblock\b/sdspi.readblock/g ;
      s/\bwriteblock\b/sdspi.writeblock/g ;
      print $_, "\n" ;
   }
}
if (@dat) {
   print "DAT\n" ;
   print for @dat ;
}
