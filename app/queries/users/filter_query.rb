module Users
  # Narrows an already-authorized user scope by the admin list filters.
  class FilterQuery
    def initialize(scope)
      @scope = scope
    end

    def call(role: nil, search: nil, archived: nil)
      relation = @scope.order(created_at: :desc, id: :desc)
      relation = relation.where(role:) if role
      relation = filter_by_archived(relation, archived)
      filter_by_search(relation, search)
    end

    private

    def filter_by_archived(relation, archived)
      return relation if archived.nil?

      archived ? relation.archived : relation.not_archived
    end

    # Case-insensitive substring match; % and _ in the term match literally.
    def filter_by_search(relation, search)
      term = search.to_s.strip
      return relation if term.empty?

      pattern = "%#{User.sanitize_sql_like(term)}%"
      relation.where("users.email ILIKE :pattern OR users.first_name ILIKE :pattern OR users.last_name ILIKE :pattern",
                     pattern:)
    end
  end
end
