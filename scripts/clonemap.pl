#!/usr/local/bin/perl

use strict;
use Bio::EnsEMBL::Pipeline::RunnableDB::CrossCloneMap;
use Bio::EnsEMBL::DBSQL::CrossMatchDBAdaptor;
use Bio::EnsEMBL::DBLoader;
use Getopt::Long;

$| = 1;


my $dbtype = 'rdb';
my $host   = 'ecs1e';
my $port   = '';
my $dbname = 'cross_mouse';
my $dbuser = 'ensadmin';
my $dbpass = 'ensembl';
my $module = 'Bio::EnsEMBL::DBSQL::CrossMatchDBAdaptor';

&GetOptions ( 
	       'dbtype:s' => \$dbtype,
	       'host:s'   => \$host,
	       'port:n'   => \$port,
	       'dbname:s' => \$dbname, 
	       'dbuser:s' => \$dbuser,
	       'dbpass:s' => \$dbpass,
	       'module:s' => \$module,
	       );
my $clone=shift @ARGV;

my $locator = "$module/host=$host;port=$port;dbname=$dbname;user=$dbuser;pass=$dbpass";

print STDERR "Using $locator for crossmatch db\n";
my $crossdb =  Bio::EnsEMBL::DBLoader->new($locator);

my $crossmap = Bio::EnsEMBL::Pipeline::RunnableDB::CrossCloneMap->new(-crossdb=>$crossdb, -score =>1000);
print STDERR "Fetching input for clone $clone\n";
$crossmap->fetch_input($clone);
print STDERR "Running mapping for clone $clone\n";
#$SIG{ALRM} = sub { die "timeout"};
#eval {
#    alarm(3600);
$crossmap->run;
#    alarm (0);
#};
#if ($@) {
#    if ($@ =~ /timeout/) {
#	die("EXCEPTION: Crossmatch for clone $clone timed out! Exiting");
#    }
#    else {
#	die("Died because of $@");
#    }
#}
print STDERR "Writing output for clone $clone\n";
$crossmap->write_output;



