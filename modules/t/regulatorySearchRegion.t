use strict;

use Bio::EnsEMBL::Test::TestUtils;

BEGIN { $| = 1;
	use Test;
	plan tests => 10;
}

use Bio::EnsEMBL::Test::MultiTestDB;
use Bio::EnsEMBL::CoordSystem;
use Bio::EnsEMBL::Slice;
use Bio::EnsEMBL::Analysis;
use Bio::EnsEMBL::RegulatorySearchRegion;
use Bio::EnsEMBL::DBSQL::RegulatorySearchRegionAdaptor;


our $verbose = 0;

my $multi = Bio::EnsEMBL::Test::MultiTestDB->new;

# get a core DBAdaptor
#
my $dba = $multi->get_DBAdaptor("core");
my $rsa = $dba->get_RegulatorySearchRegionAdaptor();

#
# 1 create a new RegulatorySearchRegion
#
my $coord_system = Bio::EnsEMBL::CoordSystem->new
  (-NAME    => 'chromosome',
   -VERSION => 'NCBI34',
   -DBID    => 1,
   -RANK    => 1);

my $analysis = Bio::EnsEMBL::Analysis->new(-LOGIC_NAME => 'test');

my $slice = Bio::EnsEMBL::Slice->new(-COORD_SYSTEM    => $coord_system,
                                     -SEQ_REGION_NAME => 'X',
                                     -SEQ_REGION_LENGTH => 15e6,
                                     -START           => 0,
                                     -END             => 2_000_000);

my $gene = $dba->get_GeneAdaptor()->fetch_by_stable_id( "ENSG00000171456" );

my $rs = new Bio::EnsEMBL::RegulatorySearchRegion(-start               => 100,
                                                  -end                 => 220,
                                                  -strand              => -1,
                                                  -slice               => $slice,
                                                  -analysis            => $analysis,
                                                  -ensembl_object_id   => 18256,
                                                  -ensembl_object_type => 'Gene',
                                                  -dbID                => 1230,
                                                  -adaptor             => $rsa);
ok($rs);


#
# 2-8 test the basic getter and setters
#

# 2 start
ok(test_getter_setter($rs,'start',10));

# 3 end
ok(test_getter_setter($rs,'end',14));

# 4 strand
ok(test_getter_setter($rs,'strand',1));

# 5 dbID
ok(test_getter_setter($rs,'dbID',20));

# 6 name
ok(test_getter_setter($rs,'name', 'CisRed_search_2'));

# 7 ensembl_object_id
ok(test_getter_setter($rs,'ensembl_object_id',18256));

#8 ensembl_object_type
ok(test_getter_setter($rs,'ensembl_object_type','Gene'));

#
# 9 check adaptor attaching
#
$rs->adaptor($rsa);
ok($rs->adaptor->isa('Bio::EnsEMBL::DBSQL::RegulatorySearchRegionAdaptor'));

# 10 Check loading of ensembl object
my $gene = $rs->ensembl_object();
ok($gene->isa('Bio::EnsEMBL::Gene'));
ok($gene->dbID() == 18256);
