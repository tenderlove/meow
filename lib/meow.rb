require 'osx/cocoa'
require 'meow/notifier'

class Meow
  VERSION = '1.1.0'
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

    ##
    # Call this if you have passed blocks to #notify. This blocks forever, but
    # it's the only way to properly get events.
    def run
      OSX::NSApp.run
    end

    ##
    # Call this to cause Meow to stop running.
    def stop
      OSX::NSApp.stop(nil)
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
  def initialize(name, note_type = 'Note', icon = OSX::NSWorkspace.sharedWorkspace().iconForFileType_('rb'))
    @name       = name
    @icon       = icon
    @note_type  = note_type
    @registered = []

    @pid = OSX::NSProcessInfo.processInfo.processIdentifier

    # The notification name to look for when someone clicks on a notify bubble.
    @clicked_name = "#{name}-#{@pid}-GrowlClicked!"

    notify_center = OSX::NSDistributedNotificationCenter.defaultCenter
    notify_center.addObserver_selector_name_object_ @@callbacks,
                                                    "clicked:",
                                                    @clicked_name,
                                                    nil
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
    notification[:NotificationSticky] = OSX::NSNumber.numberWithBool_(true) if opts[:stick]

    notify_center = OSX::NSDistributedNotificationCenter.defaultCenter

    if block
      notification[:NotificationClickContext] = @@callbacks.add(block)
    end

    d = OSX::NSDictionary.dictionaryWithDictionary_(notification)
    notify_center.postNotificationName_object_userInfo_deliverImmediately_('GrowlNotification', nil, d, true)
  end

  private

  def register(types, default_types = nil)
    types = [types].flatten
    default_types ||= types

    @registered = [@registered, types, default_types].flatten.uniq

    dictionary = OSX::NSDictionary.dictionaryWithDictionary({
      'ApplicationName'       => name,
      'AllNotifications'      => OSX::NSArray.arrayWithArray(types),
      'DefaultNotifications'  => OSX::NSArray.arrayWithArray(default_types),
      'ApplicationIcon'       => icon.TIFFRepresentation
    })
    notify_center = OSX::NSDistributedNotificationCenter.defaultCenter
    notify_center.postNotificationName_object_userInfo_deliverImmediately_('GrowlApplicationRegistrationNotification', nil, dictionary, true)
  end

end
