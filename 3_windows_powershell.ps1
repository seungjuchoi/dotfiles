# PowerShell 초기 설정 스크립트
# 관리자 권한으로 실행하세요

Write-Host "PowerShell 환경 설정을 시작합니다..." -ForegroundColor Green

# 1. 실행 정책 설정
Write-Host "실행 정책을 설정합니다..." -ForegroundColor Yellow
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# 2. PowerShell 프로필 생성 및 기본 설정
Write-Host "PowerShell 프로필을 설정합니다..." -ForegroundColor Yellow
if (!(Test-Path -Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
}

# 3. 필수 모듈 설치
Write-Host "필수 모듈을 설치합니다..." -ForegroundColor Yellow
$modules = @(
    "PSReadLine",
    "Terminal-Icons",
    "z",
    "PSFzf",
    "posh-git"
)

foreach ($module in $modules) {
    if (!(Get-Module -ListAvailable -Name $module)) {
        Write-Host "설치 중: $module" -ForegroundColor Cyan
        Install-Module -Name $module -Force -Scope CurrentUser
    }
}

# 4. Chocolatey 설치 (패키지 관리자)
Write-Host "Chocolatey 패키지 관리자를 설치합니다..." -ForegroundColor Yellow
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        # 환경 변수 새로고침
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
        
        # Chocolatey 경로 직접 추가
        $chocoPath = "$env:ProgramData\chocolatey\bin"
        if (Test-Path $chocoPath) {
            $env:PATH = $env:PATH + ";" + $chocoPath
        }
    }
    catch {
        Write-Host "Chocolatey 설치 중 오류 발생: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "수동으로 설치하거나 다른 패키지 관리자를 사용하세요." -ForegroundColor Yellow
    }
}

# 5. 필수 도구들 설치
Write-Host "필수 도구들을 설치합니다..." -ForegroundColor Yellow

# Chocolatey가 정상적으로 설치되었는지 확인
if (Get-Command choco -ErrorAction SilentlyContinue) {
    $tools = @(
        "fzf",
        "ripgrep",
        "fd",
        "bat",
        "eza",
        "zoxide",
        "starship",
        "lazygit",
        "neovim",
        "git"
    )

    foreach ($tool in $tools) {
        if (!(Get-Command $tool -ErrorAction SilentlyContinue)) {
            Write-Host "설치 중: $tool" -ForegroundColor Cyan
            try {
                choco install $tool -y
            }
            catch {
                Write-Host "  $tool 설치 실패: $($_.Exception.Message)" -ForegroundColor Red
            }
        } else {
            Write-Host "  $tool 이미 설치됨" -ForegroundColor Green
        }
    }
} else {
    Write-Host "Chocolatey가 설치되지 않았습니다." -ForegroundColor Red
    Write-Host "대안 방법:" -ForegroundColor Yellow
    Write-Host "1. PowerShell을 재시작한 후 다시 실행해보세요." -ForegroundColor Cyan
    Write-Host "2. 또는 수동으로 다음 도구들을 설치하세요:" -ForegroundColor Cyan
    Write-Host "   - zoxide: https://github.com/ajeetdsouza/zoxide/releases" -ForegroundColor White
    Write-Host "   - starship: https://starship.rs/guide/#step-1-install-starship" -ForegroundColor White
    Write-Host "   - fzf: https://github.com/junegunn/fzf/releases" -ForegroundColor White
}

# 6. PowerShell 프로필 구성
Write-Host "PowerShell 프로필을 구성합니다..." -ForegroundColor Yellow

$profileContent = @'
# UTF-8 인코딩 설정
$OutputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
chcp 65001 > $null

# PowerShell 프로필 설정

# PSReadLine 설정 (Emacs 키바인딩)
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineOption -Colors @{ InlinePrediction = '#8A8A8A' }

# 히스토리 설정
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# 모듈 import
Import-Module Terminal-Icons
Import-Module z
Import-Module PSFzf
Import-Module posh-git

