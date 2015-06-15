# This is a KB Instance.
# Only KB specific logic should
# live in this class. All domain logic
# e.g. Bibframe, Hydra::Rights etc,
# should live in separate modules and
# be mixed in.
class Instance < ActiveFedora::Base
  include Hydra::AccessControls::Permissions
  include Concerns::AdminMetadata
  include Concerns::Preservation
  include Concerns::RelatorMethods
  include Datastreams::TransWalker
  include Concerns::CustomValidations

  property :languages, predicate: ::RDF::Vocab::Bibframe.language
  property :isbn13, predicate: ::RDF::Vocab::Bibframe.isbn13, multiple: false
  property :isbn10, predicate: ::RDF::Vocab::Bibframe.isbn10, multiple: false
  property :mode_of_issuance, predicate: ::RDF::Vocab::Bibframe.modeOfIssuance, multiple: false
  property :extent, predicate: ::RDF::Vocab::Bibframe.extent, multiple: false
  property :note, predicate: ::RDF::Vocab::Bibframe.note
  property :title_statement, predicate: ::RDF::Vocab::Bibframe.titleStatement, multiple: false
  property :dimensions, predicate: ::RDF::Vocab::Bibframe.dimensions, multiple: false
  property :contents_note, predicate: ::RDF::Vocab::Bibframe.contentsNote, multiple: false
  property :system_number, predicate: ::RDF::Vocab::Bibframe.systemNumber, multiple: false

  belongs_to :work, predicate: ::RDF::Vocab::Bibframe::instanceOf

  has_and_belongs_to_many :equivalents, class_name: "Instance", predicate: ::RDF::Vocab::Bibframe::hasEquivalent

  has_many :content_files, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.isPartOf
  has_many :struct_map, predicate: Datastreams::MetsStructMap
  has_many :relators, predicate: ::RDF::Vocab::Bibframe.relatedTo
  has_many :publications, predicate: ::RDF::Vocab::Bibframe::publication, class_name: 'Provider'

  accepts_nested_attributes_for :relators, :publications

  before_save :set_rights_metadata

  after_save do
    self.work.update_index if work.present?
    self.send_to_extsolr
  end

  def publication
    publications.first
  end
  # method to set the rights metadata stream based on activity
  def set_rights_metadata
    a = Administration::Activity.find(self.activity)
    self.discover_groups = a.activity_permissions['instance']['group']['discover']
    self.read_groups = a.activity_permissions['instance']['group']['read']
    self.edit_groups = a.activity_permissions['instance']['group']['edit']
  end


  def uuid
    self.id
  end

  validates :collection, :copyright, :type, presence: true
  validates :isbn13, isbn_format: { with: :isbn13 }, if: "isbn13.present?"
  validates :isbn13, presence: true, if: :is_trykforlaeg?


  def is_trykforlaeg?
    self.type == 'Trykforlaeg'
  end

  # Use this setter to manage work relations
  # as it ensures relationship symmetry
  # We allow it to take pids as Strings
  # to enable it to be written to via forms
  # @params Work | String (pid)
  def set_work=(work_input)
    if work_input.is_a? String
      work = Work.where(work_input)
    elsif work_input.is_a? Work
      work = work_input
    else
      fail "Can only take args of type Work or String where string represents a Work's pid"
    end
    begin
      self.work = work
      work
    rescue ActiveFedora::RecordInvalid => exception
      logger.error("set_work failed #{exception}")
      nil
    end
  end

  def set_equivalent=(instance_input)
    if instance_input.is_a? String
      instance = Instance.where(instance_input)
    elsif instance_input.is_a? Instance
      instance = instance_input
    else
      fail "Can only take args of type Instance or String where string represents a Work's pid"
    end
    begin
      self.equivalents += [instance]
      instance.equivalents += [self]
      instance
    rescue ActiveFedora::RecordInvalid => exception
      logger.error("set_equivalent failed #{exception}")
      nil
    end
  end
  
  def add_relator(agent,role)
    relation = Relator.new(agent: agent, role: role)
    self.relators += [relation]
  end

  def add_publisher(agent)
    role = 'http://id.loc.gov/vocabulary/relators/pbl'
    self.add_relator(agent,role)
  end

  def add_printer(agent)
    role = 'http://id.loc.gov/vocabulary/relators/prt'
    self.add_relator(agent,role)
  end

  def add_scribe(agent)
    role = 'http://id.loc.gov/vocabulary/relators/scr'
    self.add_relator(agent,role)
  end

  # Accessor for backwards compatibility
  def publisher_name
    related_agents('pbl').first.try(:_name)
  end

  # Accessor for backwards compatibility
  def published_date
    publication.provider_date if publication.present?
  end

  def add_published_date(date)
    publications ||= [ Provider.new ]
    publications.first.provider_date=date
  end

  def content_files=(files)
    # ensure instance is valid before saving files
    return unless self.valid?
    #remove old file
    content_files.delete_all
    files.each do |f|
      self.add_file(f)
    end
  end

  def add_file(file, validators=[],run_custom_validators = true)
    cf = ContentFile.new
    cf.instance=self
    if (file.is_a? File) || (file.is_a? ActionDispatch::Http::UploadedFile)
      cf.add_file(file)
    else
      if (file.is_a? String)
        cf.add_external_file(file)
      end
    end
    cf.instance = self
    cf.validators = validators
    cf.save(validate: run_custom_validators)
    cf
  end

  def create_structMap
    self.structMap.clear_structMap
    order = 1
    self.content_files.each do |cf|
      self.structMap.add_file(order.to_s,cf.uuid.to_s)
      order += 1
    end
  end

  # method to set the rights metadata stream based on activity
  def set_rights_metadata
    a = Administration::Activity.find(self.activity)
    self.discover_groups = a.activity_permissions['instance']['group']['discover']
    self.read_groups = a.activity_permissions['instance']['group']['read']
    self.edit_groups = a.activity_permissions['instance']['group']['edit']
  end

  def set_rights_metadata_on_file(file)
    a = Administration::Activity.find(self.activity)
    file.discover_groups = a.activity_permissions['file']['group']['discover']
    file.read_groups = a.activity_permissions['file']['group']['read']
    file.edit_groups = a.activity_permissions['file']['group']['edit']
  end

  ## Model specific preservation functionallity

  # @return whether any operations can be cascading (e.g. updating administrative or preservation metadata)
  # For the instances, this is true (since it has the files).
  def can_perform_cascading?
    true
  end

  # Returns all the files as ContentFile objects.
  # @return the objects, which cascading operations can be performed upon (e.g. updating administrative or preservation metadata)
  def cascading_elements
    res = []
    content_files.each do |f|
      res << ContentFile.find(f.id)
    end
    logger.debug "Found following inheritable objects: #{res}"
    res
  end

  def create_preservation_message_metadata
    XML::InstanceSerializer.preservation_message(self)
  end

  def to_solr(solr_doc = {} )
    super
    #activity_name = Administration::Activity.find(activity).activity
    #Solrizer.insert_field(solr_doc, 'activity_name', activity_name, :stored_searchable, :facetable)
  end


  def valid_trykforlaeg
    if self.is_trykforlaeg?
      errors.add(:published_date,'Et trykforlæg skal have en udgivelses dato') unless self.published_date.present?
    end
  end

  # given an activity name, return a set of Instances
  # belonging to that activity
  # note the mapping to AF objects will take a bit of time
  def self.find_by_activity(activity)
    docs = ActiveFedora::SolrService.query("activity_name_sim:#{activity}")
    docs.map { |d| Instance.find(d['id']) }
  end

  # given an activity object - create an instance
  # with the default values of that activity
  def self.from_activity(activity)
    i = self.new
    i.activity = activity.id
    i.collection = activity.collection
    i.copyright = activity.copyright
    i.preservation_profile = activity.preservation_profile
    i
  end

  # Send the instance to the rsolr
  def send_to_extsolr
     i = self.to_solr()
     solr = RSolr.connect :url => CONFIG[:external_solr]
     solr.add i
     solr.commit
  end
end
