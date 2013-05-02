module MongoUtils
  module Stripable
    def blank_value?(value)
      if value.is_a?(Hash)
        value.reject! { |_, v| blank_value?(v) }
      end
      plain_value_blank?(value)
    end

    def plain_value_blank?(value)
      value.blank? || value == 0
    end

    def blank_and_was_blank_value?(attribute, value)
      blank_value?(value) && respond_to?("#{attribute}_was") && blank_value?(send("#{attribute}_was"))
    end

    def self.included(base)
      base.send :include, Mongoid::Document

      base.around_create do |&b|
        attributes.reject! { |_, value| blank_value?(value) }
        b.call
        apply_defaults
      end

      base.around_update do |&b|
        attributes.reject! { |a, v|
          blank_and_was_blank_value?(a, v)
        }
        b.call
        apply_defaults
      end
    end
  end
end
