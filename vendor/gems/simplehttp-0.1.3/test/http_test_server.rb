require 'webrick'
#require 'constants'

include WEBrick
class TestServer
	SUCCESS_TEXT_0 = "success_0"
	SUCCESS_TEXT_1 = "success_1"
	SUCCESS_TEXT_2 = "success_2"
	SUCCESS_TEXT_3 = "success_3"
	SUCCESS_TEXT_4 = "success_4"
	SUCCESS_TEXT_5 = "success_5"
	SUCCESS_TEXT_6 = "success_6"
	SUCCESS_TEXT_7 = "success_7"
	SUCCESS_TEXT_8 = "success_8"
	SUCCESS_TEXT_9 = "success_9"

	POST_DATA = [0xbe, 0x00, 0x12, 0x23, 0x45, 0x67, 0x89, 0xAB].join

	def initialize
		@server = HTTPServer.new(
			:Port => 12345
		)

		add_tests
	end
	
	def start
		@server.start
	end

	def shutdown
		@server.shutdown
	end
	
	def dbg str 
		puts "!!!!!!!!! #{str}"
	end
	def add_tests
		# return a text
		@server.mount_proc("/test1"){|req, res|
			res.body=SUCCESS_TEXT_0
		}
		#return value of query param named "query"
		@server.mount_proc("/test2"){|req, res|
			res.body=req.query["query"]
		}
		
		# return value of query param named "query2"
		@server.mount_proc("/query_test2"){|req, res|
			res.body=req.query["query2"]
		}
		
		# return value of request header named "X-Special-Http-Header"
		@server.mount_proc("/header_test"){|req, res|
			res.body=req.header["x-special-http-header"][0]
			res['x-special-response']=req.header["x-special-http-header"][0]
		}
		
		# return value of request header named "X-Special-Http-Header"
		@server.mount_proc("/post_data_test"){|req, res|
			ctype = req.header['content-type'][0]
			if "misc/test-data" == ctype 
				res.body=req.body
			else
				res.body="failed, content-type: #{ctype}"
			end	
		}

		@server.mount_proc("/basic_auth") {|req, res|
			
			auth = Base64.decode64(req.header['authorization'][0].split[1])
			usr, pwd = auth.split(':')
			if ('test'==usr && 'pwd'==pwd)
				res.body=SUCCESS_TEXT_1	
			else
				res.status=403
			end
		}

		1.upto(6) {|i|
			@server.mount_proc("/redirect#{i}") { |req, res|
				res.status=301
				res.header['location']="http://127.0.0.1:12345/redirect#{i+1}"	
			}
		}
		
		@server.mount_proc("/redirect") { |req, res|
			res.status=301
			res.header['location']="http://127.0.0.1:12345/test1"	
		}

		@server.mount_proc("/redirect_special_header") { |req, res|
			res.status=301
			res.header['location']="http://127.0.0.1:12345/header_test"
		}
	end
end
