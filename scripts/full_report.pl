#!/usr/bin/perl -w
use strict;

open(my $GENE, '<', "ASM73341v1.gff") or die ;

my $gene={};
while (<$GENE>) {
    chomp;
    next if (/^#/);
    my @a=split /\t/,$_;
    if (/Parent=(\w+);.*product=([^\;]+);/){
        my $id=$1;
        my $des=$2;
        my $pos=$a[3]."_".$a[4];
        $gene->{$id}{"pos"}=$pos;
        $gene->{$id}{"des"}=$des;
    }
}
close($GENE);


open(my $BGI, '<', "2556921600.gff") or die ;
my $bgi={};
while (<$BGI>) {
    chomp;
    next if (/^#/);
    my @a=split /\t/,$_;
    if (/ID=(\w+);.*product=([^\;]+)/){
        my $id=$1;
        my $des=$2;
        my $pos=$a[3]."_".$a[4];
        $bgi->{$pos}{"id"}=$id;
        $bgi->{$pos}{"des"}=$des;
    }
}
close($BGI);

open(my $PAP, '<', "2022827000.gff") or die ;
my $pa={};
while (<$PAP>) {
    chomp;
    next if (/^#/);
    my @a=split /\t/,$_;
    if (/ID=(\w+);.*product=([^\;]+)/){
        my $id=$1;
        my $des=$2;
        my $pos=$a[3]."_".$a[4];
        $pa->{$pos}{"id"}=$id;
        $pa->{$pos}{"des"}=$des;
    }
}
close($PAP);

open(my $mod, '<', $ARGV[0]) or die ;
open(my $FULL, '>', $ARGV[1]) or die ;
my $count=0;
while(<$mod>){
    $count++;
    print $FULL "id\tpos\tdes\tNCBI_Des\tPaper_id\tPaper_Des\tBGI_id\tBGI_des\tcolor\tGS\tP.GS\tMM\tP.MM\n" and next if $count==1;
    #gene1952,#N/A,hypothetical protein,,,magenta,-0.899713384,0.000952281,0.992791972,1.03955E-07
    
    chomp;
    my @a=split /,/,$_;
    my $id=$a[0];
    my $des=$a[1];
    my $ncbi_des='';
    $ncbi_des=$gene->{$id}{"des"};
    my $pos=$gene->{$id}{"pos"};
    my $paper_id=defined($pa->{$pos}{"id"}) ? $pa->{$pos}{"id"}:"" ;
    my $paper_des=defined($pa->{$pos}{"des"}) ? $pa->{$pos}{"des"}:"" ;
    my $bgi_id=defined($bgi->{$pos}{"id"}) ? $bgi->{$pos}{"id"}:"" ;
    my $bgi_des=defined($bgi->{$pos}{"des"}) ? $bgi->{$pos}{"des"}:"" ;
    if (!defined($paper_id)){
        my $a=1;
    }
    print $FULL "$id\t$pos\t$des\t$ncbi_des\t$paper_id\t$paper_des\t$bgi_id\t$bgi_des\t$a[-5]\t$a[-4]\t$a[-3]\t$a[-2]\t$a[-1]\n";
}
close($mod);
close($FULL)

