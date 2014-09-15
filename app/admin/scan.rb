ActiveAdmin.register Scan do
    permit_params { policy( Scan ).permitted_attributes }
end
