# @name: Settings
# @description: Interactive settings editor (colors, toggles, paths)
# @key: C

KEYMAP['C'] = :show_settings

PLUGIN_HELP['Settings'] = <<~HELP
  Interactive editor for RTFM settings that don't
  have their own dedicated keys.

  Overrides the default 'C' (show config) key.

  #{"Navigation:".bd}
    j/k or UP/DOWN  Navigate settings
    LEFT/RIGHT      Toggle booleans, adjust colors +-1
    H/L             Adjust colors +-10
    ENTER           Edit text fields or type color number
    q/ESC           Save and close

  #{"Settings included:".bd}
    Trash mode, run-mailcap, interactive programs,
    custom ls flags, OpenAI key/model, and all
    pane colors (top, bottom, search, command,
    ruby, AI, SSH bars).

  Changes are saved to ~/.rtfm/conf on close.
  Color changes apply immediately.
HELP

def show_settings
  clear_image

  # Settings definitions: [label, variable, type, options]
  # Types: :bool, :cycle, :int_range, :text
  settings = [
    ['Trash (move to trash)',   :@trash,        :bool],
    ['Use run-mailcap',         :@runmailcap,   :bool],
    ['Interactive programs',    :@interactive,   :text],
    ['Custom ls flags',         :@lsuser,       :text],
    ['OpenAI API key',          :@ai,           :text_masked],
    ['OpenAI model',            :@aimodel,      :text],
    ['Top bar color',           :@topcolor,     :color],
    ['Bottom bar color',        :@bottomcolor,  :color],
    ['Search bar color',        :@searchcolor,  :color],
    ['Command bar color',       :@cmdcolor,     :color],
    ['Ruby bar color',          :@rubycolor,    :color],
    ['AI bar color',            :@aicolor,      :color],
    ['SSH bar color',           :@sshcolor,     :color],
  ]

  sel = 0
  label_w = settings.map { |s| s[0].length }.max + 2

  loop do
    # Build display
    lines = []
    lines << "Settings".bd.fg(254)
    lines << ""

    settings.each_with_index do |(label, var, type, _opts), i|
      val = instance_variable_get(var)
      display = case type
                when :bool
                  val ? "Yes" : "No"
                when :color
                  swatch = "  #{val}  ".bg(val.to_i).fg(val.to_i > 128 ? 0 : 255)
                  "#{swatch} #{val}"
                when :text_masked
                  val.to_s.length > 8 ? val.to_s[0..3] + "..." + val.to_s[-4..] : val.to_s
                else
                  val.to_s
                end

      pad = label_w - label.length
      line = "#{label}#{' ' * pad}#{display}"
      line = i == sel ? line.ul : line
      lines << line
    end

    lines << ""
    lines << "j/k:move  LEFT/RIGHT:change  ENTER:edit  q:close".fg(240)

    @pR.update = true
    @pR.say(lines.join("\n"))

    chr = getchr
    case chr
    when 'q', 'ESC'
      break
    when 'j', 'DOWN'
      sel = (sel + 1) % settings.size
    when 'k', 'UP'
      sel = (sel - 1) % settings.size
    when 'RIGHT', 'LEFT', 'ENTER'
      label, var, type, _opts = settings[sel]
      val = instance_variable_get(var)

      case type
      when :bool
        instance_variable_set(var, !val)
      when :color
        delta = chr == 'RIGHT' ? 1 : chr == 'LEFT' ? -1 : 0
        if chr == 'ENTER'
          input = @pCmd.ask("#{label} (0-255): ", val.to_s).strip
          new_val = input.to_i
          instance_variable_set(var, new_val.clamp(0, 255))
        else
          instance_variable_set(var, (val.to_i + delta).clamp(0, 255))
        end
        # Apply color changes immediately
        apply_color(var)
      when :text, :text_masked
        input = @pCmd.ask("#{label}: ", val.to_s)
        instance_variable_set(var, input)
      end
    when 'H'
      # Jump -10 for color settings
      _label, var, type, _opts = settings[sel]
      if type == :color
        val = instance_variable_get(var)
        instance_variable_set(var, (val.to_i - 10).clamp(0, 255))
        apply_color(var)
      end
    when 'L'
      # Jump +10 for color settings
      _label, var, type, _opts = settings[sel]
      if type == :color
        val = instance_variable_get(var)
        instance_variable_set(var, (val.to_i + 10).clamp(0, 255))
        apply_color(var)
      end
    end
  end

  # Save all settings to config
  save_settings(settings)
  @pR.update = true
  refresh
  render
end

def apply_color(var)
  case var
  when :@topcolor
    @pT.bg = @topcolor
    @pT.update = true
  when :@bottomcolor
    @pB.bg = @bottomcolor
    @pB.update = true
  when :@searchcolor
    @pSearch.bg = @searchcolor
  when :@cmdcolor
    @pCmd.bg = @cmdcolor
  when :@rubycolor
    @pRuby.bg = @rubycolor
  when :@aicolor
    @pAI.bg = @aicolor
  when :@sshcolor
    @pSsh.bg = @sshcolor
  end
end

def save_settings(settings)
  @conf = @conf.dup
  settings.each do |_label, var, type, _opts|
    val = instance_variable_get(var)
    name = var.to_s.sub('@', '')
    line = case type
           when :bool
             "@#{name} = #{val}"
           when :color
             "@#{name} = #{val}"
           when :text, :text_masked
             "@#{name} = '#{val}'"
           end
    regex = /^@#{Regexp.escape(name)}\b.*$/
    if @conf.match?(regex)
      @conf.sub!(regex, line)
    else
      @conf << "\n" unless @conf.end_with?("\n")
      @conf << line << "\n"
    end
  end
  File.write(CONFIG_FILE, @conf)
  @pB.say('Settings saved to ~/.rtfm/conf')
end
