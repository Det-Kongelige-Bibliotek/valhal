class MixedMaterialsController < ApplicationController
  authorize_resource
  respond_to :html
  before_action :set_mixed_material, only: [:show]

  def new
    @mixed_material = MixedMaterial.new
    @mixed_material.titles.build
    @mixed_material.relators.build
    @mixed_material.instances.build
  end

  def create
    @mixed_material = MixedMaterial.new(mixed_material_params)
    if @mixed_material.save
      flash[:notice] = t(:model_created, model: t('models.mixed_material'))
    else
      flash[:error] = t(:model_creation_failed, model: t('models.mixed_material'))
    end
    respond_with @mixed_material
  end

  def show
  end

  private

  def set_mixed_material
    @mixed_material = MixedMaterial.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def mixed_material_params
    params[:mixed_material].permit(:language, :origin_date, titles_attributes: [[:id, :value, :subtitle, :lang, :type]],
                         relators_attributes: [[ :id, :agent_id, :role ]], subjects: [[:id]], note:[],
                         instances_attributes: [[ :id, :type, :activity, :title_statement, :extent, :copyright,
                         :dimensions, :mode_of_issuance, :isbn13, :contents_note, :embargo,
                         :embargo_date, :embargo_condition, :access_condition, :availability,
                         :collection, :preservation_profile, note: [], content_files: [],
                         relators_attributes: [[ :id, :agent_id, :role ]],
                         publications_attributes: [[:id, :copyright_date, :provider_date ]] ]])
  end
end