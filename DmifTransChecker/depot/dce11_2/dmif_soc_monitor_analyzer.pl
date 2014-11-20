#!/tools/gnu/bin/perl5

use strict;
use Getopt::Long qw(GetOptions);

my $strDir ;
my $reqFile ;
my $retFile ;
my @_reqQueue;
my @_retQueue;
my @reqQueue;
my @retQueue;

GetOptions(
  "dir|d=s"  => \$strDir,
);

$reqFile = $strDir . "/dmif_freq_soc_monitor.txt";
$retFile = $strDir . "/dmif_fret_soc_monitor.txt";

open (REQ,$reqFile)||die "could not open file! $reqFile\n";
open (RET,$retFile)||die "could not open file! $retFile\n";

open (REQ_OUT,">$strDir" . "/req_out.tmp")||die "could not open file!\n";
open (RET_OUT,">$strDir" . "/ret_out.tmp")||die "could not open file!\n";
open (OUT,">$strDir" . "/_out.tmp")||die "could not open file!\n";


while(my $line=<REQ> ){
    $line = &RealChomp($line) ;
    push (@reqQueue, $line );
}

while(my $line=<RET> ){
    $line = &RealChomp($line) ;
    push (@retQueue, $line );
}

sub RealChomp{
    my $result = $_[0];
    $result = substr($result, 0 , length($result)-1);
    return $result;
}

foreach(@reqQueue){
    my $reqEntry = $_;
    my $reqTime;
    my $reqAddr;
    my $reqTag;
    my $retIndex = 0;
    if($reqEntry =~ m/([0-9\.]+) ns\)/){
        #print $1 . "\n";
        $reqTime = $1;
        my $reqPos = index ($_, "rdreq");
        my $tempStr = substr ($_, $reqPos);
        my @tempEntry = split / /, $tempStr;
        $reqAddr = $tempEntry[1];
        $reqTag = $tempEntry[2];
        $reqTag = hex ($reqTag);
        print REQ_OUT "$reqTime $reqAddr $reqTag\n";
        push (@_reqQueue, "$reqTime $reqAddr $reqTag");
    }
    else{
        print "ERROR 101 Data format mismatch $_\n";
    }
}

foreach(@retQueue){
    my $retEntry = $_;
    my $retTime;
    my $retTag;
    my $retTid1;
    my $retData1;
    if($retEntry =~ m/([0-9\.]+) ns\)/){
        $retTime = $1;
        my $retPos = index ($_, "rdret");
        my $tempStr = substr ($_, $retPos);
        my @tempEntry = split / /, $tempStr;
        $retTag = hex $tempEntry[1];
        $retTid1 = $tempEntry[2];
        $retData1 = $tempEntry[3];
        print RET_OUT "$retTime $retTag $retTid1 $retData1\n";
        push (@_retQueue, "$retTime $retTag $retTid1 $retData1");
    }
    else{
        print "ERROR 102 Data format mismatch $_\n";
    }
}

foreach (@_reqQueue){
    my @reqEntry = split / /, $_;
    my $reqTime = $reqEntry[0];
    my $reqAddr = $reqEntry[1];
    my $reqTag  = $reqEntry[2];
    my $retIndex = 0;
    foreach(@_retQueue){
        my @retEntry = split / /, $_;
        my $retTime = $retEntry[0];
        my $retTag = $retEntry[1];
        my $retTid1 = $retEntry[2];
        my $retData1 = $retEntry[3];
        if ($reqTag == $retTag){
            my @retEntry2 = split / /, $_retQueue[$retIndex+1];
            my $retTag2 = $retEntry2[1]; #for double confirm
            my $retTid2 = $retEntry2[2];
            my $retData2 = $retEntry2[3];
            if($retTag2 == $retTag){
                #remove element
                splice (@_retQueue, $retIndex, 2);
                my $deltaTime = $retTime - $reqTime;
                print OUT "$reqTime $reqAddr $reqTag $retTime $retTag $retTid1 $retTid2 $retData1 $retData2 $deltaTime\n";
                last;

            }
            else{
                print ("ERROR 103 next-tag mismatch $_\n");
            }
        }
        $retIndex++;
    }
}

if($#_retQueue + 1 == 0){
    printf "PASSED\n";
}
else{
    my $leftEntry = $#_retQueue + 1;
    printf "ERROR 104 still left $leftEntry unexpected.\n";
    foreach(@_retQueue){
        printf "\t$_\n";
    }
}
