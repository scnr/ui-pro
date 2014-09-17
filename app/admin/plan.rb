ActiveAdmin.register Plan do
    permit_params { policy( Plan ).permitted_attributes }

    form do |f|
        f.inputs 'Plan' do
            f.input :name
            f.input :description
            f.input :price
            f.input :enabled
        end

        f.inputs 'Profile', for: [:profile_override, f.object.profile_override] do |plan_form|
            plan_form.input :scope_page_limit
        end

        f.actions
    end

    controller do
        def new
            @plan = Plan.new
            @plan.build_profile_override
        end
    end
end
