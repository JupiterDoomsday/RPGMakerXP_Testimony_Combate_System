class Window_Arrows < Window_Selectable
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(480,254, 142, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.back_opacity = 160
    @commands = ["<--", "-->",]
    draw_item(0, ($game_temp.cur_line_count > 1) ? normal_color : disabled_color)
    draw_item(1, normal_color)
    @item_max = 2
    @column_max = 2
    self.index = 0
    self.active=true
    end
  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : item number
  #     color : text character color
  #--------------------------------------------------------------------------
  def draw_item(index, color)
    self.contents.font.color = color
    rect = Rect.new(index * 64 + 4, 0, 64 - 10, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    #self.contents.draw_icon_graphic("backArrow",480,(index * 64 + 254))
    self.contents.draw_text(rect, @commands[index], 1)
  end
  #--------------------------------------------------------------------------
  # * Cursor Rectangle Update
  #--------------------------------------------------------------------------
  def update_cursor_rect
    self.cursor_rect.set(index * 64, 0, 64-10, 32)
  end
  
  def refresh
    self.contents.clear
    draw_item(0, ($game_temp.cur_line_count > 1) ? normal_color : disabled_color)
    draw_item(1, normal_color)
  end
  
  def update
    super
    refresh
    if Input.trigger?(Input::B)
      self.active = false
      self.visible = false
    end
  end
end
