$wc = New-Object System.Net.WebClient
$link = Read-Host "Link eingeben"
$link -match '([^\/]+$)'
$Matches[0]
$animeData = (Invoke-RestMethod -Uri "https://api.mangadex.org/manga/$($Matches[0])")
($animeData.data.attributes.title).en
#Folder creation// add check  for new chapters
$baseFolder = Get-Location
New-Item -Path $baseFolder -Name ($animeData.data.attributes.title).en -ItemType "directory"
$folder = "$($baseFolder)\$(($animeData.data.attributes.title).en)"
$ChapterArray = [System.Collections.ArrayList]::new()
$chapterData = Invoke-RestMethod -URI "https://api.mangadex.org/chapter?manga=$($Matches[0])&limit=100&translatedLanguage[]=en" 
$offset = 0
$ChapterArray.AddRange($chapterData.results)
while($chapterData.limit + $chapterData.offset -lt $chapterData.total) {
    echo "ok2"
    $offset = $offset + 100
    $chapterData = Invoke-RestMethod -URI "https://api.mangadex.org/chapter?manga=$($Matches[0])&limit=100&translatedLanguage[]=en&offset=$offset" 
    $ChapterArray.AddRange($chapterData.results)
}

for ($i = 0; $i -lt $ChapterArray.Count; $i++) {
    $chaptervolume = $ChapterArray[$i].data.attributes.volume
    $chapterchapter = $ChapterArray[$i].data.attributes.chapter

    $chapterFolder = "Vol-$($chaptervolume) Ch-$($chapterchapter) - $($ChapterArray[$i].data.attributes.title.Replace(':','-'))"
    while ($chapterFolder[$chapterFolder.Length-2] -eq '.') {
        $chapterFolder = $chapterFolder.Remove($chapterFolder.Length-2)
    }
    New-Item -Path $folder -Name $chapterFolder -ItemType "directory"

    for ($ii = 0; $ii -lt $ChapterArray[$i].data.attributes.data.Count; $ii++) {
        
        $imgUrl = "https://uploads.mangadex.org/data/"+ $ChapterArray[$i].data.attributes.hash +"/"+$ChapterArray[$i].data.attributes.data[$ii]
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

<#for ($i= $chapters.Lenght; $i -gt -1; $i--){
    $id =  $Response[$i].data.id

    $chapter = $chapters[$i]
    $folder
    $chapter.title
    New-Item -Path $folder -Name "Vol;$($chapter.volume) Ch;$($chapter.chapter) - $($chapter.title.Replace(':',';'))" -ItemType "directory"
    $cFolder = "$($folder)\Vol;$($chapter.volume) Ch;$($chapter.chapter) - $($chapter.title.Replace(':',';'))"
    $ChapterResponse = (Invoke-RestMethod -URI "https://mangadex.org/api/v2/chapter/$($chapter.id)").data


    foreach($page in $ChapterResponse.pages){
        $imgUrl = "$($ChapterResponse.server)$($ChapterResponse.hash)/$($page)"
        $filePath = "$($cFolder)\$($page)"
        $filePath
        $wc.DownloadFile($imgUrl, $filePath)
        
    }

}
uploads.mangadex.org#>