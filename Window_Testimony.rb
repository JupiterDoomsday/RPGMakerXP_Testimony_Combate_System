#==============================================================================
# ** Window_Testimony
#------------------------------------------------------------------------------
#  This window displays the Testimony Text, borrows code from the Window_Message class
#==============================================================================

class Window_Testimony < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 320, 640, 160)
    self.contents = Bitmap.new(width - 32, height - 32)
    @wait= 2
    @type_writer = true
    @contents_showing = false
    @cursor_width = 0
    self.index = -1
  end
  
  def go_to_next_msg
    # Call message callback
    self.pause = false
    self.contents.clear
    # Clear showing flag
    @contents_showing = false
    if $game_temp.testimony_proc != nil
      $game_temp.testimony_proc.call
    end
    $game_temp.message_text = nil
    $game_temp.message_proc = nil
  end
  
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    self.pause = false
    $game_temp.testimony_text = nil
    super
  end
  
  #--------------------------------------------------------------------------
  # * refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    x = y = 0
    @cursor_width = 0
    # Indent if choice
    if $game_temp.choice_start == 0
      x = 8
    end
    # If waiting for a message to be displayed
    if $game_temp.testimony_text != nil
      text = "#{$game_temp.testimony_text}"
      #text = $game_temp.testimony_text
      #$game_temp.message_text = $game_temp.testimony_text
      # Control text processing
      begin
        last_text = text.clone
        text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
      end until text == last_text
      text.gsub!(/\\[Nn]\[([0-9]+)\]/) do
        $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
      end
      # Change "\\\\" to "\000" for convenience
      text.gsub!(/\\\\/) { "\000" }
      # Change "\\C" to "\001" and "\\G" to "\002"
      text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
      text.gsub!(/\\[Gg]/) { "\002" }
      
      # Get 1 text character in c (loop until unable to get text)
      while ((c = text.slice!(/./m)) != nil)
        # If \\
        if c == "\000"
          # Return to original text
          c = "\\"
        end
        # If \C[n]
        if c == "\001"
          # Change text color
          text.sub!(/\[([0-9]+)\]/, "")
          color = $1.to_i
          if color >= 0 and color <= 7
            self.contents.font.color = text_color(color)
          end
          # go to next text
          next
        end
        if c == "\n"
          # Add 1 to y
          y += 1
          x = 0
          # go to next text
          next
        end
        # Draw text
        self.contents.draw_text(4 + x, 32 * y, 40, 32, c)
        # Add x to drawn text width
        x += self.contents.text_size(c).width
      end
    end
  end
  
  def update
    super
    # If message is being displayed
    if @contents_showing
      self.pause = true
      if Input.trigger?(Input::X)
      # Call message callback
        go_to_next_msg
        return
      end
    end
    if $game_temp.testimony_text != nil
      refresh
      @contents_showing = true
    end
  end
end
