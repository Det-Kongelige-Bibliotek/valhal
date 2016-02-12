class Ability
  include CanCan::Ability
  include Hydra::Ability

  def create_permissions

    if user_groups.include?('Chronos-Alle')
      can [:create], Work
      can [:create], Authority::Organization
      can [:create], Authority::Person

    end

    if user_groups.include?('Chronos-Admin')
      can [:create], Administration::Activity
      can [:create], Administration::ControlledList
    end

    if (user_groups & ['Chronos-Pligtaflevering','Chronos-Admin']).present?
      can [:create], Instance
    end
  end

  def custom_permissions
    can [:destroy], ActiveFedora::Base do |obj|
      test_edit(obj.id)
    end

    can [:download], ContentFile do |cf|
      test_read(cf.id)
    end

    can [:upload, :update], ContentFile do |cf|
      test_edit(cf.id)
    end

    can [:send_to_preservation, :update_adminstration], Instance do |obj|
      test_edit(obj.id)
    end

    can [:validate_tei], Instance do |obj|
      test_read(obj.id)
    end


    if (user_groups & ['Chronos-Pligtaflevering','Chronos-Admin']).present?
      can [:aleph], Work
    end

    if (user_groups & ['Chronos-Alle']).present?
      can [:edit], Authority::Person
      can [:viaf], Authority::Person
    end

    if (user_groups & ['Chronos-Alle']).present?
      can [:edit], Authority::Organization
      can [:viaf], Authority::Organization
    end
  end
end
