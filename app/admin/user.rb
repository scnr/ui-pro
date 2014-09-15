ActiveAdmin.register User do
    permit_params { policy( User ).permitted_attributes }
end
