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
        "git",
        "mingw"
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

# 5-1. uv 설치 (공식 스크립트 사용)
Write-Host "uv 패키지 매니저를 설치합니다..." -ForegroundColor Yellow
if (!(Get-Command uv -ErrorAction SilentlyContinue)) {
    try {
        Write-Host "설치 중: uv" -ForegroundColor Cyan
        irm https://astral.sh/uv/install.ps1 | iex
    }
    catch {
        Write-Host "  uv 설치 실패: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "  uv 이미 설치됨" -ForegroundColor Green
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

# uv 자동 완성 설정
if (Get-Command uv -ErrorAction SilentlyContinue) {
    Invoke-Expression (&uv generate-completions --shell powershell | Out-String)
}

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
Import-Module PSFzf
Import-Module posh-git

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


Invoke-Expression (& { (zoxide init powershell | Out-String) })


'@

# 프로필에 내용 덮어쓰기
$profileContent | Out-File -FilePath $PROFILE -Encoding UTF8

# 7. Starship 설정 파일 생성
Write-Host "Starship 프롬프트를 설정합니다..." -ForegroundColor Yellow
$starshipConfig = @'
# Starship 설정
format = """
$directory\
$git_branch\
$git_status\
$python\
$nodejs\
$rust\
$golang\
$character\
"""

[directory]
style = "bold cyan"
format = "[$path]($style) "
truncation_length = 1
fish_style_pwd_dir_length = 1

[git_branch]
symbol = " "
style = "bold purple"
format = '[$symbol$branch]($style)'

[git_status]
style = "bold red"
format = '[$all_status$ahead_behind]($style)'

[python]
symbol = " "
style = "bold green"
format = '[$symbol$version($virtualenv)]($style)'

[nodejs]
symbol = " "
style = "bold green"
format = '[$symbol$version]($style)'

[rust]
symbol = " "
style = "bold orange"
format = '[$symbol$version]($style)'

[golang]
symbol = " "
style = "bold blue"
format = '[$symbol$version]($style)'

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
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
