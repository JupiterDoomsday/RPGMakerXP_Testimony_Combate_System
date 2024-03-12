#==============================================================================
# ** Game_Testimony
#------------------------------------------------------------------------------
#  This class handles Testimonies. It's used within the Game_TEnemy class
#  ($game_troop).
#==============================================================================

class Statement
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     node_type      : defines the statement as the head/tail/middle
  #     statement_text : text the statment will display
  #     doubt_state : Item id or bool needed to "satsifiy" the statment
  #--------------------------------------------------------------------------
  def initialize(id_num, statement_text, doubt_state, response)
    @id =id_num
    @doubt = doubt_state
    @text = statement_text
    @response = response
    @satisfied = false
    @next_state = nil
  end
  #getter/setter functions
  def id
    @id
  end
  def id=(val)
    id = val
  end
  def text
    @text
  end
  
  def text=(val)
    @text = val
  end
  def doubt
    @doubt
  end
  
  def nextState
    @next_state
  end
  
  def nextState=(val)
    @next_state = val
  end
  #this schecks to make sure if the statement is "complete"
  def satisfied
    @satisfied 
  end
  #Implementes Press logic to check if the thing is satisfied
  def press
    @satisfied = @doubt == true
    return @satisfied
  end
  #Implementes Present logic to check if the statement is satisfied
  def compareItem(itemId)
    @satisfied = itemId == @doubt
    return @satisfied
  end
  
  def response
    @response
  end
  def response=(val)
    @response = val
  end
  
  def to_s
    " Node Id is : #{@id} #{@text}"
  end
end

class Phase
  def initialize(sequences)
    @phase_seq = sequences
    @seq_length = sequences.length
    @cur_seq = 0
    @statements = 0
    @complete = false
    @root_statement = nil
  end
  
  def length
    return @statements
  end
  
  def is_seq_satisfied
    curIndex = @phase_seq[@cur_seq]
    node = find(curIndex)
    if node != nil
      return node.satisfied
    end
    return false
  end

  def root_text
    @root_statement.text
  end
  
  def curSeq
    @cur_seq
  end
  
  def find_tail
    node = @root_statement
    return node if !node.nextState
    return node if !node.nextState while (node = node.nextState)
  end
  #appends the obj node  as the new Next of the current node
  def append(statement_text, doubt_state, response)
    @statements +=1
    if @root_statement
      find_tail.nextState = Statement.new(@statements, statement_text, doubt_state, response)
    else
      @root_statement = Statement.new(1, statement_text, doubt_state, response)
    end
  end
  
  def find(id)
    node = @root_statement
    return false if !node.nextState
    return node  if node.id == id
    while (node = node.nextState)
      return node if node.id == id
    end
  end
  
  def append_after(target, statement_text, doubt_state, response)
    node = find(target)
    return unless node
    @statements +=1
    old_next = node.nextState
    node.nextState = Statement.new(@statements, statement_text, doubt_state, response)
    node.nextState.nextState = old_next
  end
  
  def go_to_next_seq
    @cur_seq += 1
    if @cur_seq == @seq_length
      @complete = true
      return true
    end
    return false
  end
  
end

class Testimony
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     phases     : array of phases
  #     statement_text : text the cur statment will display
  #--------------------------------------------------------------------------
  def initialize(phase_ar)
    @phases = phase_ar
    @cur_phase = 0
    @cur_line_count = 1
    @isTestimonyOver = false
  end
  
  def phases
    @phases
  end
  
  def cur_phase_count
    @cur_phase
  end
  
  def cur_phase
    @phases[@cur_phase]
  end
  
  def cur_line_count
    return @cur_line_count
  end
  
  def cur_phase_count=(val)
    @cur_line_count = val
  end
  
  def cur_phase=(val)
    @cur_phase = val
  end
  
  def is_testimony_over
    @isTestimonyOver
  end
  
  def cur_seq
    @phases[@cur_phase].curSeq
  end
  
  def next_seq
    @phases[@cur_phase].go_to_next_seq
  end

  def go_to_next_phase
    @cur_phase += 1
    if @cur_phase == @phases.length
      @isTestimonyOver = true
    end
  end
  
  def check_phase
    if is_node_satisfied
      go_to_next_phase
    end
  end
  
  def append(statement_text, doubt_state, response)
    @phases[@cur_phase].append(statement_text, doubt_state, response)
  end
  
  def curLine
    @phases[@cur_phase].find(@cur_line_count)
  end
  
  def check_item_of_cur_statement(item_id)
    return @phases[@cur_phase].find(@cur_line_count).compareItem(item_id)
  end
  
  def press_cur_statement
    return @phases[@cur_phase].find(@cur_line_count).press
  end
  
  def is_node_satisfied
    return @phases[@cur_phase].find(@cur_line_count).satisfied
  end
  
  def at_the_end
    return @phases[@cur_phase].length == @cur_line_count
  end
  
  def go_to_next_line
    if @phases[@cur_phase].length == @cur_line_count
      $game_temp.cur_line_count = @cur_line_count = 1
    else
      $game_temp.cur_line_count = @cur_line_count += 1
    end
  end
  
  def change_statement(new_text)
    statement_node = curLine.text
    if statement_node != nil
      statement_node.text = new_text
    end
  end
  
  def go_to_prev_line
    if @cur_line_count > 1
      $game_temp.cur_line_count = @cur_line_count -= 1
    end
  end
end
