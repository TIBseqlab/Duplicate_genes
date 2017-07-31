#FILE: Get_duplicate_genes.pl
#AUTH: Xiaoping Liao (liao_xp@tib.cas.cn)
#DATE: July. 31st, 2017
#VERS: 1.0

# This pipeline is prepared to get duplicates genes using gff and amino acid file.

use warnings;
use strict;
use File::Temp;
use File::Path;
use File::Basename;
use Getopt::Long;
use Getopt::Long qw(:config no_ignore_case);
use Data::Dumper;


my $command="perl Get_duplicate_genes.pl @ARGV";

my %options = (
    gff                        => undef,
    aa                         => undef,
    prefix                     => undef,
    threads                    => 4,
    output                     => undef,
    verbose                    => undef,
    help                       => undef
);

GetOptions(
    'g=s'          => \$options{gff},
    'a=s'          => \$options{aa},
    'p=s'          => \$options{prefix},
    't=i'          => \$options{threads},
    'o=s'          => \$options{output},
    'v'            => \$options{verbose},
    'h|help'       => \$options{help}
);

if ( defined( $options{help} ) ) {
    print_usage();
    exit(0);
}

# check the options
check_option(
    option_name     => 'g',
    option_value    => $options{gff},
    must_be_defined => 1
);
check_option(
    option_name     => 'o',
    option_value    => $options{output},
    must_be_defined => 1
);
check_option(
    option_name     => 'v',
    option_value    => $options{verbose},
    must_be_defined => 0
);
check_option(
    option_name     => 'a',
    option_value    => $options{aa},
    must_be_defined => 1 
);

# check the inputs
mkdir $options{output} unless -d $options{output};
die "$options{gff} is not a file, please specify a  gff file" unless -f $options{gff};
die "$options{aa} is not a file, please specify a file containing amoni acids" unless -f $options{aa};

message($options{verbose},"The full Command used is: $command\n" );

my $prefix=$options{prefix};

##make the blast database
my $cmd="formatdb -i $options{aa} -p T";
my $result;
message($options{verbose},"make the blast database: $cmd\n" );
$result = system($cmd);
if ( $result != 0 )
{
    die("The following command failed: '$cmd'\n");
}

##blast
$cmd="blastall -p blastp -d $options{aa} -i $options{aa} -o $options{output}/$prefix.bsp -e 1e-5 -m 8  -a 4";
message($options{verbose},"Blasting: $cmd\n" );
$result = system($cmd);
if ( $result != 0 )
{
    die("The following command failed: '$cmd'\n");
}

## Execute the R script to get the duplicate gene pair
$cmd="Rscript dupgenes.R $options{gff} $options{output}/$prefix.bsp";
message($options{verbose},"R Scripts: $cmd\n" );
$result = system($cmd);
if ( $result != 0 )
{
    die("The following command failed: '$cmd'\n");
} 


sub check_option {
    my %args = (@_);

    if ( $args{must_be_defined} ) {
        if ( !defined( $args{option_value} ) ) {
            print "Option '$args{option_name}' must be defined.\n";
            print_usage();
            exit(1);
        }
    }

    if ( !defined( $args{option_value} ) ) {
        return;
    }

    if ( $args{type_int} ) {
        if ( $args{option_value} =~ m/[^\d\+\-]/ ) {
            die("Option '$args{option_name}' must be an integer.");
        }
    }

    if ( $args{type_real} ) {
        if ( $args{option_value} =~ m/[^\d\+\-\.]/ ) {
            die("Option '$args{option_name}' must be a real number.");
        }
    }

    if ( defined( $args{max_value} ) ) {
        if ( $args{option_value} > $args{max_value} ) {
            die("Option '$args{option_name}' must be less than or equal to $args{max_value}."
            );
        }
    }

    if ( defined( $args{min_value} ) ) {
        if ( $args{option_value} < $args{min_value} ) {
            die("Option '$args{option_name}' must be greater than or equal to $args{min_value}."
            );
        }
    }

    if ( defined( $args{allowed_values} ) ) {
        my $is_allowed = 0;
        foreach my $allowed_value ( @{ $args{allowed_values} } ) {
            if ( lc( $args{option_value} ) eq lc($allowed_value) ) {
                $is_allowed = 1;
                last;
            }
        }
        if ( !$is_allowed ) {
            die("Option '$args{option_name}' must match one of the allowed values: "
                    . join( ",", @{ $args{allowed_values} } )
                    . "." );
        }
    }
}



sub message {
    my $verbose = shift;
    my $message = shift;
    $message =~ s/\s(\s{1,})/$1/g;
    if ($verbose) {
        print $message;
    }
}


sub print_usage {
    print <<BLOCK;
USAGE:
perl Get_duplicate_genes.pl [-arguments]

 -g [File]        : Input gff file (Required).
 -a [File]        : Input amino acid fil (Required).
 -o [File]        : Output duplicate genes (Required).
 -p [String]      : The output prefix (Required).
 -t [Integer]     : Number of threads (Optional, default is 4)
 -v              : Provide progress messages (Optional).
 -help           : Provide list of arguments and exit (Optional).

BLOCK
}
