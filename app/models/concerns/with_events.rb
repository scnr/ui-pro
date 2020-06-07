require 'active_support/concern'

module WithEvents
    extend ActiveSupport::Concern

    module ClassMethods

        def events( options = {} )
            options[:skip] ||= []
            if (track = options[:track])
                options[:skip] |= column_names.select { |k| !track.include? k }
            end

            has_paper_trail options.merge(
                 meta: {
                     site_id:     :event_site_id,
                     scan_id:     :event_scan_id,
                     revision_id: :event_revision_id,
                     object_to_s: :to_s
                 }
            )
        end

        # @param    [Block] block
        #   Block yielding a `Hash` with model class names as keys and
        #   Integer (id), record or relation as values.
        #
        #   The data in the hash will be used to select `PaperTrail::Version`
        #   records for children of this model.
        def children_events( &block )
            @children_events = block
        end

        # @return   [Block]
        #   Block set via {#children_events}; if no block has been set
        #   one that yields an empty hash will be returned instead.
        def children_events_selector
            @children_events || proc { {} }
        end

    end

    def event_site_id
        try( :site_id )
    end

    def event_scan_id
        try( :scan_id )
    end

    def event_revision_id
        try( :revision_id )
    end

    # @return   [ActiveRecord::Relation<PaperTrail::Version>]
    #   Events for this and {#children_events_selector children} records.
    def events
        query  = []
        params = []

        selectors = {
            self.class => self.id
        }.merge( instance_eval( &self.class.children_events_selector ) )

        selectors.each do |type, selector|
            sql = 'item_type = ? AND item_id '

            if selector.is_a?( Integer ) || selector.respond_to?( :id )
                sql << '= ?'
            else
                sql << 'IN (?)'
            end

            query  << sql
            params += [type, selector]
        end

        # We're a parent (Site, Scan or Revision), so grab children events
        # based on our foreign key.
        foreign_key = "#{self.class.to_s.downcase}_id"
        if PaperTrail::Version.column_names.include? foreign_key
            query  << "#{foreign_key} = ?"
            params << self.id
        end

        PaperTrail::Version.where( *[query.join( ' OR ' )] + params ).
            includes(:item).order( id: :desc )
    end

end
