require 'osx/cocoa'
require 'meow/notifier'

class Meow
  VERSION = '2.1.0'
  PRIORITIES = {  :very_low   => -2,
                  :moderate   => -1,
                  :normal     =>  0,
                  :high       =>  1,
                  :emergency  =>  2,
  }

  GROWL_IS_READY = "Lend Me Some Sugar; I Am Your Neighbor!"
  GROWL_NOTIFICATION_CLICKED = "GrowlClicked!"
  GROWL_NOTIFICATION_TIMED_OUT = "GrowlTimedOut!"
  GROWL_KEY_CLICKED_CONTEXT = "ClickedContext"

  # This sets up shared state properly that Cocoa uses.
  @@application = OSX::NSApplication.sharedApplication

  # Holds blocks waiting for clicks
  @@callbacks = Notifier.new
  @@callbacks.setup

  # The thread that is responsible for catching native callbacks.
  @@background_runner = nil

  class << self
    ###
    # Send a message in one call.
    #
    # Example:
    #   Meow.notify('Meow', 'Title', 'Description', :priority => :very_high)
    def notify(name, title, description, opts = {})
      new(name).notify(title, description, opts)
    end

    ##
    # Convert +image+ to an NSImage that displays nicely in growl. If
    # +image+ is a String, it's assumed to be the path to an image
    # on disk and is loaded.
    def import_image(image, size=128)
      if image.kind_of? String
        image = OSX::NSImage.alloc.initWithContentsOfFile image
      end

      return image if image.size.width.to_i == 128

      new_image = OSX::NSImage.alloc.initWithSize(OSX.NSMakeSize(size, size))
      new_image.lockFocus
      image.drawInRect_fromRect_operation_fraction(
        OSX.NSMakeRect(0, 0, size, size),
        OSX.NSMakeRect(0, 0, image.size.width, image.size.height),
        OSX::NSCompositeSourceOver, 1.0)
      new_image.unlockFocus

      return new_image
    end
  end

  attr_accessor :name, :note_type, :icon

  ###
  # Create a new Meow object.
  #
  # * +name+ is the application name.
  # * +note_type+ is the type of note you send.
  # * +icon+ is the icon displayed in the notification.
  #
  # Example:
  #   note = Meow.new('My Application')
  def initialize(name, note_type = 'Note', icon = OSX::NSWorkspace.sharedWorkspace.iconForFileType('rb'))
    @name       = name
    @icon       = icon
    @note_type  = note_type
    @registered = []

    @pid = OSX::NSProcessInfo.processInfo.processIdentifier

    # The notification name to look for when someone clicks on a notify bubble
    # or the bubble is timed out.
    @clicked_name = "#{name}-#{@pid}-#{GROWL_NOTIFICATION_CLICKED}"
    @timeout_name = "#{name}-#{@pid}-#{GROWL_NOTIFICATION_TIMED_OUT}"

    notify_center = OSX::NSDistributedNotificationCenter.defaultCenter
    notify_center.objc_send(:addObserver, @@callbacks,
                            :selector, "clicked:",
                            :name, @clicked_name,
                            :object, nil)
    notify_center.objc_send(:addObserver, @@callbacks,
                            :selector, "timeout:",
                            :name, @timeout_name,
                            :object, nil)

    start_runner unless @@background_runner
  end

  ###
  # Send a notification to growl.
  #
  # * +title+ will be the title of the message.
  # * +description+ is the description of the message
  # * +opts+ is a hash of options.
  # * +block+ is an optional block passed to +notify+. The block
  #   is called when someone clicks on the growl bubble.
  #
  # Possible values for +opts+ are:
  # * :priority   => Set the note priority
  # * :icon       => Override the current icon
  # * :note_type  => Override the current note type
  #
  # See Meow::PRIORITIES for the possible priorities.
  #
  # Example:
  #   note.notify('title', 'description', :priority => :very_low)
  def notify(title, description, opts = {}, &block)
    opts = {
      :icon       => icon,
      :sticky     => false,
      :note_type  => note_type,
      :priority   => 0
    }.merge(opts)

    register(opts[:note_type]) unless @registered.include?(opts[:note_type])
    opts[:icon] = Meow.import_image(opts[:icon]) if opts[:icon].is_a?(String)

    notification = {
      :ApplicationName   => name,
      :ApplicationPID    => @pid,
      :NotificationName  => opts[:note_type],
      :NotificationTitle => title,
      :NotificationDescription => description,
      :NotificationIcon  => opts[:icon].TIFFRepresentation(),
      :NotificationPriority => opts[:priority].to_i
    }

    notification[:NotificationAppIcon] = opts[:app_icon].TIFFRepresentation if opts[:app_icon]
    notification[:NotificationSticky] = OSX::NSNumber.numberWithBool(true) if opts[:sticky]

    notify_center = OSX::NSDistributedNotificationCenter.defaultCenter

    if block
      notification[:NotificationClickContext] = @@callbacks.add(block)
    end

    notify_center.postNotificationName_object_userInfo_deliverImmediately('GrowlNotification', nil, notification, true)
  end

  private

  def register(types, default_types = nil)
    types = [types].flatten
    default_types ||= types

    @registered = [@registered, types, default_types].flatten.uniq

    dictionary = {
      :ApplicationName       => name,
      :AllNotifications      => types,
      :DefaultNotifications  => default_types,
      :ApplicationIcon       => icon.TIFFRepresentation
    }
    
    notify_center = OSX::NSDistributedNotificationCenter.defaultCenter
    notify_center.postNotificationName_object_userInfo_deliverImmediately_('GrowlApplicationRegistrationNotification', nil, dictionary, true)
  end

  # Hides the infinite callback loop in the background so that it will not
  # stop the flow of the application.
  def start_runner
    @@background_runner = Thread.new do
      sleep 0.1
      OSX::NSApp.run
    end
    at_exit do
      loop do
        sleep 1
        OSX::NSApplication.sharedApplication.terminate(@@application) if @@callbacks.empty?
      end
    end
  end

end
