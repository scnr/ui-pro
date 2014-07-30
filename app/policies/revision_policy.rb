class RevisionPolicy < ApplicationPolicy
    alias :revision :record

    allow_admin_or :show do |user, revision|
        next if revision.scan.site.unverified?
        revision.scan.site.user == user || user.has_shared_site?( revision.scan.site )
    end

    allow_admin_or :update, :destroy do |user, revision|
        next if revision.scan.site.unverified?
        revision.scan.site.user == user
    end

    def permitted_attributes
        []
    end

end
