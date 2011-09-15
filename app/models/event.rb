class Event < ActiveRecord::Base
  attr_accessible :evtname, :evtdeparttime, :start, :evtprice, :notes, \
    :return_depart_time, :return_arrive_time

  has_many :attendee_events, :dependent => :destroy
  has_many :attendees, :through => :attendee_events

  validates_presence_of :start, :evtname, :year
  validates_length_of :notes, :maximum => 250
  validates_numericality_of :year, :only_integer => true, :greater_than => 2010, :less_than => 2100

  # Price should be numeric, but for some crazy reason, 
  # evtprice is a string.  Hence the ugly :unless blank? option
  validates_numericality_of :evtprice, \
    :greater_than_or_equal_to => 0, :allow_nil => true, \
    :unless => Proc.new { |e| e.evtprice.blank? }

  # Scopes, and class methods that act like scopes
  def self.yr(year) where(:year => year) end

end
