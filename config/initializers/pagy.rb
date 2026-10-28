# Page size when the client doesn't ask for one, and the most it may ask for.
Pagy::OPTIONS[:limit] = 25
Pagy::OPTIONS[:client_limit] = 100
Pagy::OPTIONS.freeze
