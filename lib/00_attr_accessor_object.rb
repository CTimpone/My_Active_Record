class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |method|
      define_method("#{method}") do
        send(:instance_variable_get, "@#{method}")
      end

      define_method("#{method}=") do |argument|
        send(:instance_variable_set, "@#{method}", argument)
      end
    end

  end
end
