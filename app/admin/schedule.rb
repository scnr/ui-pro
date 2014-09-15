ActiveAdmin.register Schedule do
    permit_params { policy( Schedule ).permitted_attributes }
end
