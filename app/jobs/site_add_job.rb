class SiteAddJob < ApplicationJob
  queue_as :default

  def perform( site_params, current_user )
      site = Site.new( site_params )
      site.user = current_user

      if validate_connectivity( site ) && site.save

      else

      end
  end

  def validate_connectivity( site )
      return true if site.protocol.blank? || site.host.blank? || site.port.blank?

      response = SCNR::Engine::HTTP::Client.get(
        "#{site.url}/favicon.ico",
        follow_location: true,
        mode:            :sync
      )

      if !response
          site.errors.add :host, "could not get response for: #{site.url}"
          return
      end

      if response.code == 0
          site.errors.add :host,
                      "#{response.return_message.to_s.downcase} for: #{site.url}"
          return
      end

      if response.headers['content-type'].start_with?( 'image' )
          IO.binwrite( site.provisioned_favicon_path, response.body )
      end

      true
    end

end
