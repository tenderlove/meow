class Meow
  # addObserver can only be used with subclasses of NSObject, so we use this
  # one.
  class Notifier < OSX::NSObject
    def setup
      @callbacks = {}
    end

    def add(prc)
      pos = prc.object_id
      @callbacks[pos] = prc
      return pos
    end

    def clicked(notification)
      idx = notification.userInfo[GROWL_KEY_CLICKED_CONTEXT].to_i
      begin
        if block = @callbacks[idx]
          block.call
        end
      ensure
        @callbacks.delete idx
      end
    end
  end
end
