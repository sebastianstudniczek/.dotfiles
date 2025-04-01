using namespace System.Management.Automation
using namespace System.Management.Automation.Language

Import-Module Terminal-Icons
# Until will be fixed - causing misalignment right now
# Import-Module PSFzf

if ($host.Name -eq 'ConsoleHost') {
    #Binding  for moving through history by prefix
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\montys_custom.omp.json" | Invoke-Expression

# Import local config
$localConfigPath = $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.local.ps1  
if (Test-Path $localConfigPath) {
    . $localConfigPath
}

Set-Alias ls GetChildItemsSortByNames
Set-Alias g git
Set-Alias d dotnet
Set-Alias e explorer
Set-Alias grep Select-String
Set-Alias gmain Update-BasedOnMain
Set-Alias ga GitFuzzyAdd
Set-Alias cf FuzzyGoTo
Set-Alias which Get-ExecutablePath
Set-Alias zl Invoke-ZLocation

# FZF - Git 
Set-Alias fgs Invoke-FuzzyGitStatus
Set-Alias fgb Change-Branch
Set-Alias fgc Change-Commit
Set-Alias fgf Fix-Commit
Set-Alias fgr Rebase-Commit
Set-Alias fgt Reset-Commit
Set-Alias fgw Change-Worktree

$PsReadLineOptions = @{
    PredictionSource    = "History"
    PredictionViewStyle = "ListView"
    EditMode            = "Windows"
}
Set-PSReadLineOption @PsReadLineOptions

# Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
# Set-PSFzfOption -TabExpansion

Function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp -Encoding UTF8
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath ([System.IO.Path]::GetFullPath($cwd))
    }
    Remove-Item -Path $tmp
}

# Assumes ticket number in branch name (eg. SEB-125-new-feature)
Function CreatePR {
    $branchParts
    try {
        $branchParts = (git branch --show-current).Split('/')[1].Split('-')
    }
    catch {
        Write-Host "Not a git repo!" -ForegroundColor Red
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
    try {
        git push -u origin HEAD
    }
    catch {
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
    git worktree list | Invoke-Fzf | ForEach-Object { $_.Split(" ")[0] } | Set-Location
    # Get-ChildItem | Where-Object { $_.Name -like '*.sln' } | ForEach-Object { start $_.Name }
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


