require 'osx/cocoa'

class Meow
  VERSION = '1.0.0'

  attr_accessor :name, :notifications, :icon
  def initialize(name, notifications, icon = OSX::NSWorkspace.sharedWorkspace().iconForFileType_('rb'))
    @name           = name
    @notifications  = notifications
    @default_notifications = notifications
    @icon           = icon
  end

  def register
    dictionary = OSX::NSDictionary.dictionaryWithDictionary({
      'ApplicationName'       => @name,
      'AllNotifications'      => OSX::NSArray.arrayWithArray(@notifications),
      'DefaultNotifications'  => OSX::NSArray.arrayWithArray(@default_notifications),
      'ApplicationIcon'  => @icon.TIFFRepresentation
    })
    notify_center = OSX::NSDistributedNotificationCenter.defaultCenter
    notify_center.postNotificationName_object_userInfo_deliverImmediately_('GrowlApplicationRegistrationNotification', nil, dictionary, true)
  end
end
