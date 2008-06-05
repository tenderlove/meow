require 'osx/cocoa'

class Meow
  VERSION = '1.0.0'

  attr_accessor :name, :note_types, :icon
  def initialize(name, icon = OSX::NSWorkspace.sharedWorkspace().iconForFileType_('rb'))
    @name       = name
    @icon       = icon
    @registered = []
  end

  def register(types, default_types = nil)
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

  def notify(note_type, title, description, options = {})
    register([note_type]) unless @registered.include?(note_type)

    options = {
      :icon   => icon,
      :sticky => false,
    }.merge(options)

    notification = {
      'NotificationName'  => note_type,
      'ApplicationName'   => name,
      'NotificationTitle' => title,
      'NotificationDescription' => description,
      'NotificationIcon'  => options[:icon].TIFFRepresentation(),
    }

    notification['NotificationAppIcon'] = options[:app_icon].TIFFRepresentation if options[:app_icon]
    notification['NotificationSticky'] = OSX::NSNumber.numberWithBool_(true) if options[:stick]

    d = OSX::NSDictionary.dictionaryWithDictionary_(notification)
    notify_center = OSX::NSDistributedNotificationCenter.defaultCenter
    notify_center.postNotificationName_object_userInfo_deliverImmediately_('GrowlNotification', nil, d, true)
  end
end
