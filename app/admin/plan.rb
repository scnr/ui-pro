ActiveAdmin.register Plan do
    permit_params { policy( Plan ).permitted_attributes }
end
