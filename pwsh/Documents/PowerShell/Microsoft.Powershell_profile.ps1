
using namespace System.Management.Automation.Language

Import-Module Terminal-Icons
Import-Module PSFzf

oh-my-posh init pwsh --config "$HOME\.config\oh-my-posh\montys_custom.omp.json" | Invoke-Expression
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Import local config
$localConfigPath = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.local.ps1"
if (Test-Path $localConfigPath) {
	. $localConfigPath
}

Set-Alias ls GetChildItemsSortByNames
Set-Alias lg lazygit
Set-Alias g git
Set-Alias d dotnet
Set-Alias e explorer
Set-Alias grep Select-String
Set-Alias gmain Update-BasedOnMain
Set-Alias ga GitFuzzyAdd
Set-Alias cf FuzzyGoTo
Set-Alias which Get-ExecutablePath
Set-Alias zl Invoke-ZLocation
Set-Alias cw Create-Worktree

# FZF - Git
Set-Alias fgs Invoke-FuzzyGitStatus
Set-Alias fgb Change-Branch
Set-Alias fgc Change-Commit
Set-Alias fgf Fix-Commit
Set-Alias fgr Rebase-Commit
Set-Alias fgt Reset-Commit
Set-Alias fgw Change-Worktree
Set-Alias op Open-Project
Set-Alias os Open-Solution
Set-Alias oc Open-Config

$PsReadLineOptions = @{
	PredictionSource    = "History"
	PredictionViewStyle = "ListView"
	EditMode            = "vi"
}
Set-PSReadLineOption @PsReadLineOptions

Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
Set-PSReadLineKeyHandler -Chord Ctrl+p -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Chord Ctrl+n -Function HistorySearchForward

Set-PSFzfOption -TabExpansion -GitKeyBindings
# $env:_PSFZF_FZF_DEFAULT_OPTS = '--height 50%'
# Set shell to fzf uses pwsh instead of cmd
# TODO: Fuzzy finding files withing with with plugin does not work
$env:SHELL = 'pwsh'

# Overwrites the preview-window options using `bind='start:'`
$env:_PSFZF_FZF_DEFAULT_OPTS = "$env:FZF_DEFAULT_OPTS --bind='start:change-preview-window(hidden)' --height 50%"

<#
	.DESCRIPTION
	Assumes creating worktree with new branch
#>
Function Create-Worktree([String]$branchName) {
	$worktreeFolderName = $branchName.Split('/')[1]
	git worktree add -b $branchName $worktreeFolderName master
	zoxide add $(Join-Path -Path $(Get-Location) -ChildPath $worktreeFolderName)
}

Set-PSReadLineKeyHandler -Chord Ctrl+Shift+O -ScriptBlock { Open-Project }

Function y {
	$tmp = [System.IO.Path]::GetTempFileName()
	yazi $args --cwd-file="$tmp"
	$cwd = Get-Content -Path $tmp -Encoding UTF8
	if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
		Set-Location -LiteralPath ([System.IO.Path]::GetFullPath($cwd))
	}
	Remove-Item -Path $tmp
}

function Get-GitFzfArguments() {
	# take from https://github.com/junegunn/fzf-git.sh/blob/f72ebd823152fa1e9b000b96b71dd28717bc0293/fzf-git.sh#L89
	return @{
		Ansi          = $true
		Layout        = "reverse"
		Multi         = $true
		Height        = '50%'
		MinHeight     = 20
		Border        = $true
		Color         = 'header:italic:underline'
		PreviewWindow = 'right,50%,border-left'
		Bind          = @('ctrl-/:change-preview-window(down,50%,border-top|hidden|)')
	}
}

function Get-ColorAlways($setting = ' --color=always') {
	# if ($RunningInWindowsTerminal -or -not $IsWindowsCheck) {
	#     return $setting
	# }
	# else {
	return ''
	# }
}

function Invoke-PsFzfGitHashesV2() {
	# $previewCmd = "${script:bashPath} \""" + $(Join-Path $PsScriptRoot 'helpers/PsFzfGitHashes-Preview.sh') + "\"" {}" + $(Get-ColorAlways) + " \""$pwd\"""
	$result = @()

	$fzfArguments = Get-GitFzfArguments
	$gitLogCmd = 'git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" ' + $(Get-ColorAlways).Trim() + " --graph"
	echo $gitLogCmd
	& $gitLogCmd
	# & git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" $(Get-ColorAlways).Trim() --graph | `
	return;
	Invoke-Expression "& $gitLogCmd" | `
		Invoke-Fzf @fzfArguments -NoSort
	# -BorderLabel "$script:hashesString" `
	# -Preview "$previewCmd" | ForEach-Object {
	# if ($_ -match '\d\d-\d\d-\d\d\s+([a-f0-9]+)\s+') {
	#     $result += $Matches.1
	# }
	# }

	$result
}

