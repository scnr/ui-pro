include Warden::Test::Helpers
Warden.test_mode!

# Feature: Site ownership verification form
#   As a user
#   I want to verify ownership of my site
feature 'Site verification' do

    before do
        Typhoeus.stub( site.verification.url ).and_return( response )
        user.sites << site
    end

    after(:each) do
        Warden.test_reset!
    end

    let(:user) { FactoryGirl.create :user }
    let(:site) { FactoryGirl.create :site, host: 'localhost.local' }
    let(:response) do
        Typhoeus::Response.new(
            code:        200,
            body:        site.verification.code,
            return_code: :ok
        )
    end

    before do
        login_as user, scope: :user
    end

    feature 'when site verification fails' do
        before do
            site.verification.message = 'Error message!'
            site.verification.failed!
            visit edit_site_path( site )
        end

        # Scenario: User sees the HTTP error message for a failed verification
        #   Given I am signed in
        #   When I visit the edit site page
        #   And the site verification has failed
        #   I see a appropriate message
        scenario 'user sees a failed message' do
            expect(page).to have_content site.verification.message
        end

        # Scenario: User cannot see the verify button for a verification in progress
        #   Given I am signed in
        #   When I visit the edit site page
        #   And the site verification is in progress
        #   I do not see the Verify link
        scenario 'user sees the verification link' do
            expect(page).to have_xpath "//a[@href='#{verify_site_path(site)}']"
        end
    end

    feature 'when site verification is in progress' do
        before do
            site.verification.started!
            visit edit_site_path( site )
        end

        # Scenario: User sees progress message for a verification in progress
        #   Given I am signed in
        #   When I visit the edit site page
        #   And the site verification is in progress
        #   I see a progress message
        scenario 'user sees a progress message' do
            expect(page).to have_content 'In progress'
        end

        # Scenario: User cannot see the verify button for a verification in progress
        #   Given I am signed in
        #   When I visit the edit site page
        #   And the site verification is in progress
        #   I do not see the Verify link
        scenario 'user cannot see verification link' do
            expect(page).to_not have_xpath "//a[@href='#{verify_site_path(site)}']"
        end
    end

    feature 'when the site is verified' do
        before do
            site.verification.verified!
            visit edit_site_path( site )
        end

        # Scenario: User can see the Verified message for a verified site
        #   Given I am signed in
        #   When I visit the edit site page
        #   And the site is verified
        #   I see a Verified message
        scenario 'user sees Verified message' do
            expect(page).to have_content 'Verified'
        end

        # Scenario: User cannot see the verify button for a verified site
        #   Given I am signed in
        #   When I visit the edit site page
        #   And the site is verified
        #   I do not see the Verify link
        scenario 'user cannot see verification link' do
            expect(page).to_not have_xpath "//a[@href='#{verify_site_path(site)}']"
        end
    end

    feature 'when the site is not verified' do
        before do
            visit edit_site_path( site )
        end

        # Scenario: User can see the location of the verification file they need to create
        #   Given I am signed in
        #   When I visit the edit site page
        #   I see the location of the verification file
        scenario 'user sees the verification form' do
            expect(page).to have_content site.verification.url
        end

        # Scenario: User can see the verification code for the file
        #   Given I am signed in
        #   When I visit the edit site page
        #   I see a textarea with the verification code
        scenario 'user sees the verification form' do
            expect(find('#site-verification-code').value).to match site.verification.code
        end

        # Scenario: User can see the verification button
        #   Given I am signed in
        #   When I visit the edit site page
        #   I see the verification link
        scenario 'user sees the verification form' do
            expect(page).to have_xpath "//a[@href='#{verify_site_path(site)}']"
        end

        # Scenario: User can verify ownership of the site
        #   Given I am signed in
        #   When I try to verify my site
        #   And have created the verification file
        #   Then I see a success message
        # scenario 'user can verify ownership of the site', js: true do
        #     click_link 'Verify'
        #
        #     # sleep 1 while !page.body.to_s.include? 'verified'
        #     # sleep 1 while !site.verification.reload.verified?
        #
        #     expect(page).to have_content 'Verified'
        #     expect(site.verification.reload).to be_verified
        # end
    end

end
