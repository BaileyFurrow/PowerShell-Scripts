function Optimize-Files {
    <#
    .SYNOPSIS
        Sort files in current folder into subfolders by file type.
    .DESCRIPTION
        Sorts the files in current folder into subfolders based on file type. 
        The file types are categorized into multiple categories:
        
        - documents
        - data
        - archives and executables
        - images
        - audio
        - video
        - code

        All file not found in listed file types will not be moved.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        # Specifies a path to one or more locations.
        [Parameter(Position=0,
                   ParameterSetName="Path",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Path to one location.")]
        [Alias("PSPath")]
        [string] $Path = $PWD.Path
    )

    # File types as a JSON object
    $filetypes_json = @'
    {
        "documents": [
            "*.rtf",
            "*.doc*",
            "*.dot*",
            "*.epub",
            "*.mobi",
            "*.odt",
            "*.pdf",
            "*.tex",
            "*.xls*",
            "*.ppt*",
            "*.bib",
            "*.ris"
        ],
        "data": [
            "*.txt",
            "*.csv",
            "*.md",
            "*.log",
            "*.text",
            "*.info",
            "*.hlp",
            "*.json",
            "*.ini",
            "*.inf",
            "*.tsv",
            "*.xml",
            "*.yaml",
            "*.yml",
            "*.dat",
            "*.db",
            "*.mdb",
            "*.accdb",
            "*.sql",
            "*.sqlite",
            "*.pcapng",
            "*.pcap",
            "*.cap"
        ],
        "code": [
            "*.c",
            "*.cpp",
            "*.cs",
            "*.csproj",
            "*.cc",
            "*.go",
            "*.h",
            "*.hpp",
            "*.java",
            "*.js",
            "*.lisp",
            "*.php",
            "*.r",
            "*.rs",
            "*.sln",
            "*.py",
            "*.pl",
            "*.rb",
            "*.xsl",
            "*.html",
            "*.htm",
            "*.css",
            "*.xhtml",
            "*.xht",
            "*.mhtml",
            "*.mht",
            "*.asp",
            "*.aspx",
            "*.vbs"
        ],
        "video": [
            "*.3gp",
            "*.avi",
            "*.flv",
            "*.m4v",
            "*.mp4",
            "*.mkv",
            "*.mov",
            "*.mpg",
            "*.mpeg",
            "*.swf",
            "*.drp",
            "*.ppj",
            "*.prproj",
            "*.wlmp",
            "*.veg",
            "*.webm"
        ],
        "audio": [
            "*.aiff",
            "*.au",
            "*.aup3",
            "*.cdda",
            "*.wav",
            "*.flac",
            "*.wma",
            "*.mp3",
            "*.m4a",
            "*.aac",
            "*.ogg",
            "*.mod",
            "*.nsf",
            "*.mid",
            "*.midi",
            "*.ftm",
            "*.gp",
            "*.ly",
            "*.mus",
            "*.musx",
            "*.mxl",
            "*.mscx",
            "*.mscz",
            "*.sib",
            "*.als",
            "*.alc",
            "*.alp",
            "*.aup",
            "*.band",
            "*.cpr",
            "*.drm",
            "*.flp",
            "*.logic",
            "*.mmp",
            "*.mmpz",
            "*.ptx",
            "*.ptf"
        ],
        "images": [
            "*.psd",
            "*.xcf",
            "*.png",
            "*.jpg",
            "*.jpeg",
            "*.gif",
            "*.webp",
            "*.bmp",
            "*.svg"
        ],
        "arch_exec": [
            "*.7z",
            "*.appx",
            "*.bin",
            "*.bz2",
            "*.cab",
            "*.dmg",
            "*.deb",
            "*.exe",
            "*.gz",
            "*.jar",
            "*.lz",
            "*.rar",
            "*.xz",
            "*.zip",
            "*.iso",
            "*.dd",
            "*.img",
            "*.msi",
            "*.torrent",
            "*.vhd",
            "*.appinstaller",
            "*.apk",
            "*.dll"
        ],
        "3d_models": [
            "*.stl",
            "*.scad",
            "*.mix",
            "*.3mf"
        ],
        "roms": [
            "*.z64",
            "*.n64",
            "*.gba",
            "*.nes",
            "*.sav",
            "*.sgm",
            "*.bsz",
            "*.sfc",
            "*.srm",
            "*.xci"
        ]
    }
'@

    # Convert file types to a pwsh object format.
    $filetypes = ConvertFrom-Json $filetypes_json

    Write-Debug "Using path $Path"
    Push-Location $Path
    Write-Debug "Now in path $PWD"

    $filetypes | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
        # Create new directory if not present
        if (-Not (Test-Path ./$_)) {
            New-Item -ItemType Directory $_
        }
        $items = Get-ChildItem $filetypes.$_
        $count = ($items | Measure-Object).Count
        Write-Verbose "Moving $count items to the $_ folder..."
        Get-ChildItem $filetypes.$_ | Move-Item -Destination ./$_ 
    }

    Pop-Location

}
