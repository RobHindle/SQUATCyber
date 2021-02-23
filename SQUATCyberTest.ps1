### CyberSquatter Monitor
# Takes base list of URLs you wish to test for proximate CyberSquatters
# Generates potential squat list per known methods (size substitution & fingerslips)
# Presumes just a single error or adjustment in each URL tested from the core.
# Tests if the sites are up
# Checks the ownership of the sites if they are up.
# Outputs in text files with commas for major separation
######################################

# Robert Hindle 2021-02-20

############# Compose Alternate URL spellings ############
# Function Invert-URLchars
<#
.Synopsis
    Inverts adjacent characters in a URL and stores these for future testing
.Description
    Goes through and inverts adjacent characters
.Parameter
    URLs - array of URLs to be studied and modified for search of squatters
.Parameter
    TrgtFN - File name of file to hold the adjusted URL formats
.Example
#>
Function Invert-URLchars {
    Param ( $URLS ,
            $TrgtFn
             )
foreach ($baseurl in $URLs) {
#transpose 2
   for ($i = 0; $i -lt $($baseurl.Length - 1); $i += 1) {
       $inxt = $i + 1
       $composedURL = ""
        for ($j = 0; $j -lt $baseURL.Length; $j +=1) {
            if ($j -eq $i) {
                $composedURL += $baseURL[$inxt]
            }
            elseif ($j -eq $inxt) {
                $composedURL += $baseURL[$i]
             }
             else {
                $composedURL += $baseurl[$j]
            }
       } # For each character of the URL j
       $composedURL >> $TrgtFn
      } # For each character of the URL i
   } # For each URL in the list to be tested
} # Function Invert-URLchars
##############################

Function Substitute-URLletters {
   Param ( $URLS ,
           $SubletterFn = "$PSScriptRoot\FNGRSLPletters.txt",
           $TrgtFn
          )

$subssp = get-content -Path $SubletterFn

foreach ($baseurl in $URLs) {
  $inda = [int][char]"a"
  $indz = [int][char]"z"          #######################test for not LC letters
For ($i = 0; $i -lt $baseURL.length; $i += 1) {
  $indx = [int][char]$baseurl[$i]
  #think here if (($indx -ge $inda) -and ($indx -le $indz)) {
  $arypntr = $indx-$inda
  $subvals = $subssp[$arypntr]
  for ($j = 1; $j -lt $subvals.length; $j += 1) {
     $subchar = $subvals[$j]
     $composedURL = ""
     for ($k = 0; $k -lt $baseURL.length; $k += 1) {
       if ( $k -eq $i ) {
         $composedURL += $subchar
         }
       else {
         $composedURL += $baseURL[$k]
         }
     } #k
if ($debug -eq "YES") {
  $composedURL
  }
  else { $composedURL >> $TrgtFn
  }
  } #j
  #think here } if the character we ae working on is not in range then skip
} #i
} # for each url in url list
} # Substitute-URLletters -URLS

Function Substitute-URLnumbers {
   Param ( $URLS ,
           $SubnumberFn = "$PSScriptRoot\FNGRSLPnumbers.txt",
           $TrgtFn
          )

$subssp = get-content -Path $SubnumberFn
   $inda = [int][char]"0"
   $indz = [int][char]"9"  
foreach ($baseurl in $URLs) {
For ($i = 0; $i -lt $baseURL.length; $i += 1) {
  $indx = [int][char]$baseurl[$i]
  if (($indx -ge $inda) -and ($indx -le $indz)) {
  $arypntr = $indx-$inda     
  $subvals = $subssp[$arypntr]
  for ($j = 1; $j -lt $subvals.length; $j += 1) {
     $subchar = $subvals[$j]
     $composedURL = ""
     for ($k = 0; $k -lt $baseURL.length; $k += 1) {
       if ( $k -eq $i ) {
         $composedURL += $subchar
         }
       else {
         $composedURL += $baseURL[$k]
         }
     } #k
  if ($debug -eq "YES") {
    $composedURL
    }
    else { $composedURL >> $TrgtFn
    }
  } #j
 } # if character here is not a number then skip this letter for processing
} #i
} # for each url in url list
} # Substitute-URLnumbers -URLS

