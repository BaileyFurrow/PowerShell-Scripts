
function Get-YouTubePlaylistTime {
    <#
        .SYNOPSIS
            Calculate the total length of a YouTube playlist.
        .DESCRIPTION
            Uses Google's YouTube Data API to find all videos in a playlist,
            add their durations together, and returns the total duration.
        .PARAMETER URL
            YouTube URL. Can either be the playlist page or a video in the
            playlist. URL must contain the `list` query parameter.
        .PARAMETER PlaylistID
            ID of the YouTube playlist.
        .PARAMETER Value
            Returns the value only rather than a formatted string
        .OUTPUTS
            System.TimeSpan of total playlist length.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ParameterSetName="listID")]
        [string]$PlaylistID,

        [Parameter(Mandatory, Position=0, ParameterSetName="url")]
        [System.Uri]$URL
    )

    begin {
        # Get the Playlist ID from the URL.
        if ($URL -and -not $PlaylistID) {
            # Must be from YouTube
            if ($URL.Host -notin "youtu.be","youtube.com","www.youtube.com") {
                throw [System.FormatException]::new("Invalid URL. URL must be from 'youtu.be', 'youtube.com', or 'www.youtube.com'.")
            }
            Add-type -AssemblyName System.Web
            $URLParse = [System.Web.HttpUtility]::ParseQueryString($URL.Query)
            # YT URL must contain the `list` query.
            if ("list" -notin $URLParse) {
                throw [System.FormatException]::new("Invalid query. URL must contain the ``list`` query to reference a specific playlist.")
            }
            $PlaylistID = $URLParse.Get("list")
        }
    }

    process {
        $ytApi = @{
            baseURL = "https://youtube.googleapis.com/youtube/v3/";
            key = Get-Content ./.private/GoogleKey.txt -Raw
        }
        $ytApi.pListItems = $ytApi.baseURL + "playlistItems?key=" + $ytApi.key + "&part=contentDetails&maxResults=50&playlist_id="
        $ytApi.pList = $ytApi.baseURL + "playlists?key=" + $ytApi.key + "&part=snippet&maxResult=1&id="
        $ytApi.videos = $ytApi.baseURL + "videos?key=" + $ytApi.key + "&part=contentDetails&id="
        $totalTime
        
        $playlist = curl "$($ytApi.pListItems)$PlayListID" | ConvertFrom-Json
        
        do {
            $videoIDs = @()
            $playlist.items | ForEach-Object { $videoIDs += $_.contentDetails.videoId }
            $videosInfo = curl "$($ytApi.videos)$($videoIDs -join ',')" | ConvertFrom-Json
            $videosInfo.items | ForEach-Object {
                Write-Debug "$($_.id): $($_.contentDetails.duration)"
                $totalTime += [System.Xml.XmlConvert]::ToTimeSpan($_.contentDetails.duration)
            }
            $playlist = curl "$($ytApi.pListItems)$PlaylistID&pageToken=$($playlist.nextPageToken)" | ConvertFrom-Json
        } while ([bool]$playlist.nextPageToken)

        $playlistInfo = curl "$($ytApi.pList)$PlaylistID" | ConvertFrom-Json
        Write-Host "Playlist: $($playlistInfo.items.snippet.title)"
        Write-Host "      By: $($playlistInfo.items.snippet.channelTitle)"
        Write-Host "Total # of videos: $($playlist.pageInfo.totalResults)"
        return $totalTime
    }
}

Export-ModuleMember -Function Get-YouTubePlaylistTime
