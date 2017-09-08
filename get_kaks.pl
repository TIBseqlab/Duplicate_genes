#!/usr/bin/perl -w
use strict;

open(my $DES, $ARGV[0]) or die;
open(my $FULL, '>', $ARGV[2]) or die ;
my $count=0;
while (<$DES>) {
    chomp;
    $count++;
    if ($count==1) {
        my $header=$_;
        print $FULL $header."\tKa\tKs\tKa/Ks\n" ;
        next;
    }
    my @a=split /\t/,$_;
    my $g1=$a[0];
    my $g2=$a[1];
    `echo "$g1\n$g2" > id.txt`;
    my $cmd="perl get_seq_by_id.pl $ARGV[1] id.txt id.fa ";
    $cmd.= "\nperl bp_pairwise_kaks.pl -i id.fa -o id.out";
    my $result = system($cmd);
    if ( $result != 0 )
     {
         die("The following command failed: '$cmd'\n");
     }
     open(my $K, "id.out") or die;
     my $c=0;
     while (<$K>) {
        $c++;
        next if $c==1;
        my @b=split /\t/,$_;
        print $FULL join("\t",@a)."\t",$b[2]."\t".$b[3]."\t".$b[4]."\n";
     }
     `rm id.fa id.txt id.out`; 
     close($K);

}

close($DES)