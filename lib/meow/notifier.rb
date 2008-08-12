class Meow
  # addObserver can only be used with subclasses of NSObject, so we use this
  # one.
  class Notifier < OSX::NSObject
    def setup
      @callbacks = {}
    end

    def empty?
      @callbacks.empty?
    end

    def add(prc)
      pos = prc.object_id
      @callbacks[pos] = prc
      return pos
    end

    def clicked(notification)
      if block = remove_callback(notification)
        block.call 
      end
    end

    def timeout(notification)
      remove_callback(notification)
    end

    private

    def remove_callback(notification)
      idx = notification.userInfo[GROWL_KEY_CLICKED_CONTEXT].to_i
      @callbacks.delete idx
    end
  end
end
