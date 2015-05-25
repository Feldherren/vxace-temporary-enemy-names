=begin
Temporary Enemy Names v0.1, by Feldherren (rpaliwoda@googlemail.com)

To-do:
  Add easy means to create skills that reveal battler's true name
    Can currently put b.reveal_name in battle formula, but that's less than ideal as it requires at least 1 point of damage or healing to be done
    Tsukihime's effects script or whatever it is that lets you easily add effects to skills or items is probably the way to go, here
  Allow passive per-turn check to reveal name? Or have that rely on Troop events?
  Probably interacts badly with random names script; make this play nice with other name-manipulating things
=end

class Game_Enemy < Game_Battler
  attr_reader   :temporary_name            # temporary name
  attr_accessor :name_revealed             # whether or not the enemy's name has been revealed
  # on creation, get notebox tags from data and pick up the enemy's temporary name. Return that for original name instead
  alias initialize_temp_name initialize
  def initialize(index, enemy_id)
    initialize_temp_name(index, enemy_id)
    @name_revealed = true
		@temporary_name = @original_name
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

class Game_Troop < Game_Unit
	# switched enemy.original_name to .name
	alias make_unique_names_temp_name make_unique_names
  def make_unique_names
    members.each do |enemy|
      next unless enemy.alive?
      next unless enemy.letter.empty?
      n = @names_count[enemy.name] || 0
      enemy.letter = letter_table[n % letter_table.size]
      @names_count[enemy.name] = n + 1
    end
    members.each do |enemy|
      n = @names_count[enemy.name] || 0
      enemy.plural = true if n >= 2
    end
  end
	
	# switched enemy.original_name to enemy.temporary_name
	alias enemy_names_temp_name enemy_names
	def enemy_names
    names = []
    members.each do |enemy|
      next unless enemy.alive?
      next if names.include?(enemy.temporary_name)
      names.push(enemy.temporary_name)
    end
    names
  end
end