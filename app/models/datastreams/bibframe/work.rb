module Datastreams
  module Bibframe
    # Datastream for modelling all Bibframe::Work metadata
    class Work < ActiveFedora::OmDatastream
      set_terminology do |t|
        t.root(path:  'Work', xmlns: 'http://bibframe.org/vocab/')
        t.uniformTitle
        t.title
        t.language
        t.subject do
          t.Topic do
            t.label
          end
        end
      end

      def self.xml_template
        Nokogiri::XML.parse('<bf:Work xmlns="http://bibframe.org/vocab/">')
      end
    end
  end
end
