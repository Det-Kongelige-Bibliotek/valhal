module Authority
  class Person < Agent
    property :family_name, predicate: ::RDF::Vocab::SCHEMA.familyName, multiple: false
    property :given_name, predicate: ::RDF::Vocab::SCHEMA.givenName, multiple: false
    property :full_name, predicate: ::RDF::Vocab::SCHEMA.name, multiple: false
    property :birth_date, predicate: ::RDF::Vocab::SCHEMA.birthDate, multiple: false
    property :death_date, predicate: ::RDF::Vocab::SCHEMA.deathDate, multiple: false
    property :birth_place, predicate: ::RDF::Vocab::SCHEMA.birthPlace, multiple: false
    property :death_place, predicate: ::RDF::Vocab::SCHEMA.deathPlace, multiple: false
    property :same_as, predicate: ::RDF::Vocab::SCHEMA.sameAs, multiple: false
    property :nationality, predicate: ::RDF::Vocab::SCHEMA.nationality, multiple: false
    property :description, predicate: ::RDF::Vocab::SCHEMA.description, multiple: false
    property :alternate_names, predicate: ::RDF::Vocab::SCHEMA.alternateName, multiple: true
    property :image, predicate: ::RDF::Vocab::SCHEMA.image

    has_many :relators

    def display_value
      value = ''
      value += "#{family_name}, " if family_name.present?
      value += "#{given_name}, " if given_name.present?
      value += "#{birth_date}-" if birth_date.present?
      value += "#{death_date}" if death_date.present?
      value
    end

    def to_solr(solr_doc = {})
      solr_doc = super
      Solrizer.insert_field(solr_doc, 'display_value', display_value, :displayable)
      Solrizer.insert_field(solr_doc, 'typeahead', display_value, :stored_searchable)
      solr_doc
    end
  end
end