# Function Add-WHeaderOnURL
<#
.Synopsis
    Adds array of potential headers that emulate leads to URL
.Description
    Adds array of potential headers that emulate leads to URL
.Parameter
    URLs - array of URLs to be studied and modified for search of squatters
.Parameter
    HEADs - array of head strings that might get through close scrutiny or missing period
.Parameter
    TrgtFN - File name of file to hold the adjusted URL formats
.Example

#>
Function Add-WHeaderOnURL {
   Param ( $URLS ,
           $Heads = @("www","ww3","www3","w3"),
           $TrgtFn
          )
   Foreach ($URL in $URLs) {
      Foreach ($head in $Heads) {
         "$head$URL" >> $TrgtFn
      } # for each Head
   } # For each URL

} # Function Add-WHeaderOnURL


# Function Replace-URLseq
<#
.Synopsis
   Does substitutions for permutations and combinations on a string rather than single character.
.Description
   Goes through the list of URLs being studied and does replacement substitutions for domain blocks 
.Parameter
   URLs -array of URLs that are being considered for the replacement work
.Parameter
   RplcFn  -Replacements file Name First CSV entry is the replacement target with other pieces replacing
.Parameter
   Debug Yes|No  Dflt=NO
.Parameter
   TrgtFn  - is the output file of URLs for availability testing
.Example
   $sub = "$PSScriptRoot\Replacers.txt"
   Replace-URLseq -URLs $baseURLs -Rplcfn $sub -Trgtfn $trgt

#>
Function Replace-URLseq {
  Param ( $URLs,
          $Rplcfn = "$PSScriptRoot\Replacers.txt",
          $Debug = "NO",
          $TrgtFn
         )

 $replacers = get-content $Rplcfn

foreach  ($baseURL in $URLs) {
foreach ($replacer in $replacers) {
 $replace = $replacer -split ","
 # first instance of replace block
 $IOreplace = $baseURL.tostring().IndexOf($replace[0])
 if ($IOreplace -gt 0 ) {
   if ($($IOreplace+$($replace[0].Length)) -eq $baseURL.Length) {
     $lead = $baseURL.tostring().Substring(0,$IOreplace)
     for ($i =1; $i -lt $replace.Count; $i += 1) {
       $composedURL = $lead+$($replace[$i])
       if ($debug -eq "YES") {
        $composedURL
        }
       else { 
        $composedURL >> $TrgtFn
        } #debug URL output
     } # for replace 1-n
   } #end of the line
   else {
     $lead = $baseURL.tostring().Substring(0,$IOreplace)
     $rmndr = $baseurl.Length - $IOreplace - $replace[0].Length
     $tail = $baseURL.tostring().substring($($IOreplace+$($replace[0].Length)),$rmndr)
     for ($i =1; $i -lt $replace.Count; $i += 1) {
       $composedURL = $lead+$($replace[$i])+$tail
       if ($debug -eq "YES") {
        $composedURL
        }
       else { 
        $composedURL >> $TrgtFn
        } #debug URL output
     } # for replace 1-n
     # look for another (just 1) of same replacement target in the tail as well
     # replace just in the tail
     #$tail
     $IO2replace = $tail.tostring().IndexOf($replace[0])
     if ($IO2replace -gt 0) {
        $lead = $baseURL.tostring().Substring(0,$IOreplace+$replace[0].Length+$IO2replace)
        for ($i =1; $i -lt $replace.Count; $i += 1) {
          $composedURL = $lead+$($replace[$i])
          if ($debug -eq "YES") {
            $composedURL
           }
          else { 
            $composedURL >> $TrgtFn
           } #debug URL output
     } # for replace 1-n

     } # second match in tail
   } # Tail needed
 } #match found
} # replacer
} # for each baseURL
} # Function Replace-URLseq

############ Testing URLS ##########################
# Function Test-SiteandOwner
<#
.Synopsis
   Tests if the website at the URL is up and running (or not).
.Description
   TrgtFile - File of URLs to be tested 
.Parameter
   WebUp - File to hold websites that were found UP
.Parameter
   WebNUp - Optional - File to hold websites that were found NOT UP
