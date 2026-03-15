# @name: Notes
# @description: Attach notes to files/directories, shown in right pane
# @key: F5

require 'fileutils'

NOTES_DIR = File.expand_path('~/.rtfm/notes')
FileUtils.mkdir_p(NOTES_DIR)

KEYMAP['F5'] = :toggle_note

PLUGIN_HELP['Notes'] = <<~HELP
  Attach text notes to any file or directory.

  Press F5 on any selected item to view, create,
  edit, or delete its note.

  #{"How it works:".b}
    If no note exists, you're prompted to create one.
    If a note exists, it shows in the right pane
    with options to edit or delete.

  #{"Commands (when viewing a note):".b}
    e   Edit the note
    d   Delete the note
    q   Close

  #{"Difference from marks:".b}
    Marks (m/') are single-letter bookmarks for
    quick directory jumping. Notes are free-text
    annotations attached to specific files or
    directories, useful for reminders, TODO items,
    or documentation.

  Notes are stored in ~/.rtfm/notes/ as text files.
HELP

def note_path_for(file)
  File.join(NOTES_DIR, file.gsub('/', '%') + '.txt')
end

def toggle_note
  clear_image
  file = @selected
  npath = note_path_for(file)
  has_note = File.exist?(npath)

  if has_note
    note = File.read(npath)
    loop do
      lines = []
      lines << "Note for:".b.fg(254)
      lines << File.basename(file).fg(112)
      lines << ""
      lines << note
      lines << ""
      lines << "e".b.fg(112) + "  edit note"
      lines << "d".b.fg(112) + "  delete note"
      lines << "q/ESC: close".fg(240)

      @pR.update = true
      @pR.say(lines.join("\n"))

      chr = getchr
      case chr
      when 'e'
        input = @pCmd.ask('Note: ', note)
        unless input.strip.empty?
          File.write(npath, input)
          note = input
          @pB.say('Note updated.')
        end
      when 'd'
        File.delete(npath)
        @pB.say('Note deleted.')
        break
      when 'q', 'ESC'
        break
      end
    end
  else
    input = @pCmd.ask('Note: ', '')
    unless input.strip.empty?
      File.write(npath, input)
      @pB.say('Note saved.')
    end
  end

  @pR.update = true
  refresh
  render
end
