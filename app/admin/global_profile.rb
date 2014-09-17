ActiveAdmin.register GlobalProfile do
    permit_params { policy( GlobalProfile ).permitted_attributes }
end