.Parameter
   Debug Yes|No  Dflt=NO
.Parameter
   TestDelay - Delay amount to not swmp your IP  Default = 50 milliseconds
.Example
   $TSAO = Test-SiteandOwner -TrgtFile $composedURLs -WebUp c:\test\sitesup.txt -TestDelay = 150
.Example
   $TSAO = Test-SiteandOwner -TrgtFile $composedURLs -WebUp c:\test\sitesup.txt -WebNUP "C:\test\NotUP.txt -TestDelay = 150
#>
Function Test-SiteandOwner {
    Param ( $TrgtFile,
            $Webup,
            $WebNup,
            $Debug = "NO",
            $TestDelay = 50
           )
$sites = Get-Content -Path $trgtfile
foreach ($site in $sites){
  $iwr = ""
  try {
  $iwr = Invoke-WebRequest -uri $site -DisableKeepAlive -Method Head -ErrorAction SilentlyContinue
  }
  catch {"$site not Found"}

  if ($debug -eq "YES") {$iwr}
  $statusflg = "$($iwr.statuscode)"
  if (($statusflg -eq 200) -or ($statusflg -eq 403)) { 
     if ($debug -eq "YES") {"OK - Site $site found and responding" }
     try {
     $testips = [system.net.DNS]::GetHostAddresses("$site")
     } 
     catch {"No IP found for $site !!?"}
     $ip = ""
     $aliases = ""
        foreach ($testip in $testips) {
        $ip += "$($testip.IPAddressToString);"
        try {
        $testurl = [system.net.DNS]::GetHostByAddress("$testip")
        }
        catch {"No Reverse DNS found for $site !!?"}
        $aliases += "$($testurl.Aliases);"
        
        #$url = "$baseWHOISurl/ip/$($testip.IPAddressToString)"
        #$rslt = Invoke-RestMethod -Uri $url

        } # foreach ip associated to name
        if ($Webup.length -eq 0) {
           #"$site,$ip,$statusflg,$aliases,$($rslt.net.name),$($rslt.net.startaddress),$($rslt.net.endaddress),$($rslt.net.updateDate)"
           "$site,$ip,$statusflg,$aliases"
           }
           else {
           #"$site,$ip,$statusflg,$aliases,$($rslt.net.name),$($rslt.net.startaddress),$($rslt.net.endaddress),$($rslt.net.updateDate)" >> $webup
           "$site,$ip,$statusflg,$aliases" >> $webup
           }
     }
     else {
       if ($debug -eq "YES") {"NOT OK - Site $site not available" }
       if ($WebNup.length -eq 0) {}
       else { "$site,$statusflg" >> $webNup }
     }
     start-sleep -Milliseconds $testdelay
} # for each site
} # Function Test-SiteandOwner

#Function Check-WhoISIP
<#
 FYI : 'http://whois.arin.net/rest'   # alternate whois servic API
.Synopsis
    Does a WebRequest check on WhoIS to bring back Country and address info
.Description
    Does a webrequest and the uses regular expressions to parse the return 
    for name, address and date info for consideration to the sites you visit/connect with
    Return is whatever information gleaned
.Parameter
    IPin -IP address for the site you want whois info on. IPv4 ?IPv6?
.Parameter
    Debug - extra inforamtion - Default = NO
.Example
  $whoisinfo = Check-WhoisIP -IPin "254.23.6.47"
#>
Function Check-WhoisIP {
   Param ( $IPin ,
           $debug = "NO"
           )
   #Could check here if it looks like an IPv4 address
   $whoisInfo = "$IPin = "
   $SS =  @{"searchString" = "$IPin"}
  $WebResponse = Invoke-WebRequest -Uri "https://who.is/domains/search" -Method Post -Body $SS
  $Pre = $WebResponse.AllElements | Where {$_.TagName -eq "pre"}
  If ($Pre -match "OrgName:\s+(\w+)")                 { $WhoisInfo += "Organization: $($Matches[1])" }
  If ($Pre -match "Country:\s+(\w{2})")               { $WhoisInfo += "Country code: $($Matches[1])" }
  If ($Pre -match "RegDate:\s+(\w{2,4})\S(\w{1,2})\S(\w{1,2})")   { $WhoisInfo += "Reg Date: $($Matches[0])" }
  If ($Pre -match "UpDated:\s+(\d+)\D(\d+)\D(\d+)")   { $WhoisInfo += "Update: $($Matches[0]) $($Matches[2]) $($Matches[3])" }
  If ($Pre -match "PostalCode:\s+(\w+)")              { $WhoisInfo += "Postal Code: $($Matches[1])" }
  if ($debug -eq "YES") { $pre.innertext }
  $whoisInfo
} # Function Check-WhoisIP

