ActiveAdmin.register Revision do
    permit_params { policy( Revision ).permitted_attributes }
end