# zoxide 초기화
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    try {
        Invoke-Expression (& { (zoxide init powershell | Out-String) })
    } catch {
        Write-Host "zoxide 초기화 실패: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "수동으로 다음 명령어를 실행하세요: Invoke-Expression (& { (zoxide init powershell | Out-String) })" -ForegroundColor Yellow
    }
}

# starship 프롬프트 초기화
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# 유용한 별칭 설정
Set-Alias -Name l -Value Get-ChildItem
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name la -Value Get-ChildItem
Set-Alias -Name grep -Value Select-String
Set-Alias -Name which -Value Get-Command
Set-Alias -Name touch -Value New-Item

# nvim 별칭 설정
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias -Name vi -Value nvim
    Set-Alias -Name vim -Value nvim
}

# eza 별칭 (ls 대체)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Set-Alias -Name ls -Value eza
    function ll { eza -l @args }
    function la { eza -la @args }
    function tree { eza --tree @args }
}

# bat 별칭 (cat 대체)
if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias -Name cat -Value bat
}

# lazygit 별칭 (lg)
if (Get-Command lazygit -ErrorAction SilentlyContinue) {
    Set-Alias -Name lg -Value lazygit
}

# 편리한 함수들
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }

function mkcd($dir) {
    New-Item -ItemType Directory -Path $dir -Force
    Set-Location $dir
}

