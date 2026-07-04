module CX
  class Interface < Subsystems::Interface
    def create_client(**args)
      with_logging { CX::Clients::Create.new.call(**args) }
    end
  end
end
