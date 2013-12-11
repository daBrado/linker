#
# Redirect App
#
# A Rack application for generating redirections based on the Linker API.
#

require 'net/http'
require 'logger'
require 'rack'

HTTP_REDIRECT_FOUND = 302
HTTP_NOT_FOUND = 404
HTTP_SERVICE_UNAVAILABLE = 503

class RedirectApp
  def initialize(api_uri, log:Logger.new(STDERR))
    @api_uri = URI api_uri
    @api_http = Net::HTTP.new(@api_uri.hostname, @api_uri.port)
    @log = log
    @log.formatter = lambda{|_,time,_,msg| "#{time.strftime '%FT%T%z'} #{msg}\n"}
  end
  def call(env)
    req = Rack::Request.new env
    id = Rack::Utils::unescape(req.path_info.split('/')[1]) rescue nil
    return [HTTP_NOT_FOUND, {}, []] if !id
    dest_uri = @api_http.request(Net::HTTP::Get.new(File.join(@api_uri.path, 'get', id))).body rescue nil
    return [HTTP_SERVICE_UNAVAILABLE, {}, []] if !dest_uri
    return [HTTP_NOT_FOUND, {}, []] if dest_uri == ''
    @log.info "#{req.ip} #{[req.referer, req.user_agent].map{|s|(s||'-').inspect}.join(' ')} #{id} #{dest_uri.inspect}"
    [HTTP_REDIRECT_FOUND, {'Location' => dest_uri}, []]
  end
end
