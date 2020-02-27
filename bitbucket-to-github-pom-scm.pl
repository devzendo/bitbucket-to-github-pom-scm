#!/usr/bin/env perl
#
# Converts SCM block of a pom.xml from BitBucket Mercurial to Github Git.
#
# Matt Gumbley, Feb 2020
# matt.gumbley@gmail.com
# @mattgumbley
#
use warnings;
use strict;
no strict 'refs';

my $pom = 'pom.xml';
die "No $pom in the current directory\n" unless -f $pom;

# Read the entire pom.xml, find the scm block, and translate elements within it.

open (my $pfh, "<", $pom) or die "Can't open $pom: $!\n";
my $doc = (join('', (<$pfh>)));
close $pfh;
undef $/;
$doc =~ m/(\s*<scm>.*?<\/scm>\s*)/sm;
my ($prescm, $scmblock, $postscm) = ($`, $1, $');

die "There is no SCM block in this pom.xml\n" unless ($scmblock);

#print "initial scm block [$scmblock]";

# Convert from this:
#    <scm>
#        <url>https://bitbucket.org/foobarorg/reponame</url>
#        <connection>scm:hg:https://bitbucket.org/foobarorg/reponame</connection>
#        <developerConnection>scm:hg:https://bitbucket.org/foobarorg/reponame</developerConnection>
#        <tag>HEAD</tag>
#    </scm>
#
# To:
#
# <scm>
#    <connection>scm:git:https://github.com/foobarorg/reponame.git</connection>
#    <developerConnection>scm:git:git@github.com:foobarorg/reponame.git</developerConnection>
#    <url>https://github.com/foobarorg/reponame.git</url>
#    <tag>HEAD</tag>
#  </scm>

my ($url) = $scmblock =~ m/<url>\s*(\S*?)\s*<\/url>/sm;
my ($connection) = $scmblock =~ m/<connection>\s*(\S*?)\s*<\/connection>/sm;
my ($developerConnection) = $scmblock =~ m/<developerConnection>\s*(\S*?)\s*<\/developerConnection>/sm;

#print "url [$url]\n";
$url =~ s/bitbucket.org/github.com/;
$url .= '.git';

#print "connection [$connection]\n";
$connection =~ s-scm:hg:https://bitbucket.org-scm:git:https://github.com-;
$connection .= '.git';

#print "developerConnection [$developerConnection]\n";
$developerConnection =~ s-scm:hg:https://bitbucket.org/-scm:git:git\@github.com:-;
$developerConnection .= '.git';

$scmblock =~ s-<url>.*?</url>-<url>$url</url>-s;
$scmblock =~ s-<connection>.*?</connection>-<connection>$connection</connection>-s;
$scmblock =~ s-<developerConnection>.*?</developerConnection>-<developerConnection>$developerConnection</developerConnection>-s;

#print "transformed scm block [$scmblock]\n";

open (my $nfh, ">", "$pom") or die "Can't create $pom: $!\n";
print $nfh ($prescm . $scmblock . $postscm);
close $nfh;
