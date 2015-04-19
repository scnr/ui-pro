module IssuesHelper

    def data_dump( data )
        ap = AwesomePrint::Inspector.new( plain: true, html: true )
        "<pre class='data-dump'>#{ap.awesome( data )}</pre>".html_safe
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
        code_highlight(
            vector_source_prettify( vector ),
            vector_type_to_source_type( @issue.vector.kind ),
            line_numbers: true,
            anchor_id:    'input_vector-source'
        ).html_safe
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

    def highlight_proof( string, proof )
        string = string.to_s.recode
        proof  = proof.to_s.recode

        return h( string ) if proof.to_s.empty?
        return h( string ) if !string.downcase.include?( proof.downcase )

        escaped_proof         = h( proof )
        escaped_response_body = h( string )

        escaped_response_body.gsub(
            Regexp.new( escaped_proof, Regexp::IGNORECASE ),
            "<span class=\"issue-proof-highlight\">\\0</span>"
        )
    end

    def escape_control_characters( string )
        string.gsub( "\x00", '\\\0' )
    end

end
