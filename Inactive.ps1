#Exports either Computers or Users that have not checked in in $time days. Exports to CSV.
#Author – Jeremy Corbello – JeremyCorbello.com

$reportdate = Get-Date -Format mmddyyyy
$reportfile = “Report_$reportdate.csv”
if (-not (Get-Module ActiveDirectory))
{
Import-Module ActiveDirectory -Force
}
$Criteria = Read-Host “Search ‘Computers’ or ‘Users’? Input C or U”
$DaysInactive = Read-Host “What length (In days) do you want as the search criteria?”
$time = (Get-Date).Adddays(-($DaysInactive))
switch ($Criteria)
{
“C” {Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp | select name,@{N=’LastLogonTimeStamp’; E={[DateTime]::FromFileTime($_.LastLogonTimeStamp)}} | export-csv Comp_$reportfile -NoTypeInformation; break}
“c” {Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp | select name,@{N=’LastLogonTimeStamp’; E={[DateTime]::FromFileTime($_.LastLogonTimeStamp)}} | export-csv Comp_$reportfile -NoTypeInformation; break}
“U” {Get-ADUser -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp | select name,@{N=’LastLogonTimeStamp’; E={[DateTime]::FromFileTime($_.LastLogonTimeStamp)}} | export-csv User_$reportfile -NoTypeInformation; break}
“u” {Get-ADUser -Filter {LastLogonTimeStamp -lt $time} -Properties LastLogonTimeStamp | select name,@{N=’LastLogonTimeStamp’; E={[DateTime]::FromFileTime($_.LastLogonTimeStamp)}} | export-csv User_$reportfile -NoTypeInformation; break}
default {“Invalid input”; break}
}
