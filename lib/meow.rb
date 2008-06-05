require 'osx/cocoa'

class Meow
  VERSION = '1.0.0'
  PRIORITIES = {  :very_low   => -2,
                  :moderate   => -1,
                  :normal     =>  0,
                  :high       =>  1,
                  :emergency  =>  2,
  }

  class << self
    ###
    # Send a message in one call.
    #
    # Example:
    #   Meow.notify('Meow', 'Title', 'Description', :priority => :very_high)
    def notify(name, title, description, opts = {})
      new(name).notify(title, description, opts)
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
  end

  ###
  # Send a notification to growl.
  #
  # * +title+ will be the title of the message.
  # * +description+ is the description of the message
  # * +opts+ is a hash of options.
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
  def notify(title, description, opts = {})
    opts = {
      :icon       => icon,
      :sticky     => false,
      :note_type  => note_type,
    }.merge(opts)

    register(opts[:note_type]) unless @registered.include?(opts[:note_type])

    notification = {
      'NotificationName'  => opts[:note_type],
      'ApplicationName'   => name,
      'NotificationTitle' => title,
      'NotificationDescription' => description,
      'NotificationIcon'  => opts[:icon].TIFFRepresentation(),
    }

    notification['NotificationAppIcon'] = opts[:app_icon].TIFFRepresentation if opts[:app_icon]
    notification['NotificationSticky'] = OSX::NSNumber.numberWithBool_(true) if opts[:stick]

    if opts[:priority]
      notification['NotificationPriority'] = OSX::NSNumber.numberWithInt_(PRIORITIES[opts[:priority]])
    end

    d = OSX::NSDictionary.dictionaryWithDictionary_(notification)
    notify_center = OSX::NSDistributedNotificationCenter.defaultCenter
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
