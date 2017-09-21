use strict;   
use Getopt::Std;
use File::Basename;
use List::Util qw/max/;

my %opts=(s=>undef,o=>undef);
# handling command line options
getopts('s:o:',\%opts);
#Gene    adipose liver   duodenum        hypothalamus    lung    muscle  kidney
#ENSBTAG00000000005      8.62668 3.52836 1.3325  14.2656 6.28344 2.65366 0.811751
open IN, $opts{s};
open OUT, '>'.$opts{o};
my $head=<IN>;
my %exp=();
while(<IN>){
  chomp;
  my @cols=split "\t",$_;
  $exp{$cols[0]}=join("\t",@cols[1..$#cols]);
}
my $count=0;
#print "Gene1\tGene2\tGene1_Chr\tGene2_Chr\tdN\tdS\tGene1_Adipose\tGene1_Liver\tGene1_Duodenum\tGene1_Hypothalamus\tGene1_Lung\tGene1_Muscle\tGene1_kidney\tGene2_Adipose\tGene2_Liver\tGene2_Duodenum\tGene2_Hypothalamus\tGene2_Lung\tGene2_Muscle\tGene2_kidney\n";
while(<>){
    chomp;
    $count++;
    print OUT $_."\tPearson\n" and next if $count==1;
    my @cols=split "\t",$_;
    my @arr1=split /\t/,$exp{$cols[0]};
    my @arr2=split /\t/,$exp{$cols[1]};
    my $max1= max(@arr1);
    my $max2= max(@arr2);
    my $mean1 = &Mean(@arr1);
    my $mean2 = &Mean(@arr2);
    my $ss1 =0;
    for my $j (0..8){
        $ss1 = $ss1+($arr1[$j]-$mean1)*($arr1[$j]-$mean1);
    }
    my $ss2 =0;
    for my $j (0..8){
        $ss2 = $ss2+($arr2[$j]-$mean2)*($arr2[$j]-$mean2);

    }
    my $ss12 =0;
    for my $j (0..8){
        $ss12 = $ss12+($arr1[$j]-$mean1)*($arr2[$j]-$mean2);
    }
    my $cor=".";
    $cor = sprintf("%.3f",$ss12/sqrt($ss1*$ss2)) if $ss1!=0 and $ss2!=0;
    print OUT $_."\t".$cor."\n";
    #print $_."\t".$exp{$cols[0]}."\t".$exp{$cols[1]}."\n" if $cols[5]>0;
}
close(IN);
close(OUT);

sub Mean {
  my @arr = @_;
  my ($i,$sum)=(0,0);  
  for ($i=0;$i<=$#arr;$i++){
    $sum=$sum+$arr[$i];
  }
  my $mu=$sum/$#arr; 
  return $mu;
}