ActiveAdmin.register Site do
    permit_params { policy( Site ).permitted_attributes }
end
