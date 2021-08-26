$wc = New-Object System.Net.WebClient
$link = Read-Host "Link eingeben"
$link -match '([^\/]+$)'
$Matches[0]
$animeInfo = (Invoke-RestMethod -URI "https://api.mangadex.org/chapter?manga=$($Matches[0])&limit=100&translatedLanguage[]=en").results 
$chapters[0].data.attributes.title

#Folder creation// add check  for new chapters
$baseFolder = Get-Location
New-Item -Path $baseFolder -Name $chapters[0].data.attributes.title -ItemType "directory"
$folder = "$($baseFolder)\$($chapters[0].data.attributes.title)"

$chapters = (Invoke-RestMethod -URI "https://api.mangadex.org/chapter?manga=$($Matches[0])&limit=100&translatedLanguage[]=en").results 



for ($i= $chapters.Lenght; $i -gt -1; $i--){
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
uploads.mangadex.org