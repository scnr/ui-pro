module IssuesHelper
    include IssuesSummary

    def data_dump( data )
        ap = AwesomePrint::Inspector.new( plain: true, html: true )
        "<pre class='data-dump'>#{ap.awesome( data )}</pre>".html_safe
    end

    def filter_params
        prepare_issue_filters
        { filter: params[:filter] }
    end

    def filter_params_without_page
        prepare_issue_filters

        np         = params[:filter].dup
        np[:pages] = []
        { filter: np }
    end

    def sitemap_entry_url( sitemap_entry )
        filter_params_without_page.merge(
            'filter[pages][]' => sitemap_entry.id
        )
    end

    def fa_icon_to_unicode( icon )
        case icon
            when 'circle'
                '&#xf111;'

            when 'exclamation-circle'
                '&#xf06a;'

            when 'remove'
                '&#xf00d;'

            when 'question-circle'
                '&#xf059;'

            when 'check'
                '&#xf00c;'
        end
    end

    def issue_state_to_icon( state )
        case state
            when 'trusted'
                'check'

            when 'untrusted'
                'question-circle'

            when 'false_positive'
                'exclamation-circle'

            when 'fixed'
                'remove'
        end
    end

    def issue_state_to_unicode( state )
        fa_icon_to_unicode( issue_state_to_icon( state ) )
    end

    def id_to_location( id )
        "#!/#{id.gsub( '-', '/' )}"
    end

    def highlight_seed( issue )
        code_highlight(
            escape_control_characters( issue.vector.seed ),
            issue.platform ? issue.platform.shortname : nil
        ).html_safe
    end

    def highlight_vector_source( vector )
        s = code_highlight(
            vector_source_prettify( vector ),
            vector_type_to_source_type( @issue.vector.kind ),
            line_numbers: true,
            anchor_id:    'input_vector-source'
        )

        (highlight_proof( s, vector.default_inputs[vector.affected_input_name] ) || s).html_safe
    end

    def vector_source_prettify( vector )
        source = @issue.vector.source

        case vector.kind
            when :json
                JSON.pretty_generate( JSON.load( source ) )

            else
                source
        end
    end

    def vector_type_to_source_type( type )
        case type
            when :json, :xml
                type

            else
                :html
        end
    end

    def highlight_http_request( request, issue, highlight )
        return if !highlight

        case issue.vector.arachni_class.to_s

            when 'Arachni::Element::LinkTemplate'
                encoded = Arachni::URI( highlight ).to_s

            when 'Arachni::Element::JSON'
                encoded = highlight.to_json[1..-2]

            when 'Arachni::Element::XML'
                encoded = highlight

            else
                encoded = issue.vector.arachni_class.respond_to?( :encode ) ?
                    issue.vector.arachni_class.encode( highlight ) :
                    highlight
        end

        s = highlight_proof( request.to_s, encoded )
        return if !s

        s.html_safe
    end

    def string_has_proof?( string, proof )
        return if proof.to_s.empty?
        return false if !string.to_s.recode.downcase.include?( proof.recode.downcase )

        true
    end

    def highlight_proof( string, proof )
        return if !string_has_proof?( string, proof )

        escaped_proof         = h( proof.to_s.recode )
        escaped_response_body = h( string.to_s.recode )

        escaped_response_body.gsub(
            Regexp.new(
                Regexp.escape( escaped_proof ),
                Regexp::IGNORECASE | Regexp::MULTILINE
            ),
            "<span class=\"highlight\">\\0</span>"
        ).html_safe
    end

    def html_diff( string1, string2 )
        Diffy::Diff.new( string1, string2 )
    end

    def escape_control_characters( string )
        string = string.dup
        {
            "\n"   => '\\\n',
            "\r"   => '\\\r',
            "\x00" => '\\\0'
        }.each { |pair| string.gsub!( *pair ) }
        string
    end

    extend self

end
