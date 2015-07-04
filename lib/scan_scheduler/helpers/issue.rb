class ScanScheduler
module Helpers
module Issue

    def initialize
        super

        reset_issue_state
    end

    # Creates a `revision` DB {Issue} from a `native` {Arachni::Issue issue}.
    #
    # @param    [Revision]  revision
    # @param    [Arachni::Issue]  native
    def create_issue( revision, native )
        log_debug_for revision, "Creating issue: #{native.unique_id} - #{native.digest}"

        update_updatable_data_for( revision, native )

        ::Issue.create_from_arachni( native, revision: revision )
    end

    # Updates the `revision`'s DB {Issue} with `native` {Arachni::Issue}'s data.
    #
    # In this case, issue remarks and state are updated, so long as the state
    # has not ben set to either `false_positive` or `fixed` by the user.
    #
    # @param    [Revision]  revision
    # @param    [Arachni::Issue]  native
    def update_issue( revision, native )
        if !update_issue?( revision, native )
            log_debug_for revision, 'No need to update issue: ' +
                "#{native.unique_id} - #{native.digest}"
            return
        end

        log_debug_for revision, "Updating issue: #{native.unique_id} - #{native.digest}"

        issue = revision.issues.where( digest: native.digest ).first

        native.remarks.each do |author, remarks|
            remarks.each do |remark|
                issue.remarks.find_or_create_by( author: author, text: remark )
            end
        end

        # If the user has set the status manually, don't override it.
        if !%w(false_positive fixed).include?( issue.state )
            issue.state = (native.trusted? ? 'trusted' : 'untrusted')
            issue.save
        end
    end

    def import_issues_from_report( revision, report )
        scan_issues     = Set.new(
            revision.scan.issues.where.not( revision: revision ).digests
        )
        revision_issues = Set.new( revision.issues.digests )

        report.issues.each do |issue|
            # Already logged by a previous revision, don't bother with it.
            if scan_issues.include?( issue.digest )
                log_info_for revision, 'Issue already logged by previous' +
                    " revision: #{issue.unique_id} - #{issue.digest}"
                next
            end

            # If false, issue must have already been created **and** have
            # no data that needs updating, skip it.
            if !update_issue?( revision, issue.variations.first )
                log_debug_for revision, 'No need to update issue from report:' +
                    " #{issue.unique_id} - #{issue.digest}"
                next
            end

            issue.variations.each do |variation|
                solo = variation.to_solo( issue )

                if revision_issues.include?( solo.digest )
                    update_issue( revision, solo )
                else
                    create_issue( revision, solo )
                end
            end
        end

    end

    # Marks issues of other revisions as fixed, if their digests are not included
    # in the given `issue_digests`.
    #
    # @param    [Revision]          revision
    # @param    [Array<Integer>]    issue_digests
    def mark_other_issues_fixed( revision, issue_digests )
        # Mark issues of previous revisions as fixed if they're not logged by
        # this revision.
        revision.scan.issues.reorder('').where.not(
            revision: revision,
            digest:   issue_digests,
        ).update_all(
            state:                'fixed',
            fixed_by_revision_id: revision.id
        )
    end

    def reset_issue_state
        @updatable_issue_data_per_digest = {}
    end

    private

    def updatable_data_for( issue )
        @updatable_issue_data_per_digest[issue.digest] ||=
            Arachni::Support::LookUp::HashSet.new
    end

    def update_updatable_data_for( revision, issue )
        updatable_data_for( issue ) <<
            hash_from_updatable_issue_data( revision, issue )
    end

    def update_issue?( revision, issue )
        !updatable_data_for( issue ).include?(
            hash_from_updatable_issue_data( revision, issue )
        )
    end

    def hash_from_updatable_issue_data( revision, issue )
        [
            revision.id,
            issue.trusted? ? 'trusted' : 'untrusted',
            issue.remarks
        ].hash
    end

end
end
end
