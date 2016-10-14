# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
OrderManager::Application.initialize!

Date::DATE_FORMATS[:default] = "%d-%m-%Y"
Time::DATE_FORMATS[:default] = "%d-%m-%Y %H:%M"
Time::DATE_FORMATS[:long] = "%d-%m-%Y %H:%M"
Time::DATE_FORMATS[:for_filename] = "%d-%m-%Y_%H-%M"

GIT_INFO = `git rev-parse --abbrev-ref HEAD`

require 'loggers/CustomLogger'

module BreadcrumbsOnRails
  module Breadcrumbs
    class OrderManagerBuilder < Builder
      def render
        @elements.collect do |element|
          render_element(element)
        end.join(@options[:separator] || " &raquo; ")
      end

      def render_element(element)
        content = @context.link_to_unless_current(compute_name(element), compute_path(element), element.options)
        if @options[:tag]
          @context.content_tag(@options[:tag], content)
        else
          if element.options[:type].present?
            @context.content_tag('span', content, :class => element.options[:type])
          else
            content
          end
        end
      end
    end

    class Element
      # @return [String] The element/link name.
      attr_accessor :name
      # @return [String] The element/link URL.
      attr_accessor :path
      # @return [Hash] The element/link URL.
      attr_accessor :options

      def initialize(name, path, options = {})
        self.name = name
        self.path = path
        self.options = options
      end
    end

  end
end

#config.active_record.observers = :user_observer
