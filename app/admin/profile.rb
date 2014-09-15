ActiveAdmin.register Profile do
    permit_params { policy( Profile ).permitted_attributes }
end
