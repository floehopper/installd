require 'simple_http.rb'
require 'http_test_server.rb'

require 'test/unit'
require 'uri'
require 'base64'

# These tests communicate with a corresponding http server (TestServer), which is
# implemented in `http_test_server.rb`

class SimpleHttpTest < Test::Unit::TestCase
	def initialize *args
		super *args
		# create webbrick server in a separate thread
		Thread.new {
			TestServer.new.start
		}
	end

	def teardown
		#@t.shutdown # webrick blocks in a weird way, can't
		#commnicate with it in a different thread. this, of
		#course, is really ugly.
	end

	# Tests of SimpleHttp class method behaviour.
	
	def test_get_class_method
		# string url
		ret = SimpleHttp.get "http://127.0.0.1:12345/test1"
		assert_equal(ret, TestServer::SUCCESS_TEXT_0, "basic GET 1 test failed.");
		
		# string url, with query	
		ret = SimpleHttp.get "http://127.0.0.1:12345/test1?query=true"
		assert_equal(ret, TestServer::SUCCESS_TEXT_0, "basic GET 2 test failed.");
		
		# uri
		uri = URI.parse "http://127.0.0.1:12345/test1?query=true"
		ret = SimpleHttp.get uri 
		assert_equal(ret, TestServer::SUCCESS_TEXT_0, "basic GET 3 test failed.");

		#string with query as hash	
		ret = SimpleHttp.get "http://127.0.0.1:12345/test2", "query" => "query_test"
		assert_equal("query_test", ret, "basic GET (query) 4 test failed.");
		
		#uri with existing query + query as hash.
		uri = URI.parse "http://127.0.0.1:12345/test2?query2=true"
		ret = SimpleHttp.get uri, "query" => "query_test"
		assert_equal("query_test", ret, "basic GET (query) 4.1 test failed.");


	end

	# Tests for http GET calls implemented using instantiated SimpleHttp objects.
	
	def test_get_class_instance_method
		http = SimpleHttp.new "http://127.0.0.1:12345/test1"
		ret = http.get 
		assert_equal(ret, TestServer::SUCCESS_TEXT_0, "instance GET 1 test failed.");

		http = SimpleHttp.new "http://127.0.0.1:12345/test2?query=query_test"
		ret = http.get
		assert_equal("query_test", ret, "instance GET 2 test (query)");

		http = SimpleHttp.new "http://127.0.0.1:12345/query_test2?query=query_test"
		ret = http.get "query2"=>"query2_test"
		assert_equal("query2_test", ret, "instance GET 2.1 test (add to existing query")

		http = SimpleHttp.new(URI.parse("http://127.0.0.1:12345/query_test2?bla=true"))
		ret = http.get "query2" => "query_test"
		assert_equal("query_test", ret, "basic GET (query) 3 test failed.")

		http = SimpleHttp.new(URI.parse("http://127.0.0.1:12345/query_test2?bla=true"))
		ret = http.get "something"=>"or the other", "query2" => "query_test"
		assert_equal("query_test", ret, "basic GET (query) 4 test failed.")

		# GET request with a custom request_header
		http = SimpleHttp.new "http://127.0.0.1:12345/header_test"
		http.request_headers= {'x-special-http-header'=>'my-value'}
		ret = http.get
		assert_equal("my-value", ret, "GET header test 4")

		# GET test with custom response_headers
		http = SimpleHttp.new "http://127.0.0.1:12345/header_test"
		http.request_headers= {'x-special-http-header'=>'resp-header-test'}
		http.get
		assert_equal("resp-header-test", http.response_headers['x-special-response'], "GET response header test 5")

		# GET test with custom request & response header and redirect
		# test that request headers we set remain intact during redirects.

		http = SimpleHttp.new "http://127.0.0.1:12345/redirect_special_header"
		http.request_headers["x-special-http-header"]='redirect_test'
		http.get
		assert_equal("redirect_test", http.response_headers['x-special-response'], "GET response header redirect test. 6")
				
	end
	
	# http POST calls using class methods.
	#
	def test_post_class_method

		# string url
		ret = SimpleHttp.post "http://127.0.0.1:12345/test1"
		assert_equal(ret, TestServer::SUCCESS_TEXT_0, "basic POST 1 test failed.");
		

		#string with query as hash	
		ret = SimpleHttp.post "http://127.0.0.1:12345/test2", "query" => "query_test"
		assert_equal("query_test", ret, "basic POST (query) 2 test failed.");
		
		#uri with existing query + query as hash.
		uri = URI.parse "http://127.0.0.1:12345/test2"
		ret = SimpleHttp.post uri, "query" => "query_test"
		assert_equal("query_test", ret, "basic POST (query) 2.1 test failed.");
		
		# post something other than a form.
		ret = SimpleHttp.post "http://127.0.0.1:12345/post_data_test", TestServer::POST_DATA, "misc/test-data"
		assert_equal(TestServer::POST_DATA, ret, "class Post data test")


	end

	
	def test_post_instance_method
		http = SimpleHttp.new "http://127.0.0.1:12345/test1"
		ret = http.post 
		assert_equal(ret, TestServer::SUCCESS_TEXT_0, "instance POST 1 test failed.");

		http = SimpleHttp.new "http://127.0.0.1:12345/test2"
		ret = http.post "query" => "query_test"
		assert_equal("query_test", ret, "instance POST 2 test (query)");

		http = SimpleHttp.new "http://127.0.0.1:12345/query_test2?query=query_test"
		ret = http.post "query2"=>"query2_test"
		assert_equal("query2_test", ret, "instance POST 2.1 test (add to existing query")

		http = SimpleHttp.new(URI.parse("http://127.0.0.1:12345/query_test2?bla=true"))
		ret = http.post "query2" => "query_test"
		assert_equal("query_test", ret, "basic POST (query) 3 test failed.")

		# POST requst with a custom request_header
		http = SimpleHttp.new "http://127.0.0.1:12345/header_test"
		http.request_headers= {'x-special-http-header'=>'my-value'}
		ret = http.post
		assert_equal("my-value", ret, "POST header test 4")
		
		# POST request with a custom data type (not posting a form.)
		http = SimpleHttp.new "http://127.0.0.1:12345/post_data_test"
		ret = http.post TestServer::POST_DATA, "misc/test-data"
		assert_equal(TestServer::POST_DATA, ret, "Post data test")


	end
	
	def test_basic_auth

		# string url
		ret = SimpleHttp.get "http://test:pwd@127.0.0.1:12345/basic_auth"
		assert_equal(TestServer::SUCCESS_TEXT_1, ret, "basic auth get class 1 test failed.");
		
		http = SimpleHttp.new "http://127.0.0.1:12345/basic_auth"
		http.basic_authentication "test", "pwd"
		ret = http.get 
		assert_equal(ret, TestServer::SUCCESS_TEXT_1, "basic auth get instance 2 test failed.");
		#string with query as hash	
		ret = SimpleHttp.post "http://test:pwd@127.0.0.1:12345/basic_auth", "query" => "query_test"
		assert_equal(TestServer::SUCCESS_TEXT_1, ret, "basic auth post class 3 test failed.");
		
		http = SimpleHttp.new "http://127.0.0.1:12345/basic_auth"
		http.basic_authentication "test", "pwd"
		ret = http.post TestServer::POST_DATA, "misc/test-data"
		assert_equal(TestServer::SUCCESS_TEXT_1, ret, "Post data test")
	end

	def test_response_handler
		assert_raise(RuntimeError) {	
			ret = SimpleHttp.get "http://test:pwd@127.0.0.1:12345/non_existant"
		}
		
		http = SimpleHttp.new "http://test:pwd@127.0.0.1:12345/non_existant"
		http.register_response_handler(Net::HTTPNotFound) { |req, res, http|
			res.code
		}
		ret = http.get
		assert_equal("404", ret, "response handler test 2")
		
		http = SimpleHttp.new "http://test:pwd@127.0.0.1:12345/redirect1"
		http.register_response_handler(Net::HTTPRedirection) { |req, res, http|
			res['location']
		}
		ret = http.get
		assert_equal("http://127.0.0.1:12345/redirect2", ret, "response handler test 3") 

	end

	def test_redirect 
		assert_raise(RuntimeError) {	
			http = SimpleHttp.new "http://test:pwd@127.0.0.1:12345/redirect1"
			ret = http.get
		}
		
			
		ret = SimpleHttp.get "http://test:pwd@127.0.0.1:12345/redirect"
		assert_equal(ret, TestServer::SUCCESS_TEXT_0, "redirect test 2");
	end
	


end

