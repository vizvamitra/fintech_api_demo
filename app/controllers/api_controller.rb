class ApiController < ApplicationController
  include Api::ErrorHandling
  include Api::JwtAuthentication
end
