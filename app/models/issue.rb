class Issue < ActiveRecord::Base
    belongs_to :page, class_name: 'IssuePage', foreign_key: 'issue_page_id',
               dependent: :destroy

    belongs_to :referring_page, class_name: 'IssuePage',
               foreign_key: 'issue_page_id', dependent: :destroy

    belongs_to :type, class_name: 'IssueType', foreign_key: 'issue_type_id'

    belongs_to :platform, class_name: 'IssuePlatform',
               foreign_key: 'issue_platform_id'

    belongs_to :revision

    has_one  :vector,  as: :with_vector, dependent: :destroy
    has_many :remarks, class_name: 'IssueRemark', foreign_key: 'issue_id',
                dependent: :destroy

    def self.create_from_arachni( issue )
        issue_remarks = []
        issue.remarks.each do |author, remarks|
            remarks.each do |remark|
                issue_remarks << IssueRemark.create( author: author, text: remark )
            end
        end

        create(
            type:           IssueType.find_by_check_shortname( issue.check[:shortname] ),
            digest:         issue.digest.to_s,
            signature:      issue.signature,
            proof:          issue.proof,
            trusted:        issue.trusted,
            active:         issue.active?,
            page:           IssuePage.create_from_arachni( issue.page ),
            referring_page: IssuePage.create_from_arachni( issue.referring_page ),
            vector:         Vector.create_from_arachni( issue.vector ),
            remarks:        issue_remarks,
            platform:       (IssuePlatform.find_by_shortname( issue.platform_name.to_s ) if issue.platform_name),
        )
    end
end
