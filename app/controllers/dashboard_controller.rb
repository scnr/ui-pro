class DashboardController < ApplicationController
    before_filter :authenticate_user!

    def index
        @issue_count_by_severity = {}
        IssueTypeSeverity.find_each do |severity|
            @issue_count_by_severity[severity.to_sym] = severity.issues.size
        end
    end

end