function Get-PublicIP {
    (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
}

function Get-Weather($city = "Seoul") {
    (Invoke-WebRequest -Uri "https://wttr.in/$city" -UseBasicParsing).Content
}

function Start-Here {
    explorer .
}

function Get-DirSize {
    param([string]$Path = ".")
    Get-ChildItem -Path $Path -Recurse -File | Measure-Object -Property Length -Sum | 
    ForEach-Object { [math]::Round($_.Sum / 1MB, 2) }
}

# 시스템 정보
function sysinfo {
    Write-Host "시스템 정보:" -ForegroundColor Green
    Write-Host "OS: $(Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption)"
    Write-Host "버전: $(Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Version)"
    Write-Host "아키텍처: $(Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty OSArchitecture)"
    Write-Host "메모리: $([math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)) GB"
    Write-Host "PowerShell: $($PSVersionTable.PSVersion)"
}

# 환영 메시지
Write-Host "PowerShell 환경이 준비되었습니다! " -ForegroundColor Green -NoNewline
Write-Host "🚀" -ForegroundColor Yellow
Write-Host "사용 가능한 명령어:" -ForegroundColor Yellow
Write-Host "  sysinfo  - 시스템 정보 표시"
Write-Host "  mkcd     - 디렉토리 생성 후 이동"
Write-Host "  ..       - 상위 디렉토리로 이동"
Write-Host "  z <path> - 빠른 디렉토리 이동 (zoxide)"
Write-Host ""
'@

# 프로필에 내용 덮어쓰기
$profileContent | Out-File -FilePath $PROFILE -Encoding UTF8

# 7. Starship 설정 파일 생성
Write-Host "Starship 프롬프트를 설정합니다..." -ForegroundColor Yellow
$starshipConfig = @'
# Starship 설정
format = """
[](#9A348E)\
$username\
[](bg:#DA627D fg:#9A348E)\
$directory\
[](fg:#DA627D bg:#FCA17D)\
$git_branch\
$git_status\
[](fg:#FCA17D bg:#86BBD8)\
$nodejs\
$rust\
$golang\
$php\
$python\
[](fg:#86BBD8 bg:#06969A)\
$docker_context\
[](fg:#06969A bg:#33658A)\
$time\
[ ](fg:#33658A)\
"""

[username]
show_always = true
style_user = "bg:#9A348E"
style_root = "bg:#9A348E"
format = '[  $user ]($style)'

[directory]
style = "bg:#DA627D"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
symbol = ""
style = "bg:#FCA17D"
format = '[ $symbol $branch ]($style)'

[git_status]
style = "bg:#FCA17D"
format = '[$all_status$ahead_behind ]($style)'

[nodejs]
symbol = ""
style = "bg:#86BBD8"
format = '[ $symbol ($version) ]($style)'

[rust]
symbol = ""
style = "bg:#86BBD8"
format = '[ $symbol ($version) ]($style)'

[golang]
symbol = ""
style = "bg:#86BBD8"
format = '[ $symbol ($version) ]($style)'

[php]
symbol = ""
style = "bg:#86BBD8"
format = '[ $symbol ($version) ]($style)'

[python]
symbol = ""
style = "bg:#86BBD8"
format = '[ $symbol ($version) ]($style)'

[docker_context]
symbol = ""
style = "bg:#06969A"
format = '[ $symbol $context ]($style)'

[time]
disabled = false
time_format = "%R"
style = "bg:#33658A"
format = '[ ♥ $time ]($style)'
'@

$starshipConfigPath = "$env:USERPROFILE\.config\starship.toml"
if (!(Test-Path (Split-Path $starshipConfigPath))) {
    New-Item -ItemType Directory -Path (Split-Path $starshipConfigPath) -Force
}
$starshipConfig | Out-File -FilePath $starshipConfigPath -Encoding UTF8

# 8. LazyVim 설치
Write-Host "LazyVim을 설치합니다..." -ForegroundColor Yellow
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    $nvimConfigPath = "$env:LOCALAPPDATA\nvim"
    
    # 기존 nvim 설정 백업
    if (Test-Path $nvimConfigPath) {
        $backupPath = "$env:LOCALAPPDATA\nvim.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Write-Host "기존 nvim 설정을 백업합니다: $backupPath" -ForegroundColor Yellow
        Move-Item $nvimConfigPath $backupPath
    }
    
    # LazyVim 설치
    try {
        Write-Host "LazyVim을 클론합니다..." -ForegroundColor Cyan
        git clone https://github.com/LazyVim/starter $nvimConfigPath
        
        # .git 폴더 제거 (optional)
        if (Test-Path "$nvimConfigPath\.git") {
            Remove-Item "$nvimConfigPath\.git" -Recurse -Force
        }
        
        Write-Host "LazyVim 설치가 완료되었습니다!" -ForegroundColor Green
        Write-Host "처음 nvim 실행 시 플러그인들이 자동으로 설치됩니다." -ForegroundColor Cyan
    }
    catch {
        Write-Host "LazyVim 설치 중 오류 발생: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "수동 설치 방법:" -ForegroundColor Yellow
        Write-Host "git clone https://github.com/LazyVim/starter $nvimConfigPath" -ForegroundColor White
    }
} else {
    Write-Host "nvim이 설치되지 않았습니다. LazyVim 설치를 건너뜁니다." -ForegroundColor Yellow
}

# 9. SSH 서버 설정
Write-Host "SSH 서버를 설정합니다..." -ForegroundColor Yellow

# OpenSSH Server 설치 확인 및 설치
Write-Host "OpenSSH Server 설치 상태를 확인합니다..." -ForegroundColor Cyan

# 먼저 SSH 서비스 존재 여부로 설치 상태 확인 (더 안정적)
$sshdService = Get-Service -Name sshd -ErrorAction SilentlyContinue
if ($sshdService) {
    Write-Host "SSH 서비스가 존재합니다. OpenSSH Server가 설치되어 있습니다." -ForegroundColor Green
} else {
    Write-Host "SSH 서비스가 존재하지 않습니다. OpenSSH Server 설치를 시도합니다..." -ForegroundColor Yellow
    
    try {
        # winget을 사용한 설치 시도
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-Host "winget으로 OpenSSH Server를 설치합니다..." -ForegroundColor Cyan
            winget install Microsoft.OpenSSH.Beta
            Write-Host "OpenSSH Server 설치 완료" -ForegroundColor Green
        } else {
            Write-Host "winget을 찾을 수 없습니다. Windows Capability로 설치를 시도합니다..." -ForegroundColor Yellow
            Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
            Write-Host "OpenSSH Server 설치 완료" -ForegroundColor Green
        }
    } catch {
        Write-Host "OpenSSH Server 자동 설치 실패: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "수동 설치 방법:" -ForegroundColor Yellow
        Write-Host "1. 설정 → 앱 → 선택적 기능 → OpenSSH Server 추가" -ForegroundColor White
        Write-Host "2. 또는 PowerShell 관리자 권한으로: Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0" -ForegroundColor White
    }
}

