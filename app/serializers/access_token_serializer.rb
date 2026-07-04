class AccessTokenSerializer < ApplicationSerializer
  attribute(:access_token, &:itself)
end
