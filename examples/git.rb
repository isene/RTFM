# @name: Git
# @description: Git operations (status, commit, push, diff)
# @key: C-G

KEYMAP['C-G'] = :git_menu

PLUGIN_HELP['Git'] = <<~HELP
  Quick git operations for the current directory.

  Press Ctrl-G to open the git menu.

  #{"Commands:".bd}
    s   Show git status
    d   Show git diff
    c   Stage all, commit (prompts for message), push
    l   Show last 20 commits (git log --oneline)
    q   Close menu

  All output displays in the right pane.
  The commit command runs interactively so you
  can see push progress and any errors.
HELP

def git_menu
  clear_image

  loop do
    lines = []
    lines << "Git".bd.fg(254)
    lines << ""
    lines << "s".bd.fg(112) + "  git status"
    lines << "d".bd.fg(112) + "  git diff"
    lines << "c".bd.fg(112) + "  git add + commit + push"
    lines << "l".bd.fg(112) + "  git log (last 20)"
    lines << ""
    lines << "q/ESC: close".fg(240)

    @pR.update = true
    @pR.say(lines.join("\n"))

    chr = getchr
    case chr
    when 's'
      output = command("git status 2>&1")
      @pR.update = true
      @pR.say("git status".bd.fg(254) + "\n\n" + output)
    when 'd'
      output = command("git diff 2>&1")
      output = "No changes." if output.strip.empty?
      @pR.update = true
      @pR.say("git diff".bd.fg(254) + "\n\n" + output)
    when 'c'
      message = @pCmd.ask('Commit message: ', '')
      if message.strip.empty?
        @pB.say("Aborted: empty commit message.")
        next
      end
      @pB.say("Committing and pushing...")
      shellexec("git add . && git commit -m '#{message}' && git push", timeout: 20)
      @pB.full_refresh
    when 'l'
      output = command("git log --oneline -20 2>&1")
      @pR.update = true
      @pR.say("git log".bd.fg(254) + "\n\n" + output)
    when 'q', 'ESC'
      break
    end
  end

  @pR.update = true
  refresh
  render
end
