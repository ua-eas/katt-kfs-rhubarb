class Rhubarb::Email::JobStream
  attr_reader :name, :outputs

  def initialize(config={})
    @name = config['name']
    @outputs = {}

    # target_name = key, the target name
    # target_entry = value, a nested hash, specific email info for each target
    config['outputs'].each do |target_name, target_entry|
        @outputs[target_name] = Rhubarb::Email::Output.new(target_entry)
    end

  end


  def deliver(target_name)
   
    if name.eql? 'all'
        #send all in an each loop
        @outputs.each do |target_name|
            @outputs[target_name].deliver!
        end
        return 0
    elsif @outputs[target_name]
        # send just the target name
        @outputs[target_name].deliver!
        return 0
    end
    
    #throw some exception because the target is undefined.
    raise "Could not find target with name: " + target_name
    
    
  end

end
