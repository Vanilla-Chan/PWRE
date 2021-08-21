$wc = New-Object System.Net.WebClient
$link = Read-Host "Link eingeben"
$link -match '\d+'
$Matches[0]
$Response = (Invoke-RestMethod -URI "https://mangadex.org/api/v2/manga/$($Matches[0])/chapters").data

$chapters = $Response.chapters
$chapters = $chapters.Where{$_.language -eq "gb"}
$baseFolder = Get-Location
New-Item -Path $baseFolder -Name $chapters[0].mangaTitle -ItemType "directory"
$folder = "$($baseFolder)\$($chapters[0].mangaTitle)"


for ($i= $chapters.Count-1; $i -gt -1; $i--){
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
