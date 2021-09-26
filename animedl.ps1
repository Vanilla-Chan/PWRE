$wc = New-Object System.Net.WebClient
$baseFolder = Get-Content .\DlFolder.txt

if (($baseFolder -eq "") -or !(Test-Path -Path $baseFolder)) {
    $baseFolder = [Environment]::GetFolderPath("MyPictures")
}
$baseFolder
$link = Read-Host "Link eingeben"
$link -match '(?<=title\/)(.*)(?=\/)'
$Matches[0]
$animeData = (Invoke-RestMethod -Uri "https://api.mangadex.org/manga/$($Matches[0])")
($animeData.data.attributes.title).en
#Folder creation// add check  for new chapters

New-Item -Path $baseFolder -Name ($animeData.data.attributes.title).en -ItemType "directory"
$folder = "$($baseFolder)\$(($animeData.data.attributes.title).en)"
$ChapterArray = [System.Collections.ArrayList]::new()
$chapterData = Invoke-RestMethod -URI "https://api.mangadex.org/chapter?manga=$($Matches[0])&limit=100&translatedLanguage[]=en" 
$offset = 0
$ChapterArray.AddRange($chapterData.data)
while($chapterData.limit + $chapterData.offset -lt $chapterData.total) {
    $offset = $offset + 100
    $chapterData = Invoke-RestMethod -URI "https://api.mangadex.org/chapter?manga=$($Matches[0])&limit=100&translatedLanguage[]=en&offset=$offset" 
    $ChapterArray.AddRange($chapterData)
}

for ($i = 0; $i -lt $ChapterArray.Count; $i++) {
    $chaptervolume = $ChapterArray[$i].attributes.volume
    $chapterchapter = $ChapterArray[$i].attributes.chapter

    $chapterFolder = "Vol-$($chaptervolume) Ch-$($chapterchapter) - $($ChapterArray[$i].attributes.title.Replace(':','-'))"
    while ($chapterFolder[$chapterFolder.Length-2] -eq '.') {
        $chapterFolder = $chapterFolder.Remove($chapterFolder.Length-2)
    }
    New-Item -Path $folder -Name $chapterFolder -ItemType "directory"

    for ($ii = 0; $ii -lt $ChapterArray[$i].attributes.data.Count; $ii++) {
        
        $imgUrl = "https://uploads.mangadex.org/data/"+ $ChapterArray[$i].attributes.hash +"/"+$ChapterArray[$i].attributes.data[$ii]
        $cFolder = $folder +"\"+ $chapterFolder
        $filePath = "$($cFolder)\$($ii+1)$($imgUrl.Substring($imgUrl.Length-4))"

        if ([System.IO.File]::Exists($filePath)) {
            $filePath +" exists"
        }else{
            $i

            $wc.DownloadFile($imgUrl, $filePath)
            $imgUrl
            echo $filePath "   Downloaded"
        }
        
    }
  
}

