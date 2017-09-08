#FILE: get_seq_by_id.pl
#AUTH: Xiaoping Liao (liao_xp@tib.cas.cn)
#DATE: Aug. 23rd, 2017
#VERS: 1.0

use warnings;
use strict;
use Bio::SeqIO;

my $seqdata =$ARGV[0];

my %hash=();
my $seqio = new Bio::SeqIO(-file => $seqdata,  -format => 'fasta');
while( my $seq = $seqio->next_seq){
    my $id= $seq->{primary_id};
    my $seq=$seq->{primary_seq}{seq};
    $hash{$id}=$seq;
    #print ">$id"."\n$seq\n";
}


my $idfile=$ARGV[1];
open my $ID ,$idfile or die;
open my $OUT ,'>'.$ARGV[2] or die;
while(<$ID>){
    chomp;
    print $OUT ">$_"."\n$hash{$_}\n";
}
close($ID);
close($OUT);
