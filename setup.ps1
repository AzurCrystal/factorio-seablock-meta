#Requires -Version 5.1
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SeaBlockTrunk = Join-Path $ScriptDir 'trunk'

# Check prerequisites
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error 'Error: git is required but not found.'
    exit 1
}

$FactorioVersion = '2.0.72'
$FactorioArchive = "factorio_win_$FactorioVersion.zip"
$FactorioDownloadUrl = "https://factorio.com/get-download/$FactorioVersion/alpha/win64-manual"

$response = Read-Host "Download and extract Factorio $FactorioVersion? [y/N]"
if ($response -imatch '^y') {
    $archivePath = Join-Path $ScriptDir $FactorioArchive
    if (-not (Test-Path $archivePath)) {
        Write-Host "Downloading $FactorioArchive..."
        Invoke-WebRequest -Uri $FactorioDownloadUrl -OutFile $archivePath
    }
    $FactorioDir = Join-Path $ScriptDir 'factorio'
    if (-not (Test-Path $FactorioDir)) {
        Write-Host "Extracting $FactorioArchive..."
        Expand-Archive -Path $archivePath -DestinationPath $ScriptDir
    }
    $SeaBlockMods = Join-Path $FactorioDir 'mods'
} else {
    $SeaBlockMods = Join-Path $env:APPDATA 'Factorio\mods'
}

$TrunkPack = @(
    'SeaBlock\SeaBlock'
    'SeaBlock\SeaBlockMetaPack'
    'SpaceMod'
    'ScienceCostTweakerM'
    'Angelmods\angelsbioprocessing'
    'Angelmods\angelsrefining'
    'Angelmods\angelssmelting'
    'Angelmods\angelspetrochem'
    'Angelmods\angelsaddons-storage'
    'Angelmods\angelsbioprocessinggraphics'
    'Angelmods\angelsrefininggraphics'
    'Angelmods\angelspetrochemgraphics'
    'Angelmods\angelssmeltinggraphics'
    'bobsmods\bobelectronics'
    'bobsmods\boblibrary'
    'bobsmods\boblogistics'
    'bobsmods\bobores'
    'bobsmods\bobplates'
    'bobsmods\bobassembly'
    'bobsmods\bobenemies'
    'bobsmods\bobequipment'
    'bobsmods\bobinserters'
    'bobsmods\bobmining'
    'bobsmods\bobmodules'
    'bobsmods\bobpower'
    'bobsmods\bobrevamp'
    'bobsmods\bobtech'
    'bobsmods\bobwarfare'
    'CircuitProcessing\CircuitProcessing'
    'LandfillPainting\LandfillPainting'
    'reskins-angels'
    'reskins-bobs'
    'reskins-compatibility'
)

# Pull latest changes from remote
Write-Host 'Pulling latest changes from remote...'
git -C $ScriptDir pull --ff-only
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Error: git pull failed.'
    exit 1
}

# Pull all submodules to the commit recorded in the parent repo
Write-Host 'Updating submodules...'
git -C $ScriptDir submodule update --init --recursive
if ($LASTEXITCODE -ne 0) {
    Write-Error 'Error: submodule update failed.'
    exit 1
}

# Ensure mods directory exists
New-Item -ItemType Directory -Force -Path $SeaBlockMods | Out-Null

function New-ModSymlink {
    param(
        [string]$Target,
        [string]$Dest
    )

    if (Test-Path $Dest) {
        $item = Get-Item $Dest -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            Write-Host "Skipping: $Dest is already a symlink"
            return
        }
        if ($item.PSIsContainer) {
            Write-Error "Error: $Dest is a directory"
            return
        }
    }

    New-Item -ItemType Junction -Path $Dest -Target $Target | Out-Null
    Write-Host "Linked: $Dest"
}

# Create junctions for each mod directory
foreach ($mod in $TrunkPack) {
    $target = Join-Path $SeaBlockTrunk $mod
    if (Test-Path $target -PathType Container) {
        $modName = Split-Path -Leaf $mod
        $dest = Join-Path $SeaBlockMods $modName
        New-ModSymlink -Target $target -Dest $dest
    }
}

# Copy zip mods directly into mods directory
foreach ($zip in (Get-ChildItem -Path $SeaBlockTrunk -Filter '*.zip' -File)) {
    $dest = Join-Path $SeaBlockMods $zip.Name
    if (Test-Path $dest) {
        Write-Host "Skipping: $dest already exists"
    } else {
        Copy-Item -Path $zip.FullName -Destination $dest
        Write-Host "Copied: $($zip.Name)"
    }
}

Write-Host 'Done.'