Function Open-Solution {
	start $(Get-ChildItem -Filter *.sln -File | Select -First 1)
}

# Assumes ticket number in branch name (eg. SEB-125-new-feature)
Function CreatePR {
	$branchParts
	try {
		$branchParts = (git branch --show-current).Split('/')[1].Split('-')
	}
 catch {
		Write-Host "Not a git repo or invalid branch name!" -ForegroundColor Red
		return
	}
	$ticket = $branchParts[0..1] | Join-String -Separator '-'
	# Maybe this tempalte file is not needed
	$prTemplate = Get-Content D:\pull_request_template.md
	$prContent = $prTemplate.Replace('$ticket', $ticket)
	$commitMessages = $(git log --pretty='* %s' master..HEAD --no-merges)
	$sb = [System.Text.StringBuilder]::new()
	foreach ($commitMessage in $commitMessages) {
		$sb.AppendLine($commitMessage)
	}
	$sb.AppendLine()
	$sb.AppendLine($prContent)
	$finalContent = $sb.ToString()
	$featurePart = $branchParts[2..($branchParts.Length - 1)] | Join-String -Separator ' '
	$featureName = $featurePart.Substring(0, 1).ToUpper() + $featurePart.Substring(1)
	$prTitle = '[' + $ticket + '] ' + $featureName
	Write-Host "Pushing branch: $(git branch --show-current)" -ForegroundColor Green

		git push -u origin HEAD
	if ($? -ne $true) {
		Write-Host "Failed to push branch" -ForegroundColor Red
		return
	}

	Write-Host "Creating PR: $prTitle..." -ForegroundColor Green
	gh pr create --body $finalContent --title $prTitle --web
}

Function Get-ExecutablePath($executable) {
	(Get-Command $executable).Path
}

Function Fix-Commit {
	git commit --fixup $(Invoke-PsFzfGitHashes)
}
$env:XDG_CONFIG_HOME = "$HOME\.config"

Function Rebase-Commit {
	git rebase --interactive $(Invoke-PsFzfGitHashes)
}

Function Reset-Commit {
	git reset $(Invoke-PsFzfGitHashes)
}

Function Change-Branch {
	git switch $(Invoke-PsFzfGitBranches)
}

Function Change-Worktree {
	git worktree list | Invoke-Fzf -Layout reverse -Height 50% | ForEach-Object { $_.Split(" ")[0] } | Set-Location
	# Get-ChildItem | Where-Object { $_.Name -like '*.sln' } | ForEach-Object { start $_.Name }
}

# Required for glow to show properly in fzf preview
$env:COLORTERM = 'truecolor'
$env:CLICOLOR_FORCE = 1

Function Open-Config {
	Get-ChildItem -Path ~/.dotfiles -File -Recurse `
	| Select -ExpandProperty FullName `
	| Where-Object { $_ -notmatch '~|.gitignore' } `
	| fzf --preview='bat {} --color=always'
}

Function Open-Project {
	Get-ChildItem -Dept 2 -Path D:\ *.sln `
	| Select -ExpandProperty DirectoryName `
	| fzf `
		--layout reverse `
		--header " ^r rider ^v vscode" `
		--preview 'glow -p -s dark $(Get-ChildItem -Path {} -File README.md | Select-Object -First 1)' `
		--bind 'ctrl-r:execute(Start-Process $(Get-ChildItem -Path {} -Filter *.sln | Select--Object -First 1))+abort' `
		--bind 'ctrl-v:execute(code {})+abort'
}

Function Change-Commit {
	git switch --detach $(Invoke-PsFzfGitHashes)
}

Function GitFuzzyAdd($arg) {
	# "&" Invocation operator and script block
	& {
		# Get untracked files
		git ls-files --other --exclude-standard;
		# Get changed files
		git diff --name-only
	} `
	| Invoke-Fzf `
		-Multi `
		-CaseInsensitive `
		-Extended `
		-Preview 'git diff --color=always {} | diff-so-fancy' `
		-PreviewWindow 'down,50%'
	| ForEach-Object { git add $_ -$arg }
}

Function GetChildItemsSortByNames {
	Get-ChildItem -Force | Format-Wide
}

Function FuzzyGoTo {
	Get-ChildItem -Directory -Recurse | Invoke-Fzf | ForEach-Object { cd $_ }
}

# PowerShell parameter completion shim for the winget CLI
Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
	param($wordToComplete, $commandAst, $cursorPosition)
	[Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
	$Local:word = $wordToComplete.Replace('"', '""')
	$Local:ast = $commandAst.ToString().Replace('"', '""')
	winget complete --word="$Local:word" --commandline "$Local:ast" --position $cursorPosition | ForEach-Object {
		[System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
	}
}

# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
	param($commandName, $wordToComplete, $cursorPosition)
	dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
		[System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
	}
}

#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58


