use lib("./lib/perl");
use Geopiche::Analyze;

my $a = Geopiche::Analyze->new({
    source => "./data/worldcitiespop.txt",
    source_encoding => "iso-8859-1",
    terms => "./data/terms.csv",
});

# $a->read();
$a->MCELoop();
