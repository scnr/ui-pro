class SiteVerificationWorker < RenderWorker

    def perform( id, refreshable_channel )
        @refreshable_channel = refreshable_channel
        @verification        = SiteVerification.find_by_id( id )

        return if !@verification || @verification.verified?

        update :started

        response = Typhoeus.get(
            @verification.url,
            timeout_ms:     5_000,
            ssl_verifypeer: false,
            ssl_verifyhost: 0
        )

        if response.code == 0
            update :failed, 'Server did not return a response. ' <<
                "(#{response.return_code}: #{response.return_message})"
            return
        elsif response.code != 200
            update :failed, "HTTP response didn't have an 200 (OK) " <<
                "status code: #{response.code}"
            return
        end

        if response.body.to_s.strip != @verification.code
            update :failed, 'HTTP response body did not match the @verification code.'
            return
        end

        update :verified
    rescue => e
        update :error, "[#{e.class}] #{e}"
        nil
    end

    def update( action, message = nil )
        @verification.message = message
        @verification.send "#{action}!"

        html = render(
            partial: 'sites/form_verification',
            locals: { site: @verification.site.reload }
        )

        @verification.site.user.notify_browser @refreshable_channel, html
    end

end
