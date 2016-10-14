module Mws
  class Connection
    def get_no_parse(path, params, overrides)
      request_no_parse(:get, path, params, nil, overrides)
    end

    private

    def request_no_parse(method, path, params, body, overrides)
      query = Query.new({
                            action: overrides[:action],
                            version: overrides[:version],
                            merchant: @merchant,
                            access: @access,
                            list_pattern: overrides.delete(:list_pattern)
                        }.merge(params))
      signer = Signer.new method: method, host: @host, path: path, secret: @secret
      response_for(method, path, signer.sign(query), body)
    end
  end
end

module Mws::Apis::Feeds
  class SubmissionResult

    def initialize(node)
      @transaction_id = node.xpath('ProcessingReport/DocumentTransactionID').first.text.to_s
      @status = Status.for(node.xpath('ProcessingReport/StatusCode').first.text)
      @messages_processed = node.xpath('ProcessingReport/ProcessingSummary/MessagesProcessed').first.text.to_i

      @counts = {}
      [Response::Type.SUCCESS, Response::Type.ERROR, Response::Type.WARNING].each do |type|
        @counts[type.sym] = node.xpath("ProcessingReport/ProcessingSummary/#{type.val.first}").first.text.to_i
      end
      @responses = {}
      node.xpath('ProcessingReport/Result').each do |result_node|
        response = Response.from_xml(result_node)
        @responses[response.id.to_sym] = response
      end
      @node = node
    end

    def node
      @node
    end

    def all_responses
      @responses
    end
  end
end
