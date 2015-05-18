# -*- encoding : utf-8 -*-
module Concerns
  # Handles the technical metadata.
  module TechMetadata
    extend ActiveSupport::Concern

    included do
      contains 'techMetadata', class_name: 'Datastreams::TechMetadata'

      #has_attributes :uuid, :last_modified, :created, :last_accessed, :original_filename, :mime_type, :file_uuid,
      #               :editable, :pb_xml_id, :pb_facs_id, :xml_pointer, datastream: 'techMetadata', :multiple => false
      property :uuid,  delegate_to: 'techMetadata', :multiple => false
      property :last_modified,  delegate_to: 'techMetadata', :multiple => false
      property :created,  delegate_to: 'techMetadata', :multiple => false
      property :last_accessed,  delegate_to: 'techMetadata', :multiple => false
      property :original_filename,  delegate_to: 'techMetadata', :multiple => false
      property :external_file_path, delegate_to: 'techMetadata', :multiple => false
      property :mime_type,  delegate_to: 'techMetadata', :multiple => false
      property :file_uuid,  delegate_to: 'techMetadata', :multiple => false
      property :editable,  delegate_to: 'techMetadata', :multiple => false
      property :pb_xml_id,  delegate_to: 'techMetadata', :multiple => false
      property :pb_facs_id,  delegate_to: 'techMetadata', :multiple => false
      property :xml_pointer,  delegate_to: 'techMetadata', :multiple => false
      # TODO have more than one checksum (both MD5 and SHA), and specify their checksum algorithm.
      property :checksum, delegate_to: 'techMetadata', :at => [:file_checksum], :multiple => false
      property :size, delegate_to: 'techMetadata', :at => [:file_size], :multiple => false
      property :validators, delegate_to: 'techMetadata', :at => [:validators], :multiple => true
    end
  end
end


