require 'osx/cocoa'

class Meow
  VERSION = '1.0.0'
  PRIORITIES = {  :very_low   => -2,
                  :moderate   => -1,
                  :normal     =>  0,
                  :high       =>  1,
                  :emergency  =>  2,
  }

  attr_accessor :name, :note_type, :icon
  def initialize(name, note_type = 'Note', icon = OSX::NSWorkspace.sharedWorkspace().iconForFileType_('rb'))
    @name       = name
    @icon       = icon
    @note_type  = note_type
    @registered = []
  end

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
