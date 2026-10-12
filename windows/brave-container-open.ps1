# Open an ext+container:// link in a Brave container (Windows).
#
#   ext+container://GOOGLE/https://claude.ai/new
#   ext+container:name=GOOGLE&url=https%3A%2F%2Fclaude.ai&temporary=true
#   brave-container-open.ps1 GOOGLE https://claude.ai/new
#
# Container names "@temp" and "@temp:Name" open a temporary container.
# Requires Brave 1.95+ and Containers enabled in brave://settings/braveContent.

param([Parameter(Position = 0)][string]$First, [Parameter(Position = 1)][string]$Second)

$ErrorActionPreference = 'Stop'

# Set this to override Brave detection, e.g. for Beta/Nightly builds.
$BraveExe = ''

function Fail($msg) {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($msg, 'Brave container link') | Out-Null
    exit 1
}

$name = ''; $url = ''; $temporary = $false

if ($Second) {
    $name = $First; $url = $Second
} elseif ($First) {
    if ($First -notmatch '^ext\+container:') { Fail "Not an ext+container link: $First" }
    $rest = $First -replace '^ext\+container:', ''
    if ($rest.StartsWith('//')) {
        $rest = $rest.Substring(2)
        $slash = $rest.IndexOf('/')
        if ($slash -lt 1) { Fail "Missing URL in: $First" }
        $name = [Uri]::UnescapeDataString($rest.Substring(0, $slash))
        $url = $rest.Substring($slash + 1)
    } else {
        foreach ($p in $rest.Split('&')) {
            $kv = $p.Split('=', 2)
            $val = if ($kv.Count -gt 1) { [Uri]::UnescapeDataString($kv[1].Replace('+', ' ')) } else { '' }
            switch ($kv[0]) {
                'name' { $name = $val }
                'url' { $url = $val }
                'temporary' { $temporary = ($val -eq 'true') }
            }
        }
    }
} else {
    Fail "Usage: brave-container-open.ps1 'ext+container://NAME/URL'"
}

# Some handlers collapse "https://" to "https:/" (or add a trailing slash); repair it.
$url = $url -replace '^(https?):/(?!/)', '$1://'

# Only web URLs: keeps links from smuggling switches or local files into Brave.
if ($url -notmatch '^https?://\S+$') { Fail "Only http(s) URLs are allowed, got: $url" }
if (-not $name) { Fail 'Missing container name' }

if ($name -eq '@temp') { $temporary = $true; $name = '' }
elseif ($name.StartsWith('@temp:')) { $temporary = $true; $name = $name.Substring(6) }

if (-not $BraveExe) {
    $candidates = @(
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\Application\brave.exe",
        "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe",
        "${env:ProgramFiles(x86)}\BraveSoftware\Brave-Browser\Application\brave.exe"
    )
    $BraveExe = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
}
if (-not $BraveExe) { Fail "Couldn't find brave.exe. Set `$BraveExe at the top of this script." }

$argList = @()
if ($temporary) { $argList += '--temporary-container' }
if ($name) { $argList += ('"--container=' + $name.Replace('"', '') + '"') }
# "--" ends switch parsing, so the URL can never be read as a switch.
$argList += '--'
$argList += ('"' + $url.Replace('"', '%22') + '"')

Start-Process -FilePath $BraveExe -ArgumentList $argList
