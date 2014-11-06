use File::Find;
use File::Basename;
use DBI;
use DBD::mysql;

use constant USERNAME =>"root";
use constant PASSWORD => "root";
use constant DATASOURCE => "kardb";

#===============================================================
find (\&Insert_File_To_DB, "C:/Users/username/Desktop/P/PerKarDb");
#===============================================================

sub Insert_File_To_DB {
  my $filename = $_;
  my $directory;
  my $fullpath = $File::Find::name;
  my ($select_cmd, $cmdSql, $select_handle, $query_handle);
  if (-f $filename) { 	
		$directory = dirname($fullpath);	
		$cmdSql = "Insert Into SongList(song_name, dir_path) ".
					"Values('".$filename."','". $directory."')";
			
		$select_cmd = "Select * From SongList ".
						"Where song_name ='".$filename."' And dir_path = '".$directory."'";		

		my $rs_count = 0;
		$select_handle = Connect_DB_Query_Data($select_cmd);
		while(my $row = $select_handle->fetchrow_hashref){
			$rs_count++;
		}
		
		# check if file is there in db
		if(!$rs_count){
			$query_handle = Connect_DB_Query_Data($cmdSql);
			print "Inserted: ". $fullpath ."\n";	
		}
		else{
			print $fullpath." is already there!\n";
		}	
	}
}	
#Connect to database and do the query to get data#
sub Connect_DB_Query_Data{
	my $cmdQuery = shift;
	# Connection
	my $data_source = DATASOURCE; $data_source = "dbi:mysql:$data_source";
	my $dbh = DBI->connect($data_source, USERNAME, PASSWORD)
		or die "Can't connect to $data_source: $DBI::errstr";
		
	# Prepare the input
	my $sth = $dbh->prepare($cmdQuery)
		or die "Can't prepare statement: $DBI::errstr\n$cmdQuery";
	# Execute the statement
	$sth->execute()
		or die "Error Execute: $DBI::errstr\n";
	
	return $sth;
}
