#!/usr/bin/perl -w
use strict;

open(my $BGI, '<', "2556921600.gff") or die ;
my $bgi={};
while (<$BGI>) {
    chomp;
    next if (/^#/);
    my @a=split /\t/,$_;
    if (/ID=(\w+);.*product=([^\;]+)/){
        my $id=$1;
        my $des=$2;
        $bgi->{"id"}=$id;
        $bgi->{"des"}=$des;
    }
}
close($BGI);


open(my $mod, '<', $ARGV[0]) or die ;
open(my $FULL, '>', $ARGV[1]) or die ;
my $count=0;
while(<$mod>){
    $count++;
    print $FULL "query\tsubject\tidentity\tlength\tqlength\tslength\tquery_des\tsubject_des\n" and next if $count==1;
    chomp;
    my @a=split /,/,$_;
    my $query=$a[0];
    my $subject=$a[1];
    my $identity=$a[2];
	my $len=$a[3];
	my $qlength=$a[5];
	my $slength=$a[4];
    my $query_des=defined($bgi->{"id"}) ? $bgi->{"id"}:"" ;
    my $subject_des=defined($bgi->{"des"}) ? $bgi->{"des"}:"" ;
    print $FULL "$query\t$subject\t$identity\t$len\t$qlength\t$slength\t$query_des\t$subject_des\n";
}
close($mod);
close($FULL)

