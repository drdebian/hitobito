module DatetimeAttribute
  extend ActiveSupport::Concern
  
  included do
    class_attribute :datetime_attributes
    self.datetime_attributes = []
    
    before_validation :store_datetime_fields
  end
  
  private
  
  def store_datetime_fields
    datetime_attributes.each do |attr|
      # use accessors to obtain persisted values
      date = send("#{attr}_date")
      if date.present?
        date = date.to_date
        hour = send("#{attr}_hour").presence || 0
        min = send("#{attr}_min").presence || 0
        send("#{attr}=", Time.zone.local(date.year, date.month, date.day, hour.to_i, min.to_i))
      else
        send("#{attr}=", nil)
      end
    end
  end
  
  def datetime_to(value, field)
    value ? send("datetime_to_#{field}", value) : nil
  end
  
  def datetime_to_date(value)
    value.to_date
  end
  
  def datetime_to_hour(value)
    value.hour
  end
  
  def datetime_to_min(value)
    value.min
  end
  
  def datetime_fields(attr)
    @datetimes ||= {}
    @datetimes[attr] ||= {}
  end
  
  module ClassMethods
    
    def datetime_attr(*attrs)
      attrs.each do |attr|
        self.datetime_attributes << attr
        
        attr_accessible attr, :"#{attr}_date", :"#{attr}_hour", :"#{attr}_min"
        
        # define field accessors
        [:date, :hour, :min].each do |field|
          accessor = :"#{attr}_#{field}"
          # getter
          define_method(accessor) do
            datetime_fields(attr)[field] ||= datetime_to(send(attr), field)
          end
          
          # setter
          define_method("#{accessor}=") do |value|
            send("#{attr}_will_change!") unless value == send(accessor)
            datetime_fields(attr)[field] = value
          end
        end
      end
    end
    
  end
  
end