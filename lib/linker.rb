#
# Linker
#
# Use Rack to do redirections for links and to provide an API for creating those links.
#

require_relative './linkstore'

require 'logger'
require 'rack'
require 'rack/cors'

HTTP_OK = 200
HTTP_REDIRECT_FOUND = 302
HTTP_NOT_FOUND = 404
HTTP_METHOD_NOT_ALLOWED = 405

class Linker
  GET = [:get, :log]
  POST = [:create]
  def initialize datafile, wordfile, access_log
    @linker = LinkStore.new datafile, words: File.open(wordfile)
    @access_log_path = access_log
    @access_log = Logger.new access_log
    @access_log.formatter = proc{|_,time,_,msg| "#{time.strftime '%FT%T%z'} #{msg}\n"}
  end
  def call_redirect(req)
    id = req.path_info.split('/')[1]
    uri = @linker.get id
    return [HTTP_NOT_FOUND, {}, []] if !uri
    @access_log.info "#{req.ip} #{id} #{[uri, req.referer, req.user_agent].map{|s|(s||'-').inspect}.join(' ')}"
    [HTTP_REDIRECT_FOUND, {'Location' => uri}, []]
  end
  def get(id)
    @linker.get id
  end
  def log
    File.new(@access_log_path).read
  end
  def create(url:nil)
    @linker.create url
  end
  def parse_api(req)
    _, cmd, *args = req.path_info.split('/').map {|e| Rack::Utils::unescape e}
    cmd = cmd.to_sym rescue nil
    meta_args, named_args = req.params.partition{|k,v| k =~ /^_/}.map{|p| Hash[p]}
    meta_args = Hash[meta_args.map{|k,v| [k[1..-1],v] }]
    meta_args, named_args = [meta_args, named_args].map{|a| Hash[a.map{|k,v| [k.to_sym,v] }]}
    [cmd, args, named_args, meta_args]
  end
  def call_api(req)
    cmd, args, named_args, meta_args = parse_api req
    return [HTTP_NOT_FOUND, {}, []] if !(GET+POST).include?(cmd)
    return [HTTP_METHOD_NOT_ALLOWED, {}, []] if (req.get? && !GET.include?(cmd)) || (req.post? && !POST.include?(cmd))
    if named_args.empty?
      result = self.public_send(cmd, *args)
    else
      result = self.public_send(cmd, *args, **named_args)
    end
    [HTTP_OK, {"Content-Type" => "text/plain"}, [result.to_s]]
  end
  def build
    app = lambda{|method| lambda{|env| self.public_send(method, Rack::Request.new(env))}}
    Rack::Builder.new do
      use Rack::Cors do
        allow do
          origins '*'
          resource '*', :headers => :any, :methods => [:get, :post]
        end
      end
      map '/api' do
        run app[:call_api]
      end
      run app[:call_redirect]
    end
  end
end
