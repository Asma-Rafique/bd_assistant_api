# One page of records plus Pagy's page numbers, the object a *PaginationType reads.
PaginatedRecords = Data.define(:records, :pagy) do
  delegate :count, :page, :last, :next, :previous, to: :pagy
end
