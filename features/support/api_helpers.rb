module ApiHelpers
  def api_request(request_type, path, input)
    require 'erb'
    request_opts = {method: request_type.downcase.to_sym}

    if @auth_token.present?
      separator = (path.include? "?") ? "&" : "?"
      auth_token = @auth_token

      path = path + "#{separator}user_token=#{auth_token}"
    end

    unless input.nil?
      if input.class == Cucumber::Ast::Table
        replace_hash_meta_data input.rows_hash
        request_opts[:params] = input.rows_hash
      else
        request_opts[:params] = input
      end
    end

    request path, request_opts
  end

end
World(ApiHelpers)