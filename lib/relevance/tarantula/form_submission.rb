class Relevance::Tarantula::FormSubmission
  attr_accessor :method, :action, :data
  def initialize(form)
    @method = form.method
    @action = form.action
    @data = mutate_selects(form).merge(mutate_text_areas(form)).merge(mutate_inputs(form))
  end
  
  def to_s
    "#{action} #{method} #{data.inspect}"
  end
  
  # a form's signature is what makes it unique (e.g. action + fields)
  # used to keep track of which forms we have submitted already
  def signature
    [action, data.keys.sort]
  end
  
  def create_random_data_for(form, tag_selector)
    form.find_all(tag_selector).inject({}) do |form_args, input|
      # TODO: test
      form_args[input['name']] = random_data(input) if input['name']
      form_args
    end
  end

  def mutate_inputs(form)
    create_random_data_for(form, :tag => 'input')
  end

  def mutate_text_areas(form)
    create_random_data_for(form, :tag => 'textarea')
  end
  
  def mutate_selects(form)
    form.find_all(:tag => 'select').inject({}) do |form_args, select|
      options = select.find_all(:tag => 'option')
      option = options.rand
      form_args[select['name']] = option['value'] 
      form_args
    end
  end
  
  def random_data(input)
    case input['name']
      when /amount/         : random_int
      when /_id$/           : random_whole_number
      when /uploaded_data/  : nil
      when nil              : input['value']
      else                    random_int
    end
  end
  
  def big_number
    10000   # arbitrary
  end
  
  def random_int
    rand(big_number) - (big_number/2)
  end
  
  def random_whole_number
    rand(big_number)
  end
end