# SSH 서비스 시작 및 자동 시작 설정
Write-Host "SSH 서비스 상태를 확인합니다..." -ForegroundColor Cyan
$sshdService = Get-Service -Name sshd -ErrorAction SilentlyContinue

if ($sshdService) {
    if ($sshdService.Status -eq "Running") {
        Write-Host "SSH 서비스가 이미 실행 중입니다." -ForegroundColor Green
    } else {
        Write-Host "SSH 서비스를 시작합니다..." -ForegroundColor Cyan
        try {
            Start-Service sshd
            Write-Host "SSH 서비스 시작 완료" -ForegroundColor Green
        } catch {
            Write-Host "SSH 서비스 시작 실패: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    # 자동 시작 설정 확인
    if ($sshdService.StartType -ne "Automatic") {
        Write-Host "SSH 서비스 자동 시작을 설정합니다..." -ForegroundColor Cyan
        try {
            Set-Service -Name sshd -StartupType 'Automatic'
            Write-Host "SSH 서비스 자동 시작 설정 완료" -ForegroundColor Green
        } catch {
            Write-Host "SSH 서비스 자동 시작 설정 실패: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "SSH 서비스 자동 시작이 이미 설정되어 있습니다." -ForegroundColor Green
    }
} else {
    Write-Host "SSH 서비스를 찾을 수 없습니다. OpenSSH Server 설치를 확인하세요." -ForegroundColor Red
}

# PowerShell을 SSH 기본 셸로 설정
Write-Host "SSH 기본 셸 설정을 확인합니다..." -ForegroundColor Cyan
try {
    # 현재 기본 셸 확인
    $currentShell = Get-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -ErrorAction SilentlyContinue
    
    if ($currentShell) {
        Write-Host "현재 SSH 기본 셸: $($currentShell.DefaultShell)" -ForegroundColor White
        
        # PowerShell 7 (pwsh) 경로 찾기
        $pwshPath = Get-Command pwsh -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
        
        if ($pwshPath -and $currentShell.DefaultShell -ne $pwshPath) {
            Write-Host "PowerShell 7으로 기본 셸을 업데이트합니다..." -ForegroundColor Cyan
            New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value $pwshPath -PropertyType String -Force
            Write-Host "SSH 기본 셸 업데이트 완료: $pwshPath" -ForegroundColor Green
        } elseif ($pwshPath) {
            Write-Host "SSH 기본 셸이 이미 올바르게 설정되어 있습니다." -ForegroundColor Green
        } else {
            Write-Host "PowerShell 7을 찾을 수 없습니다!" -ForegroundColor Red
            Write-Host "현재 설정을 유지합니다." -ForegroundColor Yellow
        }
    } else {
        # 기본 셸이 설정되지 않은 경우
        $pwshPath = Get-Command pwsh -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
        
        if ($pwshPath) {
            Write-Host "PowerShell 7을 SSH 기본 셸로 설정합니다..." -ForegroundColor Cyan
            Write-Host "PowerShell 7 경로: $pwshPath" -ForegroundColor White
            New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value $pwshPath -PropertyType String -Force
            Write-Host "SSH 기본 셸 설정 완료" -ForegroundColor Green
        } else {
            Write-Host "PowerShell 7을 찾을 수 없습니다!" -ForegroundColor Red
            Write-Host "SSH 기본 셸 설정을 건너뜁니다." -ForegroundColor Yellow
            Write-Host "PowerShell 7 설치 후 다음 명령어로 수동 설정하세요:" -ForegroundColor Yellow
            Write-Host "New-ItemProperty -Path `"HKLM:\SOFTWARE\OpenSSH`" -Name DefaultShell -Value `"C:\Program Files\PowerShell\7\pwsh.exe`" -PropertyType String -Force" -ForegroundColor White
        }
    }
} catch {
    Write-Host "SSH 기본 셸 설정 실패: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "수동 설정이 필요할 수 있습니다." -ForegroundColor Yellow
}

# 방화벽 설정
Write-Host "방화벽 SSH 포트 규칙을 확인합니다..." -ForegroundColor Cyan
$firewallRule = Get-NetFirewallRule -Name sshd -ErrorAction SilentlyContinue

if ($firewallRule) {
    Write-Host "SSH 방화벽 규칙이 이미 존재합니다." -ForegroundColor Green
} else {
    Write-Host "방화벽에서 SSH 포트를 허용합니다..." -ForegroundColor Cyan
    try {
        New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
        Write-Host "방화벽 설정 완료" -ForegroundColor Green
    } catch {
        Write-Host "방화벽 설정 실패: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "수동으로 방화벽에서 포트 22를 허용해주세요." -ForegroundColor Yellow
    }
}

# SSH 상태 확인
Write-Host "SSH 서비스 상태 확인..." -ForegroundColor Cyan
try {
    $sshStatus = Get-Service sshd
    Write-Host "SSH 서비스 상태: $($sshStatus.Status)" -ForegroundColor Green
    
    $sshPort = Get-NetTCPConnection -LocalPort 22 -ErrorAction SilentlyContinue
    if ($sshPort) {
        Write-Host "SSH 포트 22 리스닝 중" -ForegroundColor Green
    } else {
        Write-Host "SSH 포트 22 리스닝 안함" -ForegroundColor Yellow
    }
} catch {
    Write-Host "SSH 상태 확인 실패: $($_.Exception.Message)" -ForegroundColor Red
}

# 네트워크 IP 주소 표시
Write-Host "네트워크 IP 주소:" -ForegroundColor Cyan
try {
    $ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -ne "127.0.0.1" }
    foreach ($ip in $ipAddresses) {
        Write-Host "  $($ip.InterfaceAlias): $($ip.IPAddress)" -ForegroundColor White
    }
} catch {
    Write-Host "IP 주소 확인 실패" -ForegroundColor Red
}

# 완료 메시지
Write-Host ""
Write-Host "설정이 완료되었습니다! " -ForegroundColor Green -NoNewline
Write-Host "🎉" -ForegroundColor Yellow
Write-Host "다음 단계:" -ForegroundColor Yellow
Write-Host "1. PowerShell을 재시작하거나 다음 명령어를 실행하세요:" -ForegroundColor Cyan
Write-Host "   . `$PROFILE" -ForegroundColor White
Write-Host "2. 터미널 폰트를 Nerd Font로 변경하는 것을 권장합니다." -ForegroundColor Cyan
Write-Host "   (예: FiraCode Nerd Font, JetBrains Mono Nerd Font)" -ForegroundColor White
Write-Host "3. Windows Terminal을 사용하면 더 나은 경험을 할 수 있습니다." -ForegroundColor Cyan
Write-Host "4. SSH 연결을 위해 계정에 암호를 설정하세요:" -ForegroundColor Cyan
Write-Host "   net user [사용자명] [암호]" -ForegroundColor White
Write-Host "5. macOS에서 SSH 연결 테스트:" -ForegroundColor Cyan
Write-Host "   ssh [사용자명]@[Windows IP 주소]" -ForegroundColor White

Read-Host "설정을 적용하려면 Enter를 눌러주세요..."

# 프로필 다시 로드
. $PROFILE