# Function Review-WhoIs
<#
.Synopsis
   Processes the file of websites that are up using IP.
.Description
   Processes the file of websites that are up using IP.
.Parameter
   WebUp - File to hold websites that were found UP
.Parameter
   WhoIS - File to hold WhoIs information discovered
.Parameter
   TestDelay - Delay amount to not swamp your IP or WhoIS  Default = 50 milliseconds
.Example
   $webup = "c:\results\webup.txt"
   $whois = "c:\results\whois.txt"
   Review-WhoIs -WebUp $webup -WhoIS $whoIs  -TestDelay 150
#>
Function Review-WhoIs {
   Param( $webup,
          $whoIs,
          $testdelay = 50 )
   $webupGC = get-content -Path $webup 
   Foreach ($line in $webupGC){
      $webupinfo = $line.split(",")
      $Checkips = $webupinfo[1].split(";")
      #$line >> $whoIs
      Foreach ($ip in $Checkips) {
        $CWIip = Check-WhoisIP -IPin $ip
        "$line $CWIip" >> $whoIs
        start-sleep -Milliseconds $testdelay
      } #ip in checkips
   } # line in GC

} # Function Review-WhoIs

###################### MAIN ################################
# #### base references
$trgtfldr = "$PSScriptRoot" # folder to find and put things
$tdy = get-date -format "yyyyMMddHHmm"                               # time of run start
$testdelay = 100                                                     # delay between tests in milliseconds
$debug = "NO"                                                        # debugging to screen

# #### Outputs by type Date and Time to minutes
$basefile = "BaseEvalURLs.txt"        # needed with one entry
$trgtfile = "Results\SQUAT$tdy.txt"           # generated per run
$webupfile = "Results\WebUp$tdy.txt"          # Websites found running. Generated if one running
$webNupfile = "Results\webNup$tdy.txt"        # Websites not running. Generated if one not running
$whoIsfile = "Results\WhoIs$tdy.txt"  # Who Is results for sites that are up

$base = "$trgtfldr\$basefile"
$trgt = "$trgtfldr\$trgtfile" 
$webup = "$trgtfldr\$WebUpfile" 
$webNup = "$trgtfldr\$WebNUpfile"
$whoIs = "$trgtfldr\$WhoIsfile"

$baseURLs = get-content -Path $base  # first read

# #### Generate the list of test URLs
Invert-URLchars -URLS $baseurls -Trgtfn $trgt
Add-WHeaderOnURL -URLS $baseURLs -Trgtfn $trgt

$sub = "$PSScriptRoot\FNGRSLPletters.txt"
Substitute-URLletters -URLS $baseURLs -SubletterFn $sub -Trgtfn $trgt
$sub = "$PSScriptRoot\SHAPEletters.txt"
Substitute-URLletters -URLS $baseURLs -SubletterFn $sub -Trgtfn $trgt

$sub = "$PSScriptRoot\FNGRSLPnumbers.txt"
Substitute-URLnumbers -URLS $baseURLs -SubnumberFn $sub -Trgtfn $trgt
$sub = "$PSScriptRoot\SHAPEnumbers.txt"
Substitute-URLnumbers -URLS $baseURLs -SubnumberFn $sub -Trgtfn $trgt

$sub = "$PSScriptRoot\Replacers.txt"
Replace-URLseq -URLs $baseURLs -Rplcfn $sub -Trgtfn $trgt

# #### Test if site running #######

Test-SiteandOwner -TrgtFile $Trgt -Webup $webup -WebNup $WebNUp -TestDelay $testdelay
Review-WhoIs -WebUp $webup -WhoIS $whoIs  -TestDelay $testdelay
