class SiteVerificationWorker
    include Sidekiq::Worker

    def perform( id )
        verification = SiteVerification.find_by_id( id )
        return if !verification || verification.done?

        verification.started!

        response = Typhoeus.get(
            verification.url,
            timeout_ms:     5_000,
            ssl_verifypeer: false,
            ssl_verifyhost: 0
        )

        if response.code == 0
            verification.message = 'Server did not return a response. ' <<
                "(#{response.return_code}: #{response.return_message})"

            verification.failed!
            return
        elsif response.code != 200
            verification.message = "HTTP response didn't have an 200 (OK) " <<
                "status code: #{response.code}"

            verification.failed!
            return
        end

        if response.body.to_s.strip != verification.code
            verification.message = 'HTTP response body did not match the verification code.'
            verification.failed!
            return
        end

        verification.verified!
    rescue => e
        verification.message = "[#{e.class}] #{e}"
        verification.error!
    end
end
