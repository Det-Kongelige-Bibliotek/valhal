# View helpers that are shared between different models
module ApplicationHelper
  # Gets the list of a controlled list
  # @param name of a controlled list
  def get_controlled_vocab(list_name)
    list = Administration::ControlledList.with(:name, list_name)
    list.nil? ? [] : list.elements.map(&:name)
  end

  # Find the available dissemination profiles from the relevant directory
  # and return an array of arrays suitable for a form in the style
  # ['DisseminationProfiles::Adl', 'Adl']
  def dissemination_profiles
    dir = Rails.root.join('app','export', 'dissemination_profiles')
    Pathname.new(dir).children.collect do |c|
      profile_name = c.basename.to_s.split('.').first
      class_name = "dissemination_profiles/#{profile_name}".classify
      [ class_name, profile_name]
    end
  end

  # Given a list name, return a list of arrays
  # suitable for dropdowns, whereby the string
  # displayed is either the element's label if present
  # or the element's name if not.
  # The list is sorted by the value of the labels ascending
  # if a recstrict_to argument is given, array is restricted to elements with the name in the list
  def get_list_with_labels(list_name,restrict_to=[])
    list = Administration::ControlledList.with(:name, list_name)
    elements = list.nil? ? [] : list.elements.to_a
    elements.map!{ |e| [ (e.label.present? ? e.label : e.name), e.name] }
    elements.select!{|e| restrict_to.include?(e.last)} if restrict_to.present?
    elements.sort { |x,y| x.first <=> y.first }
  end

  def get_entry_label(list_name, entry_name)
    entry = Administration::ControlledList.with(:name, list_name).elements.find(name: entry_name).first
    entry.label.present? ? entry.label : entry.name
  end

  def get_preservation_collections_for_select
    profiles = []
    PRESERVATION_CONFIG['preservation_collection'].each do |key,value|
      profiles << [value['name'], key]
    end
    profiles
  end

  def letter_show_link(letter_id, label)
    link_to label, "/catalog/#{URI::escape(letter_id, "/")}"
  end

  def letters_link(letter_id, label)
    book_id, div_id = letter_id.split('-')
    link_to label, "/catalog/#{URI::escape(letter_id, "/")}##{div_id}"
  end

  def letter_title(doc)
    recipient = doc["recipient_text_ssim"]
    sender = doc["sender_text_ssim"]
    date = doc["date_text_ssim"]
    title = "BREV "
    if recipient.is_a? Array
      recipient.first.present? ? title += "TIL: " + recipient.to_sentence(:last_word_connector => " og ") : title = 'TIL: ukendt'
    end
    if sender.is_a? Array
      sender.first.present? ? title += " FRA: " + sender.to_sentence(:last_word_connector => " og ") : title += ' FRA: ukendt'
    end
    if date.is_a? Array
      date.first.present? ? title += " DATO: " + date.to_sentence(:last_word_connector => " og ") : title += ' DATO: ukendt'
    end
    title
  end

  # Calculate the percentage of the letters that are done in a letter_book
  def percent_of_completed_letters(lb_id)
    ((Finder.get_completed_letters(lb_id).count.to_f / Finder.get_all_letters(lb_id).count.to_f) * 100).round(2)
  end

  def translate_model_names(name)
    I18n.t("models.#{name.parameterize('_')}", default: name)
  end

  def translate_status_names(status)
    I18n.t("status.#{status}", default: status)
  end

  # Renders a title type ahead field
  def render_title_typeahead_field
    results = Work.get_title_typeahead_objs
    select_tag 'work[titles][][value]', options_for_select(results.map { |result| collect_title(result['title_tesim'],result['id']) }.flatten(1)),
    { include_blank: true, class: 'combobox form-control input-large', data_function: 'title-selected' }
  end

  #Renders a list of Agents for a typeahead field
  def get_agent_list
    results = Authority::Agent.get_typeahead_objs
    agents = results.nil? ? [] : results.collect{|result| [result['display_value_ssm'].first,result['id']]}
    agents.sort {|a,b| a.first.downcase <=> b.first.downcase }
  end

  def subjects_for_select
    docs = Finder.all_people + Finder.all_works
    docs.map {|doc| [ doc['display_value_ssm'].try(:first), doc['id'] ] }
  end

  #Returns a list of select options
  #Param query_result : a solr query
  #Param display_field : the solr field to be used as display field
  def select_fields(query_result, display_field = 'display_value_ssm')
    result = query_result.nil? ? [] : query_result.collect { |val| [ display_value(val, display_field), val['id'] ] }
    result.sort { |a,b| a.first.downcase <=> b.first.downcase }
  end

  # Given a solr doc and a display field, show the field or 'Unknown'
  def display_value(val, display_field)
    val[display_field].first rescue t :unknown
  end

  # Given a url from a ControlledList, create a link to this url
  # with the value of the corresponding label.
  # E.g. given the corresponding entry in the system
  # <%= rdf_resource_link('http://id.loc.gov/vocabulary/languages/abk') %>
  # Will produce: <a href="http://id.loc.gov/vocabulary/languages/abk">Abkhaz</a>
  def rdf_resource_link(entry)
    if entry.present? && uri?(entry)
      link_to Administration::ListEntry.get_label(entry), entry if entry.present?
    else
      Administration::ListEntry.get_label(entry)
    end
  end

  # Check if a sting is URL
  def uri?(string)
    uri = URI.parse(string)
    %w( http https ).include?(uri.scheme)
  rescue URI::BadURIError, URI::InvalidURIError
    false
  end

  private

  def collect_title(titles,id)
    titles.collect {|title| [title,id]}
  end

  def get_activity_name(id)
    Administration::Activity.find(id).activity
  end

  # Convert the field symbol given by an error into a name
  def just_field_name(field_sym)
    field_sym.to_s.split('.').last
  end


  # Generate a link to a instance given a work_id and instance id
  # Note: This code could be made much simpler if we
  def get_work_instance_link_for_search_result(work_id,inst_id)
    solr_id = inst_id.gsub(':','\:')
    doc =ActiveFedora::SolrService.query("id:#{solr_id}").first
    # catch cases where instance isn't present for some reason
    if doc.nil?
      link_to 'Work', work_path(work_id)
    elsif doc['active_fedora_model_ssi'] == 'Trygforlaeg'
      link_to "#{doc['active_fedora_model_ssi']} (#{doc['type_ssm'].first})", work_trykforlaeg_path(work_id, inst_id)
    else
      link_to "#{doc['active_fedora_model_ssi']} (#{doc['type_ssm'].first})", work_instance_path(work_id, inst_id)
    end
  end
end
