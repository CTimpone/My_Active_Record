def method_missing(method_name, *args)
  split_array = method_name.to_s.split('_')
  if split_array[0] = 'meditate'

    split = split_array[2..-1]
    eigenclass = class << self; self; end
    
    eigenclass.class_eval do
      define_method("meditate_on_#{split.join('_')}") do
        return "I know the meaning of #{split.join(' ')}"
      end
    end

  send(method_name, *args)

  else
    super
  end

end
