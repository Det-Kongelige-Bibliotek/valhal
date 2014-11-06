require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

# We'll put our functioning tests here for now
describe InstancesController, type: :controller do
  describe '#show' do
    it 'should return rdf when requested' do
      instance = Instance.create
      get :show, { id: instance.id, format: :rdf }
      expect(assigns(:instance)).to eq(instance)
    end
  end
end


describe InstancesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Instance. As you add validations to Instance, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { title_statement: 'An Unfortunate Title' } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # InstancesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET index' do
    it 'assigns all instances as @instances' do
      instance = Instance.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:instances)).to include instance
    end
  end

  describe 'GET show' do
    it 'assigns the requested instance as @instance' do
      instance = Instance.create! valid_attributes
      get :show, { id: instance.to_param }, valid_session
      assigns(:instance).should eq(instance)
    end
  end

  describe 'GET new' do
    it 'assigns a new instance as @instance' do
      get :new, {}, valid_session
      assigns(:instance).should be_a_new(Instance)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested instance as @instance' do
      instance = Instance.create! valid_attributes
      get :edit, { id: instance.to_param }, valid_session
      assigns(:instance).should eq(instance)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Instance' do
        expect {
          post :create, { instance: valid_attributes }, valid_session
        }.to change(Instance, :count).by(1)
      end

      it "saves the Instance's title" do
        post :create, { instance: valid_attributes.merge(title_statement: 'War and Peace') }, valid_session
        expect(Instance.last.title_statement).to eql 'War and Peace'
      end

      it "saves the Instance's language" do
        post :create, { instance: valid_attributes.merge(language: { value: 'Latin' }) }, valid_session
        expect(Instance.last.language_values).to include 'Latin'
      end

      it 'assigns a newly created instance as @instance' do
        post :create, { instance: valid_attributes }, valid_session
        assigns(:instance).should be_a(Instance)
        assigns(:instance).should be_persisted
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved instance as @instance' do
        # Trigger the behavior that occurs when invalid params are submitted
        Instance.any_instance.stub(:save).and_return(false)
        post :create, { instance: {} }, valid_session
        assigns(:instance).should be_a_new(Instance)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Instance.any_instance.stub(:save).and_return(false)
        post :create, { instance: {} }, valid_session
        response.should render_template('new')
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested instance' do
        instance = Instance.create! valid_attributes
        # Assuming there are no other instances in the database, this
        # specifies that the Instance created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Instance.any_instance.should_receive(:update).with('these' => 'params')
        put :update, { id: instance.to_param, instance: { 'these' => 'params' } }, valid_session
      end

      it 'assigns the requested instance as @instance' do
        instance = Instance.create! valid_attributes
        put :update, { id: instance.to_param, instance: valid_attributes }, valid_session
        assigns(:instance).should eq(instance)
      end

      it 'redirects to the instance' do
        instance = Instance.create! valid_attributes
        put :update, { id: instance.to_param, instance: valid_attributes }, valid_session
        response.should redirect_to(instance)
      end
    end

    describe 'with invalid params' do
      it 'assigns the instance as @instance' do
        instance = Instance.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Instance.any_instance.stub(:save).and_return(false)
        put :update, { id: instance.to_param, instance: {} }, valid_session
        assigns(:instance).should eq(instance)
      end

      it "re-renders the 'edit' template" do
        instance = Instance.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Instance.any_instance.stub(:save).and_return(false)
        put :update, { id: instance.to_param, instance: {} }, valid_session
        response.should render_template('edit')
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested instance' do
      instance = Instance.create! valid_attributes
      expect {
        delete :destroy, { id: instance.to_param }, valid_session
      }.to change(Instance, :count).by(-1)
    end

    it 'redirects to the instances list' do
      instance = Instance.create! valid_attributes
      delete :destroy, { id: instance.to_param }, valid_session
      response.should redirect_to(instances_url)
    end
  end

  describe 'Update preservation profile metadata' do
    before(:each) do
      @ins = Instance.create!
    end
    it 'should have a default preservation settings' do
      ins = Instance.find(@ins.pid)
      ins.preservation_profile.should_not be_blank
      ins.preservation_state.should_not be_blank
      ins.preservation_details.should_not be_blank
      ins.preservation_modify_date.should_not be_blank
      ins.preservation_comment.should be_blank
    end

    it 'should be updated and redirect to the instance' do
      profile = PRESERVATION_CONFIG["preservation_profile"].keys.first
      comment = "This is the preservation comment"

      put :update_preservation_profile, {:id => @ins.pid, :preservation => {:preservation_profile => profile, :preservation_comment => comment }}
      response.should redirect_to(@ins)

      ins = Instance.find(@ins.pid)
      ins.preservation_state.should_not be_blank
      ins.preservation_details.should_not be_blank
      ins.preservation_modify_date.should_not be_blank
      ins.preservation_profile.should == profile
      ins.preservation_comment.should == comment
    end

    it 'should not update or redirect, when the profile is wrong.' do
      profile = "wrong profile #{Time.now.to_s}"
      comment = "This is the preservation comment"

      put :update_preservation_profile, {:id => @ins.pid, :preservation => {:preservation_profile => profile, :preservation_comment => comment }}
      response.should_not redirect_to(@ins)

      ins = Instance.find(@ins.pid)
      ins.preservation_state.should_not be_blank
      ins.preservation_details.should_not be_blank
      ins.preservation_modify_date.should_not be_blank
      ins.preservation_profile.should_not == profile
      ins.preservation_comment.should_not == comment
    end

    it 'should update the preservation date' do
      profile = PRESERVATION_CONFIG["preservation_profile"].keys.last
      comment = "This is the preservation comment"
      ins = Instance.find(@ins.pid)
      d = ins.preservation_modify_date

      put :update_preservation_profile, {:id => @ins.pid, :preservation => {:preservation_profile => profile, :preservation_comment => comment }}
      response.should redirect_to(@ins)

      ins = Instance.find(@ins.pid)
      ins.preservation_modify_date.should_not == d
    end

    it 'should not update the preservation date, when the same profile and comment is given.' do
      profile = PRESERVATION_CONFIG["preservation_profile"].keys.last
      comment = "This is the preservation comment"
      @ins.preservation_profile = profile
      @ins.preservation_comment = comment
      @ins.save

      ins = Instance.find(@ins.pid)
      d = ins.preservation_modify_date

      put :update_preservation_profile, {:id => @ins.pid, :preservation => {:preservation_profile => profile, :preservation_comment => comment }}
      response.should redirect_to(@ins)

      ins = Instance.find(@ins.pid)
      ins.preservation_modify_date.should == d
    end


    #TODO: Mock rabbitMQ
    it 'should send a message, when performing preservation and the profile has Yggdrasil set to true' do
      profile = PRESERVATION_CONFIG["preservation_profile"].keys.last
      PRESERVATION_CONFIG['preservation_profile'][profile]['yggdrasil'].should == 'true'
      comment = "This is the preservation comment"
      destination = MQ_CONFIG["preservation"]["destination"]
      uri = MQ_CONFIG["mq_uri"]

      conn = Bunny.new(uri)
      conn.start

      ch = conn.create_channel
      q = ch.queue(destination, :durable => true)

      put :update_preservation_profile, {:id => @ins.pid, :commit => Constants::PERFORM_PRESERVATION_BUTTON, :preservation => {:preservation_profile => profile, :preservation_comment => comment }}
      response.should redirect_to(@ins)

      q.subscribe do |delivery_info, metadata, payload|
        metadata[:type].should == Constants::MQ_MESSAGE_TYPE_PRESERVATION_REQUEST
        payload.should include @ins.pid
        json = JSON.parse(payload)
        json.keys.should include ('UUID')
        json.keys.should include ('Preservation_profile')
        json.keys.should include ('Valhal_ID')
        json.keys.should_not include ('File_UUID')
        json.keys.should_not include ('Content_URI')
        json.keys.should include ('Model')
       # json.keys.should include ('metadata')
        json['metadata'].keys.each do |k|
          @ins.datastreams.keys.should include k
          Constants::NON_RETRIEVABLE_DATASTREAM_NAMES.should_not include k
        end
      end

      ins = Instance.find(@ins.pid)
      ins.preservation_state.should == Constants::PRESERVATION_STATE_INITIATED.keys.first
      ins.preservation_comment.should == comment
      sleep 1.second
      conn.close
    end

    it 'should not send a message, when performing preservation and the profile has Yggdrasil set to false' do
      profile = PRESERVATION_CONFIG['preservation_profile'].keys.first
      PRESERVATION_CONFIG['preservation_profile'][profile]['yggdrasil'].should == 'false'
      comment = 'This is the preservation comment'

      put :update_preservation_profile, {:id => @ins.pid, :commit => Constants::PERFORM_PRESERVATION_BUTTON,
                                         :preservation => {:preservation_profile => profile,
                                                           :preservation_comment => comment }}
      response.should redirect_to(@ins)

      ins = Instance.find(@ins.pid)
      ins.preservation_state.should == Constants::PRESERVATION_STATE_NOT_LONGTERM.keys.first
      ins.preservation_comment.should == comment
    end

    it 'should send inheritable settings to the files' do
      file = ContentFile.create
      @ins.content_files << file
      @ins.save!
      file.save!

      profile = PRESERVATION_CONFIG["preservation_profile"].keys.last
      comment = "This is the preservation comment-#{Time.now.to_s}"

      put :update_preservation_profile, {:id => @ins.pid, :commit => Constants::PERFORM_PRESERVATION_BUTTON, :preservation =>
          {:preservation_profile => profile, :preservation_comment => comment, :cascade_preservation => '1'}}

      file = ContentFile.find(file.pid)
      file.preservation_state.should_not be_blank
      file.preservation_details.should_not be_blank
      file.preservation_modify_date.should_not be_blank
      file.preservation_profile.should == profile
      file.preservation_comment.should == comment
    end

  end


  describe 'GET preservation' do
    it 'should assign \'@ins\' to the ordered_instance' do
      @ins = Instance.create!
      get :preservation, {:id => @ins.pid}
      assigns(:instance).should eq(@ins)
    end
  end


end
