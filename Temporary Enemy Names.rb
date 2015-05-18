=begin
Temporary Enemy Names v0.1, by Feldherren (rpaliwoda@googlemail.com)

To-do:
  Stop original/proper name from showing up in intro to battle (something in Game_Troop?)
  Add easy means to create skills that reveal battler's true name
    Can currently put b.reveal_name in battle formula, but that's less than ideal as it requires at least 1 point of damage or healing to be done
  Allow passive per-turn check to reveal name? Or have that rely on Troop events?
=end

class Game_Enemy < Game_Battler
  attr_reader   :temporary_name            # temporary name
  attr_accessor :name_revealed             # letters to be attached to the name
  # on creation, get notebox tags from data and pick up the enemy's temporary name. Return that for original name instead
  alias initialize_temp_name initialize
  def initialize(index, enemy_id)
    initialize_temp_name(index, enemy_id)
    @name_revealed = true
    # if notebox tags present, do stuff
    if (match = $data_enemies[@enemy_id].note.match( /^<temp name\s*:\s*([\w\d,\s*]*)>/i ))
      @temporary_name = get_random_name(match[1].to_s)
      @name_revealed = false
    end
    if (match = $data_enemies[@enemy_id].note.match( /^<temp name list\s*:\s*([\w\d\s*]*)>/i ))
      names = Random_Names::NAME_LISTS[match[1].to_s]
      @temporary_name = names[rand(names.length)]
      @name_revealed = false
    end
  end
  
  alias initialize_name name
  def name
    #@original_name + (@plural ? letter : "")
    if (!name_revealed)
      @temporary_name + (@plural ? letter : "")
    else
      @original_name + (@plural ? letter : "")
    end
  end
  
  def reveal_name
    @name_revealed = true
  end
  
  def strip_or_self!(str)
    str.strip! || str
  end
  
  def get_random_name(names)
    a = names.split(',')
    return strip_or_self!(a[rand(a.length)])
  end
end