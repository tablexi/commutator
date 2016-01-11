module Commutator
  class ItemModifiers
    def initialize(modifiers, factory: false)
      @modifiers = modifiers
      @factory = factory
    end

    def factory?
      @factory
    end

    # This is a mess, but I wasn't sure how else to guarantee to
    # call Procs at the time of collection creation
    def expand_proc_modifiers
      return self unless factory?

      self.class.new(@modifiers.map(&:call))
    end

    def modify(item)
      @modifiers.each { |modifier| modifier.call(item) }
    end
  end
end
