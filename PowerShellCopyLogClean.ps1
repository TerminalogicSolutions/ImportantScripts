Function copyTrnFiles($SourceFolder, $destFolder, $hours) {
	#Set Defaults
	$hours = [int]$hours
	$timespan = new-timespan -days 0 -hours $hours -minutes 0
	$src_path = $SourceFolder
	$dest_path = $destFolder + '\'
	$list = @(Get-ChildItem $src_path -Filter *.trn | Sort LastWriteTime -Descending)


	foreach($file in $list)
	{
			$file.BaseName  | Out-File $OutputFile -Append
			'Date Created: ' + $file.LastWriteTime  | Out-File $OutputFile -Append
			$tempDest = $dest_path + $file.BaseName + $file.Extension
			
			#Doest it exist?
			if (!(Test-Path $tempDest)) {
			
				#File doesnt' exist, copy it to the destination.
				"Destination File Doesn't Exist" | Out-File $OutputFile -Append
				$file.CopyTo($tempDest)
				
				
				#Validate that the file was copied successfully.
				if ((Test-Path $tempDest)) {
					"Destination File validation complete. Copy Successful." | Out-File $OutputFile -Append
					
					#Check if source file is older than 24hrs, if so delete
					if (((get-date) - $file.LastWriteTime) -gt $timespan) {
						"Source File exceeds retaining threshold. Source File will be deleted." | Out-File $OutputFile -Append
						#$file.Delete
						Remove-Item $file.FullName
						Write-Host "$file deleted successfully"
						
					} else {
					    Write-Host "Will not be deleted"
					}
									
				}
				
			} else {
				Write-Host "$file exists"
			}
			
			" "  | Out-File $OutputFile -Append 
			"++++++++++++++++++++++++++++++++++++++++++++++++++++++"  | Out-File $OutputFile -Append
			" "  | Out-File $OutputFile -Append
		
	}

}
# Delete old files depending on hours and location

Function deleteOldFiles ($SourceFolder, $hours) {
	$hours = [int]$hours
	$timespan = new-timespan -days 0 -hours $hours -minutes 0
	$src_path = $SourceFolder
	$list = @(Get-ChildItem $src_path | Sort LastWriteTime -Descending)
	Write-Host $list.Count

	foreach($file in $list)
	{
		Write-Host $file.FullName
		if (((get-date) - $file.LastWriteTime) -gt $timespan) {
			Remove-Item $file.FullName
			Write-Host "$file deleted successfully"
			
		} else {
		    Write-Host "Will not be deleted"
		}
	}
	
}

#Information to output
Function Touch-File {
	$file = $args[0]
	
    if($file -eq $null) {
        throw "No filename supplied"
    }

    if(Test-Path $file)
    {
        (Get-ChildItem $file).LastWriteTime = Get-Date
    }
    else
    {
		Write-Host "Creating File"
        echo $null > $file
    }
}

#Create your output file

$date = (Get-Date).ToString("yyyyMd_HHmmss")
$OutputFile = 'F:\Database\Backups\Logs\Log_Copy_Cleanup_' + $date.ToString() + '.log'

Touch-File $OutputFile

"Test" | Out-File $OutputFile -Append


copyTrnFiles "E:\Database\Backups\prod.commonwealth" "F:\Database\Backups\prod.commonwealth" "24"
copyTrnFiles "E:\Database\Backups\reidsville.prod.kpi" "F:\Database\Backups\reidsville.prod.kpi" "24"

deleteOldFiles "F:\Database Backups\prod.commonwealth" "336"
deleteOldFiles "F:\Database Backups\reidsville.prod.kpi" "336"
deleteOldFiles "F:\Database\Backups\Logs" "120"
